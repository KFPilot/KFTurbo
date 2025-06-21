//Killing Floor Turbo TurboMapPackHoE
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapPackHoE extends StockMapsHellOnEarth;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (ownerController == None)
    {
        ownerController = KFPlayerController(Owner);
    }
}

event matchEnd(string mapname, float difficulty, int length, byte result, int waveNum)
{
    if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(self))
    {
        return;
    }

    Super.matchEnd(mapname, difficulty, length, result, waveNum);
}

defaultproperties
{
    packName="Map Achievements"
    requiredDifficulty=7.0

    mapIndexes=()
    mapIndexes(0)=(mapname="kf-abusementpark",achvIndex=19)
    mapIndexes(1)=(mapname="kf-aperture",achvIndex=18)
    mapIndexes(2)=(mapname="kf-bedlam",achvIndex=6)
    mapIndexes(3)=(mapname="kf-biohazard",achvIndex=8)
    mapIndexes(4)=(mapname="kf-bioticslab",achvIndex=4)
    mapIndexes(5)=(mapname="kf-clandestine",achvIndex=34)
    mapIndexes(6)=(mapname="kf-crash",achvIndex=9)
    mapIndexes(7)=(mapname="kf-departed",achvIndex=10)
    mapIndexes(8)=(mapname="kf-evilsantaslair",achvIndex=17)
    mapIndexes(9)=(mapname="kf-farm",achvIndex=2)
    mapIndexes(10)=(mapname="kf-filthscross",achvIndex=11)
    mapIndexes(11)=(mapname="kf-foundry",achvIndex=5)
    mapIndexes(12)=(mapname="kf-forgotten",achvIndex=29)
    mapIndexes(13)=(mapname="kf-frightyard",achvIndex=26)
    mapIndexes(14)=(mapname="kf-hell",achvIndex=28)
    mapIndexes(15)=(mapname="kf-hellride",achvIndex=21)
    mapIndexes(16)=(mapname="kf-hillbillyhorror",achvIndex=22)
    mapIndexes(17)=(mapname="kf-hospitalhorrors",achvIndex=12)
    mapIndexes(18)=(mapname="kf-icebreaker",achvIndex=13)
    mapIndexes(19)=(mapname="kf-icecave",achvIndex=20)
    mapIndexes(20)=(mapname="kf-manor",achvIndex=1)
    mapIndexes(21)=(mapname="kf-moonbase",achvIndex=23)
    mapIndexes(22)=(mapname="kf-mountainpass",achvIndex=14)
    mapIndexes(23)=(mapname="kf-offices",achvIndex=3)
    mapIndexes(24)=(mapname="kf-sirensbelch",achvIndex=30)
    mapIndexes(25)=(mapname="kf-steamland",achvIndex=24)
    mapIndexes(26)=(mapname="kf-stronghold",achvIndex=31)
    mapIndexes(27)=(mapname="kf-suburbia",achvIndex=15)
    mapIndexes(28)=(mapname="kf-thrillschills",achvIndex=35)
    mapIndexes(29)=(mapname="kf-transit",achvIndex=32)
    mapIndexes(30)=(mapname="kf-waterworks",achvIndex=16)
    mapIndexes(31)=(mapname="kf-westlondon",achvIndex=0)
    mapIndexes(32)=(mapname="kf-wyre",achvIndex=7)    
    mapIndexes(33)=(mapname="kfo-steamland",achvIndex=25)
    mapIndexes(34)=(mapname="kfo-frightyard",achvIndex=27)
    mapIndexes(35)=(mapname="kfo-transit",achvIndex=33)

    //New maps that achievements can be granted for.
    mapIndexes(36)=(mapname="kf-northernsolitude",achvIndex=36)
    mapIndexes(37)=(mapname="kf-6pointerv2",achvIndex=37)
    mapIndexes(38)=(mapname="kf-cubicalchamber",achvIndex=38)
    mapIndexes(39)=(mapname="kf-vagrant-s",achvIndex=39)

    //Modified maps that should still reward the base map achievement.
    mapIndexes(40)=(mapname="kf-abusementparkwinter-s",achvIndex=19)
    mapIndexes(41)=(mapname="kf-aperture-s",achvIndex=18)
    mapIndexes(42)=(mapname="kf-aperture-lights-out",achvIndex=18)
    mapIndexes(43)=(mapname="kf-biohazard-s",achvIndex=8)
    mapIndexes(44)=(mapname="kf-bioticslab-s",achvIndex=4)
    mapIndexes(45)=(mapname="kf-crash-s",achvIndex=9)
    mapIndexes(46)=(mapname="kf-departed-s",achvIndex=10)
    mapIndexes(47)=(mapname="kf-departedwinter-s",achvIndex=10)
    mapIndexes(48)=(mapname="kf-evilsantaslair-s",achvIndex=17)
    mapIndexes(49)=(mapname="kf-farm-s",achvIndex=2)
    mapIndexes(50)=(mapname="kf-filthscross-s",achvIndex=11)
    mapIndexes(51)=(mapname="kf-foundry-s",achvIndex=5)
    mapIndexes(52)=(mapname="kf-forgotten-s",achvIndex=29)
    mapIndexes(53)=(mapname="kf-frightyard-s",achvIndex=26)
    mapIndexes(54)=(mapname="kf-hellride-s",achvIndex=21)
    mapIndexes(55)=(mapname="kf-hospitalhorrors-s",achvIndex=12)
    mapIndexes(56)=(mapname="kf-icebreaker-s",achvIndex=13)
    mapIndexes(57)=(mapname="kf-northernsolitude-s",achvIndex=36)
    mapIndexes(58)=(mapname="kf-mountainpass-s",achvIndex=14)
    mapIndexes(59)=(mapname="kf-suburbia-s",achvIndex=15)
    mapIndexes(60)=(mapname="kf-waterworks-s",achvIndex=16)
    mapIndexes(61)=(mapname="kf-westlondon-s",achvIndex=0)
    mapIndexes(62)=(mapname="kf-westlondonwinter-s",achvIndex=0)

    achievements=()
    achievements(0)=(title="Hellish Pub Crawl",description="Win a long game on West London (or any variant) on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_65')
    achievements(1)=(title="Demonic King of the Manor",description="Win a long game on Manor on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_66')
    achievements(2)=(title="Demon Farmer",description="Win a long game on Farm on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_67')
    achievements(3)=(title="Boss from Hell",description="Win a long game on Offices on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_68')
    achievements(4)=(title="Scientist from Hell",description="Win a long game on Biotics Lab on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_69')
    achievements(5)=(title="Diablo Steel Man",description="Win a long game on Foundry on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_70')
    achievements(6)=(title="Commit-ed for life",description="Win a long game on Bedlam on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_71')
    achievements(7)=(title="Wolf King of the Dark Forrest",description="Win a long game on Wyre on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_72')
    achievements(8)=(title="Wasted",description="Win a long game on Biohazard on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_76')
    achievements(9)=(title="Warehouse Manager",description="Win a long game on Crash on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_80')
    achievements(10)=(title="Dear Departed",description="Win a long game on Departed (or any variant) on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_84')
    achievements(11)=(title="Pile Up",description="Win a long game on Filth's Cross on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_88')
    achievements(12)=(title="Not Dead Yet!",description="Win a long game on Hospital Horrors on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_92')
    achievements(13)=(title="Comet",description="Win a long game on Icebreaker (or any variant) on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_96')
    achievements(14)=(title="Park Ranger",description="Win a long game on Mountain Pass on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_100')
    achievements(15)=(title="SWAT",description="Win a long game on Suburbia on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_104')
    achievements(16)=(title="Floodgate To Hell",description="Win a long game on Waterworks on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_108')
    achievements(17)=(title="Grandmas got Eaten by a Reindeer",description="Win a long game on Santa's Evil Lair on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_117')
    achievements(18)=(title="I'm Making a Note Here, Huge Success",description="Win a long game on Aperture (or any variant) on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_136')
    achievements(19)=(title="On Top of the Big Top",description="Win a long game on Abusement Park (or any variant) on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_141')
    achievements(20)=(title="Anti Freeze",description="Win a long game on Ice Cave on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_174')
    achievements(21)=(title="Devil's Co-pilot",description="Win a long game on Hellride on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_184')
    achievements(22)=(title="First Cousins",description="Win a long game on Hillbilly Horror on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_192')
    achievements(23)=(title="One Giant Leap (Back) for Mankind",description="Win a long game on Moonbase on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_207')
    achievements(24)=(title="Advanced Omega Wave Resonance Explorer",description="Win a long game on Steamland on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_212')
    achievements(25)=(title="Tachyon Cytoneutralization Explorer",description="Win Steamland in Objective Mode on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_216')
    achievements(26)=(title="Wharfinger",description="Win a long game on Fright Yard on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_231')
    achievements(27)=(title="Shipping Magnate",description="Win Fright Yard in Objective Mode on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_235')
    achievements(28)=(title="Lucifer",description="Win a long game on Hell on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_246')
    achievements(29)=(title="Dementia",description="Win a long game on Forgotten on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_250')
    achievements(30)=(title="Trappist Monk",description="Win a long game on Siren's Belch on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_252')
    achievements(31)=(title="King",description="Win a long game on Stronghold on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_256')
    achievements(32)=(title="First Class",description="Win a long game on Transit on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_260')
    achievements(33)=(title="Moved to Paris!",description="Win Transit in Objective Mode on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_264')
    achievements(34)=(title="Hangover from Hell",description="Win a long game on Clandestine on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_278')
    achievements(35)=(title="Hollow of Horror",description="Win a long game on ThrillsChills on Hell on Earth difficulty",image=Texture'KillingFloor2HUD.Achievements.Achievement_283')
    
    //New Map Achievements.
    achievements(36)=(title="Sheer Cold",description="Win a long game on Northern Solitude on Hell on Earth difficulty",image=Texture'KFTurbo.Achievement.NorthernSolitude_HoE')
    achievements(37)=(title="Six Star Struggle",description="Win a long game on 6Pointer on Hell on Earth difficulty",image=Texture'KFTurbo.Achievement.SixPointer_HoE')
    achievements(38)=(title="Compacted Cube",description="Win a long game on Cubical Chamber on Hell on Earth difficulty",image=Texture'KFTurbo.Achievement.CubicalChamber_HoE')
    achievements(39)=(title="Chemical Plant Zone",description="Win a long game on Vagrant on Hell on Earth difficulty",image=Texture'KFTurbo.Achievement.Vagrant_HoE')
}