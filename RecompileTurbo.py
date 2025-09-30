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
    MAPVOTE = 5

ArgumentParser = argparse.ArgumentParser()
ArgumentParser.add_argument("-t","--onlyturbo", action="store_true", help="Only rebuild KFTurbo and KFTurboServer.")
ArgumentParser.add_argument("-o","--onlyholdout", action="store_true", help="Only rebuild Turbo Holdout.")
ArgumentParser.add_argument("-r","--onlyrandomizer", action="store_true", help="Only rebuild Turbo Randomizer.")
ArgumentParser.add_argument("-c","--onlycardgame", action="store_true", help="Only rebuild Turbo Card Game.")
ArgumentParser.add_argument("-m","--onlymapvote", action="store_true", help="Only rebuild Turbo Map Vote.")
ArgumentParser.add_argument("-a","--achievements", action="store_true", help="Adds KFTurboServerAchievements to build list.")
ArgumentParser.add_argument("-v", "--verboseUCC", action="store_true", help="Will log all of UCC make.")
ArgumentParser.add_argument("-s", "--stagefiles", action="store_true", help="Copies KFTurbo packages to staging directories.")
ArgumentParser.add_argument("--extrastage", help="Copies KFTurbo packages to a specified directory (such as a local test server). --stagefiles flag must be set.")
ArgumentParser.add_argument("--fonts", action="store_true", help="Rebuild all font packages. Will take a long time.")
ArgumentParser.add_argument("--printremovefailure", action="store_true", help="Print when this script fails to delete files.")

Arguments = ArgumentParser.parse_args()

#Type of build to do.
BuildType = EBuildType.ALL

#Files KFTurbo compiles.
TurboFiles = ["CommonCore.u", "KFTurboMapVote.u", "KFTurboEmbeddable.u", #Turbo-agnostic packages.
            "KFTurboGUI.u", "KFTurboFonts.u", "KFTurboFontsJP.u", "KFTurboFontsCY.u", #Asset packages.
            "KFTurbo.u", "KFTurboServer.u", "KFTurboCommon.u", #Turbo Core packages.
            "KFTurboHoldout.u", "KFTurboRandomizer.u", "KFTurboCardGame.u", "KFTurboTestMut.u"] #Special gamemode packages.

#Files needed for Turbo deployments.
TurboStagingFiles = [ "KFTurbo.ucl", "KFTurboServer.ucl",
            "KFTurboHoldout.ucl", "KFTurboRandomizer.ucl", "KFTurboCardGame.ucl", "KFTurboTestMut.ucl",
            "ServerPerks.ini" ]

def UpdateBuildType():
    global BuildType
    global TurboFiles
    global TurboStagingFiles

    if Arguments.onlyturbo:
        BuildType = EBuildType.TURBO
        TurboFiles = [ "CommonCore.u", "KFTurbo.u", "KFTurboServer.u", "KFTurboCommon.u" ]
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
    elif Arguments.onlymapvote:
        BuildType = EBuildType.MAPVOTE
        TurboFiles = [ "KFTurboMapVote.u" ]
        TurboStagingFiles = [ ]

    if Arguments.achievements:
        TurboFiles.append(["KFTurboServerAchievements.u"])
        TurboFiles.append(["KFTurboServerAchievements.ucl"])
    
UpdateBuildType()

StageFiles = Arguments.stagefiles

if StageFiles and not (BuildType is EBuildType.ALL):
    print("\033[43m  \033[0m" + "\033[33m Warning: --stagefiles files was specified when not performing a full rebuild.\033[0m")

RebuildFonts = Arguments.fonts
VerboseUCC = Arguments.verboseUCC
PrintRemoveFailure = Arguments.printremovefailure

LocalPath = pathlib.Path().resolve()
SystemPath = LocalPath.joinpath("System")

GitHubStagingPath = LocalPath.joinpath("StagedKFTurboGitHub")
ServerStagingPath = LocalPath.joinpath("StagedKFTurbo/System")
ExtraStagingPath = None

if Arguments.extrastage != None:
    ExtraStagingPath = pathlib.Path(Arguments.extrastage)

StepStrings = ["font "]
WarningStrings = ["warning", "unused local"]
ErrorStrings = ["error", "unresolved", "failed", "failure", "unknown property", "bad cast", "redundant data", "critical:"]

def PrintTask(String):
    print("\033[48;5;7m  \033[0m " + String)
def PrintStep(String):
    print("\033[48;5;7m \033[0m " + String)
def PrintWarning(String):
    print("\033[43m \033[0m \033[33m" + String + "\033[0m")
def PrintError(String):
    print("\033[41m \033[0m \033[31m" + String + "\033[0m")
def PrintSuccess(String):
    print("\033[48;2;0;200;0m \033[0m \033[38;2;0;200;0m" + String + "\033[0m")

def DeleteTurboPackages():
    for FileName in TurboFiles:
        if (not RebuildFonts) and FileName.startswith("KFTurboFonts"):
            continue
        try:
            os.remove(SystemPath.joinpath(FileName))
        except FileNotFoundError as Error:
            if PrintRemoveFailure:
                print(f"{str(Error).split('\'')[0]} {FileName}")
        except Exception as Error:
            ErrorMessageSplit = str(Error).split('\'')[0]
            ErrorMessageSplit = ErrorMessageSplit.split(']')
            if len(ErrorMessageSplit) == 1:
                print(f"\033[33m {ErrorMessageSplit[0]} {FileName} \033[0m")
            else:
                print(f"\033[33m {ErrorMessageSplit[1]} {FileName} \033[0m")

def ProcessUCCMake(Process):
    HasReachedEnd = False
    FoundAnyErrors = False
    PreviousLine = ""
    while True:
        Line = Process.stdout.readline()

        if not Line:
            if not FoundAnyErrors:
                PrintSuccess("Compile completed without any errors.")
            break

        Line = Line.rstrip()

        if Line.startswith("Compile"):
            HasReachedEnd = True

        if HasReachedEnd:
            if Line.startswith("Compile aborted") or Line.startswith("Failure -"):
                PrintError(Line)
                FoundAnyErrors = True
        elif Line.startswith("Analyzing..."):
            ModuleName = PreviousLine.replace("-", "").split(' ')[0]
            PrintStep(f"Compiling {ModuleName}...")
        elif any (FlagString in Line.lower() for FlagString in ErrorStrings):
            PrintError("  " + Line)
            FoundAnyErrors = True
        elif any (FlagString in Line.lower() for FlagString in WarningStrings):
            PrintWarning("  " + Line)
            FoundAnyErrors = True
        elif any (FlagString in Line.lower() for FlagString in StepStrings):
            PrintStep("  " + Line)

        PreviousLine = Line

        if not (Process.poll() is None):
            break

def RunUCCMake():
    UCCMakePath = LocalPath.joinpath(SystemPath, "UCC.exe")
    PrintTask("Running UCC make command...")
    try:
        if not VerboseUCC:
            UCCMakeProcess = subprocess.Popen([UCCMakePath, "make"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, bufsize=1)
            ProcessUCCMake(UCCMakeProcess)
        else:
            UCCMakeResult = subprocess.run([UCCMakePath, "make"], text=True, check=True)
    except subprocess.CalledProcessError as Error:
        print(f"Failed to run UCC make. Received return code {Error.returncode}.")
    os.remove(SystemPath.joinpath("steam_appid.txt"))
    print("... UCC make finished.")

def CheckIfAllFilesArePresent():
    MissingFiles = []
    for FileName in TurboFiles:
        FilePath = SystemPath.joinpath(FileName)
        if not FilePath.is_file():
            MissingFiles.append(FileName)
    if len(MissingFiles) != 0:
        raise MissingPackagesError("Missing files: " + " ".join(MissingFiles))

def CopyTurboFilesToTarget(Destination, bIsToServer):
    PrintStep(f"Copying files to {Destination}...")
    for FileName in TurboFiles:
        FilePath = SystemPath.joinpath(FileName)
        shutil.copy2(FilePath, Destination)
    for StagingFileName in TurboStagingFiles:
        if bIsToServer and StagingFileName.endswith(".ini"):
            continue
        FilePath = SystemPath.joinpath(StagingFileName)
        shutil.copy2(FilePath, Destination)

def CopyTurboFilesToDeployments():
    try:
        CopyTurboFilesToTarget(GitHubStagingPath, False)
        CopyTurboFilesToTarget(ServerStagingPath, True)
        if ExtraStagingPath != None:
            CopyTurboFilesToTarget(ExtraStagingPath, False)
        PrintSuccess(f"Successfully copied files.")
    except Exception as Error:
        PrintError(f"{Error}")

def PerformCompile():
    DeleteTurboPackages()
    RunUCCMake()

    PrintTask("Checking for expected files...")
    FoundAllFiles = True
    try:
        CheckIfAllFilesArePresent()
        PrintSuccess("All expected files found.")
    except MissingPackagesError as Error:
        PrintError(f"{Error}")
        FoundAllFiles = False
    print("... expected file check complete.")
    
    if StageFiles and FoundAllFiles:
        PrintTask("Staging files...")
        CopyTurboFilesToDeployments()
        print("... staging files finished.")

PerformCompile()