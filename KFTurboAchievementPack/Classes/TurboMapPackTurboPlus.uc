class TurboMapPackTurboPlus extends TurboMapPackHoE;

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum)
{
    local int Index;
    local string LowerCaseMapName;
    local bool bValidLength;

    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }
    
    if (!class'KFTurboGameType'.static.StaticIsHighDifficulty(Self))
    {
        return;
    }

    if (result != 2 || requiredDifficulty != difficulty || !playedBossWave)
    {
        return;
    }

    bValidLength = KFStoryGameInfo(Level.Game) != none || (KFGameType(Level.Game) != None && length == KFGameType(Level.Game).GL_Long);

    if (!bValidLength)
    {
        return;
    }

    if (numWavesPlayed < (KFGameType(Level.Game).FinalWave / 2) + 1)
    {
        return;
    }
    
    LowerCaseMapName = Locs(mapname);
    for(Index = 0; Index < mapIndexes.Length; Index++)
    {
        if (mapIndexes[Index].mapname != LowerCaseMapName)
        {
            continue;
        }
        
        achievementCompleted(mapIndexes[Index].achvIndex);
        break;
    }
}

defaultproperties
{
    packName="KFTurbo+ Map Achievements"

    achievements=()
    achievements(0)=(title="Abyssal Pub Crawl",description="Win a long game on West London (or any variant) on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.WestLondon_Turbo')
    achievements(1)=(title="Overlord of the Manor",description="Win a long game on Manor on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Manor_Turbo')
    achievements(2)=(title="Turbo Tiller",description="Win a long game on Farm on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Farm_Turbo')
    achievements(3)=(title="Boss of HR",description="Win a long game on Offices on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Offices_Turbo')
    achievements(4)=(title="Mad Scientist",description="Win a long game on Biotics Lab on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.BioticsLab_Turbo')
    achievements(5)=(title="Demonic Forgemaster",description="Win a long game on Foundry on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Foundry_Turbo')
    achievements(6)=(title="Irreversible Brain Damage",description="Win a long game on Bedlam on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Bedlam_Turbo')
    achievements(7)=(title="Warden of the Dark Forrest",description="Win a long game on Wyre on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Wyre_Turbo')
    achievements(8)=(title="Wastelander",description="Win a long game on Biohazard on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Biohazard_Turbo')
    achievements(9)=(title="Warehouse OSHA Inspector",description="Win a long game on Crash on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Crash_Turbo')
    achievements(10)=(title="Soul Departure",description="Win a long game on Departed (or any variant) on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Departed_Turbo')
    achievements(11)=(title="Gridlock",description="Win a long game on Filth's Cross on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.FilthsCross_Turbo')
    achievements(12)=(title="Cutting Corners",description="Win a long game on Hospital Horrors on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.HospitalHorrors_Turbo')
    achievements(13)=(title="Stirred, not Shaken",description="Win a long game on Icebreaker (or any variant) on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Icebreaker_Turbo')
    achievements(14)=(title="Thousand Year Hike",description="Win a long game on Mountain Pass on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.MountainPass_Turbo')
    achievements(15)=(title="Urban Terrorist",description="Win a long game on Suburbia on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Suburbia_Turbo')
    achievements(16)=(title="Deluge",description="Win a long game on Waterworks on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Waterworks_Turbo')
    achievements(17)=(title="11 Agonizing Days of Christmas",description="Win a long game on Santa's Evil Lair on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.EvilSanta_Turbo')
    achievements(18)=(title="Except the Ones Who Are Dead",description="Win a long game on Aperture (or any variant) on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Aperture_Turbo')
    achievements(19)=(title="Carnival Carnage",description="Win a long game on Abusement Park (or any variant) on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.AbusementPark_Turbo')
    achievements(20)=(title="Dry Ice",description="Win a long game on Ice Cave on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.IceCave_Turbo')
    achievements(21)=(title="Demon Speeding",description="Win a long game on Hellride on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Hellride_Turbo')
    achievements(22)=(title="Siblings",description="Win a long game on Hillbilly Horror on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Hillbilly_Turbo')
    achievements(23)=(title="Fake Landing",description="Win a long game on Moonbase on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Moonbase_Turbo')
    achievements(24)=(title="Quantum Superposition Entanglement Expert",description="Win a long game on Steamland on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Steamland_Turbo')
    achievements(25)=(title="Gamma Particle Chrono-Dynamics Expert",description="Win Steamland in Objective Mode on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.SteamlandKFO_Turbo')
    achievements(26)=(title="Port Commander",description="Win a long game on Fright Yard on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Frightyard_Turbo')
    achievements(27)=(title="Logistics Titan",description="Win Fright Yard in Objective Mode on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.FrightyardKFO_Turbo')
    achievements(28)=(title="Ninth Circle",description="Win a long game on Hell on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Hell_Turbo')
    achievements(29)=(title="Infinite Lapse",description="Win a long game on Forgotten on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Forgotten_Turbo')
    achievements(30)=(title="Grand Distiller",description="Win a long game on Siren's Belch on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.SirensBelch_Turbo')
    achievements(31)=(title="King-Emporer",description="Win a long game on Stronghold on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Stronghold_Turbo')
    achievements(32)=(title="Premium First Class",description="Win a long game on Transit on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Transit_Turbo')
    achievements(33)=(title="In a Worse Place Now",description="Win Transit in Objective Mode on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.TransitKFO_Turbo')
    achievements(34)=(title="Roofies from Hell",description="Win a long game on Clandestine on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Clandestine_Turbo')
    achievements(35)=(title="Den of Despair",description="Win a long game on ThrillsChills on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.ThrillsChills_Turbo')
    
    //New Map Achievements.
    achievements(36)=(title="Ice Shelf Lockout",description="Win a long game on Northern Solitude on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.NorthernSolitude_Turbo')
    achievements(37)=(title="Figurine Enthusiast",description="Win a long game on Toy House on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.ToyHouse_Turbo')
    achievements(38)=(title="Six Paths of Peril",description="Win a long game on 6Pointer on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.SixPointer_Turbo')
    achievements(39)=(title="Fabric Bleach",description="Win a long game on Yarn Box on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.YarnBox_Turbo')
    achievements(40)=(title="Nano Cube Compression",description="Win a long game on Cubical Chamber on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.CubicalChamber_Turbo')
    achievements(41)=(title="Chemical Plant Zone [Extended]",description="Win a long game on Vagrant on KFTurbo+ difficulty",image=Texture'KFTurbo.Achievement.Vagrant_Turbo')
}