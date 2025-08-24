
#Killing Floor Turbo RecompileTurbo.py
#Simple script used to compile KFTurbo.
#Makes working in VSCode on KFTurbo easier.
#Distributed under the terms of the MIT License.
#For more information see https://github.com/KFPilot/KFTurbo.
import argparse
from enum import Enum
import pathlib
import os
import subprocess
import shutil

class MissingPackagesError(Exception):
    pass

#Represents the kind of build we're trying to do.
class EBuildType(Enum):
    ALL = 0
    TURBO = 1
    HOLDOUT = 2
    RANDOMIZER = 3
    CARDGAME = 4

ArgumentParser = argparse.ArgumentParser()
ArgumentParser.add_argument("--fonts", action="store_true", help="Rebuild all font packages. Will take a long time.")
ArgumentParser.add_argument("--printremovefailure", action="store_true", help="Print when this script fails to delete files.")
ArgumentParser.add_argument("--onlyturbo", action="store_true", help="Only rebuild KFTurbo and KFTurboServer.")
ArgumentParser.add_argument("--onlyholdout", action="store_true", help="Only rebuild Turbo Card Game.")
ArgumentParser.add_argument("--onlyrandomizer", action="store_true", help="Only rebuild Turbo Randomizer.")
ArgumentParser.add_argument("--onlycardgame", action="store_true", help="Only rebuild Turbo Holdout.")
ArgumentParser.add_argument("--verboseUCC", action="store_true", help="Will log all of UCC make.")
ArgumentParser.add_argument("--stagefiles", action="store_true", help="Copies KFTurbo packages to staging directories.")

Arguments = ArgumentParser.parse_args()

#Type of build to do.
BuildType = EBuildType.ALL

#Files KFTurbo compiles.
TurboFiles = ["KFTurboEmbeddable.u", "KFTurboServerAchievements.u", #Turbo-agnostic packages.
            "KFTurboFonts.u", "KFTurboFontsJP.u", "KFTurboFontsCY.u", #Asset packages.
            "KFTurbo.u", "KFTurboServer.u", #Turbo Core packages.
            "KFTurboAchievementPack.u", #Additional Turbo content packages.
            "KFTurboHoldout.u", "KFTurboRandomizer.u", "KFTurboCardGame.u", "KFTurboTestMut.u"] #Special gamemode packages.

#Files needed for Turbo deployments.
TurboStagingFiles = [ "KFTurbo.ucl", "KFTurboServer.ucl", "KFTurboServerAchievements.ucl",
            "KFTurboHoldout.ucl", "KFTurboRandomizer.ucl", "KFTurboCardGame.ucl", "KFTurboTestMut.ucl",
            "ServerPerks.ini", "ServerAchievements.ini" ]

def UpdateBuildType():
    global BuildType
    global TurboFiles
    global TurboStagingFiles

    if Arguments.onlyturbo:
        BuildType = EBuildType.TURBO
        TurboFiles = [ "KFTurbo.u", "KFTurboServer.u" ]
        TurboStagingFiles = [ "KFTurbo.ucl", "KFTurboServer.ucl" ]
    elif Arguments.onlyholdout:
        BuildType = EBuildType.HOLDOUT
        TurboFiles = [ "KFTurboHoldout.u" ]
        TurboStagingFiles = [ "KFTurboHoldout.ucl" ]
    elif Arguments.onlyrandomizer:
        BuildType = EBuildType.RANDOMIZER
        TurboFiles = [ "KFTurboRandomizer.u" ]
        TurboStagingFiles = [ "KFTurboRandomizer.ucl" ]
    elif Arguments.onlycardgame:
        BuildType = EBuildType.CARDGAME
        TurboFiles = [ "KFTurboCardGame.u" ]
        TurboStagingFiles = [ "KFTurboCardGame.ucl" ]
    
UpdateBuildType()

StageFiles = Arguments.stagefiles
RebuildFonts = Arguments.fonts
VerboseUCC = Arguments.verboseUCC
PrintRemoveFailure = Arguments.printremovefailure

LocalPath = pathlib.Path().resolve()
SystemPath = LocalPath.joinpath("System")

GitHubStagingPath = LocalPath.joinpath("StagedKFTurboGitHub")
ServerStagingPath = LocalPath.joinpath("StagedKFTurbo/System")

WarningStrings = ["warning", "unused local"]
ErrorStrings = ["error", "warning", "unresolved", "failed", "failure"]

def DeleteTurboPackages():
    for FileName in TurboFiles:
        if (not RebuildFonts) and FileName.startswith("KFTurboFonts"):
            continue
        try:
            os.remove(SystemPath.joinpath(FileName))
        except FileNotFoundError:
            if PrintRemoveFailure:
                print(f"{str(Error).split('\'')[0]} {FileName}")
            pass
        except Exception as Error:
            ErrorMessageSplit = str(Error).split('\'')[0]
            ErrorMessageSplit = ErrorMessageSplit.split(']')
            if len(ErrorMessageSplit) == 1:
                print(f"\033[33m {ErrorMessageSplit[0]} {FileName} \033[0m")
            else:
                print(f"\033[33m {ErrorMessageSplit[1]} {FileName} \033[0m")


def ProcessUCCMake(Process):
    HasReachedEnd = False
    PreviousLine = ""
    while True:
        Line = Process.stdout.readline()

        if not Line:
            break

        Line = Line.rstrip()

        if Line.startswith("Compile"):
            HasReachedEnd = True

        if Line.startswith("Analyzing..."):
            ModuleName = PreviousLine.replace("-", "").split(' ')[0]
            print(f"  Compiling {ModuleName}...")
        elif any (FlagString in Line.lower() for FlagString in ErrorStrings):
            if not HasReachedEnd:
                print("    " + "\033[31m" + Line + "\033[0m")
            else:
                print("  " + Line)
        elif any (FlagString in Line.lower() for FlagString in WarningStrings):
            if not HasReachedEnd:
                print("    " + "\033[33m" + Line + "\033[0m")
            else:
                print("  " + Line)
        PreviousLine = Line

        if not (Process.poll() is None):
            break

def RunUCCMake():
    UCCMakePath = LocalPath.joinpath(SystemPath, "UCC.exe")
    print("Running UCC make command...")
    try:
        if not VerboseUCC:
            UCCMakeProcess = subprocess.Popen([UCCMakePath, "make"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
            ProcessUCCMake(UCCMakeProcess)
        else:
            UCCMakeResult = subprocess.run([UCCMakePath, "make"], text=True)
    except subprocess.CalledProcessError as Error:
        print(f"Failed to run UCC make. Received return code {e.returncode}.")
    os.remove(SystemPath.joinpath("steam_appid.txt"))
    print("... UCC make finished.")

def CheckIfAllFilesArePresent():
    MissingFiles = []
    for FileName in TurboFiles:
        FilePath = SystemPath.joinpath(SystemPath, FileName)
        if not FilePath.is_file():
            MissingFiles.append(FileName)
    if len(MissingFiles) != 0:
        raise MissingPackagesError("Missing files: " + " ".join(MissingFiles))

def CopyTurboFilesToTarget(Destination):
    print(f"Copying files to {Destination}...")
    for FileName in TurboFiles:
        FilePath = SystemPath.joinpath(SystemPath, FileName)
        shutil.copy2(FilePath, Destination)
    for StagingFileName in TurboStagingFiles:
        StagingFilePath = SystemPath.joinpath(StagingFileName, FileName)
        shutil.copy2(FilePath, Destination)

def CopyTurboFilesToDeployments():
    CopyTurboFilesToTarget(GitHubStagingPath)
    CopyTurboFilesToTarget(ServerStagingPath)
    print("KFTurbo files copied to staging folders successfully.")

def PerformCompile():
    DeleteTurboPackages()
    RunUCCMake()
    
    try:
        CheckIfAllFilesArePresent()
    except MissingPackagesError as Error:
        print(f"{Error}")
        return

    print("KFTurbo compiled successfully.")

    if StageFiles:
        CopyTurboFilesToDeployments()

PerformCompile()