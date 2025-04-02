//Killing Floor Turbo TurboAchievementPackMapBase
//Base class for map achievement packs.
//Works very similarly to etsai (Scary Ghost)'s MapAchievementsBase,
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboAchievementPackMapBase extends TurboAchievementPack;

#exec OBJ LOAD FILE=KillingFloor2HUD.utx

enum EBaseGameMap
{
    WestLondon, //0
    Manor,
    Farm,
    Offices,
    BioticsLab,
    Foundry,    //5
    Bedlam,
    Wyre,
    Biohazard,
    Crash,
    Departed,   //10
    FilthsCross,
    HospitalHorrors,
    Icebreaker,
    MountainPass,
    Suburbia,   //15
    Waterworks,
    EvilSantasLair,
    Aperture,
    AbusementPark,
    IceCave,    //20
    Hellride,
    HillbillyHorror,
    Moonbase,
    Steamland,
    FrightYard, //25
    Hell,
    Forgotton,
    SirensBelch,
    Stronghold,
    Transit,    //30
    Clandestine,
    ThrillsChills
};

struct MapIndex
{
    var string Map;
    var int Index;
};

//The same as MapAchievementsBase::mapIndexes. This is responsible for getting the achievement index for a given map name.
var protected array<MapIndex> MapList;

var int RoundCount;
var bool bParticipatedOnBossWave;

defaultproperties
{
    ID=""

    MapList(0)=(Map="kf-abusementpark",Index=19)
    MapList(1)=(Map="kf-aperture",Index=18)
    MapList(2)=(Map="kf-bedlam",Index=6)
    MapList(3)=(Map="kf-biohazard",Index=8)
    MapList(4)=(Map="kf-bioticslab",Index=4)
    MapList(5)=(Map="kf-clandestine",Index=31)
    MapList(6)=(Map="kf-crash",Index=9)
    MapList(7)=(Map="kf-departed",Index=10)
    MapList(8)=(Map="kf-evilsantaslair",Index=17)
    MapList(9)=(Map="kf-farm",Index=2)
    MapList(10)=(Map="kf-filthscross",Index=11)
    MapList(11)=(Map="kf-foundry",Index=5)
    MapList(12)=(Map="kf-forgotten",Index=27)
    MapList(13)=(Map="kf-frightyard",Index=25)
    MapList(14)=(Map="kf-hell",Index=26)
    MapList(15)=(Map="kf-hellride",Index=21)
    MapList(16)=(Map="kf-hillbillyhorror",Index=22)
    MapList(17)=(Map="kf-hospitalhorrors",Index=12)
    MapList(18)=(Map="kf-icebreaker",Index=13)
    MapList(19)=(Map="kf-icecave",Index=20)
    MapList(20)=(Map="kf-manor",Index=1)
    MapList(21)=(Map="kf-moonbase",Index=23)
    MapList(22)=(Map="kf-mountainpass",Index=14)
    MapList(23)=(Map="kf-offices",Index=3)
    MapList(24)=(Map="kf-sirensbelch",Index=28)
    MapList(25)=(Map="kf-steamland",Index=24)
    MapList(26)=(Map="kf-stronghold",Index=29)
    MapList(27)=(Map="kf-suburbia",Index=15)
    MapList(28)=(Map="kf-thrillschills",Index=32)
    MapList(29)=(Map="kf-transit",Index=30)
    MapList(30)=(Map="kf-waterworks",Index=16)
    MapList(31)=(Map="kf-westlondon",Index=0)
    MapList(32)=(Map="kf-wyre",Index=7)

    /*
    Begin Object Class=TurboAchievementFlag Name=WestLondon
        Title="Hellish Pub Crawl"
        Description="Win a medium or long game on West London on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_65'
    End Object
    AchievementList(0)=TurboAchievementFlag'WestLondon'

    Begin Object Class=TurboAchievementFlag Name=Manor
        Title="Demonic King of the Manor"
        Description="Win a medium or long game on Manor on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_66'
    End Object
    AchievementList(1)=TurboAchievementFlag'Manor'
    
    Begin Object Class=TurboAchievementFlag Name=Farm
        Title="Demon Farmer"
        Description="Win a medium or long game on Farm on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_67'
    End Object
    AchievementList(2)=TurboAchievementFlag'Farm'

    Begin Object Class=TurboAchievementFlag Name=Offices
        Title="Boss from Hell"
        Description="Win a medium or long game on Offices on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_68'
    End Object
    AchievementList(3)=TurboAchievementFlag'Offices'

    Begin Object Class=TurboAchievementFlag Name=BioticsLab
        Title="Scientist from Hell"
        Description="Win a medium or long game on Biotics Lab on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_69'
    End Object
    AchievementList(4)=TurboAchievementFlag'BioticsLab'
    
    Begin Object Class=TurboAchievementFlag Name=Foundry
        Title="Diablo Steel Man"
        Description="Win a medium or long game on Foundry on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_70'
    End Object
    AchievementList(5)=TurboAchievementFlag'Foundry'

    Begin Object Class=TurboAchievementFlag Name=Bedlam
        Title="Commit-ed for life"
        Description="Win a medium or long game on Bedlam on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_71'
    End Object
    AchievementList(6)=TurboAchievementFlag'Bedlam'

    Begin Object Class=TurboAchievementFlag Name=Wyre
        Title="Wolf King of the Dark Forrest"
        Description="Win a medium or long game on Wyre on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_72'
    End Object
    AchievementList(7)=TurboAchievementFlag'Wyre'

    Begin Object Class=TurboAchievementFlag Name=Biohazard
        Title="Wasted"
        Description="Win a medium or long game on Biohazard on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_76'
    End Object
    AchievementList(8)=TurboAchievementFlag'Biohazard'

    Begin Object Class=TurboAchievementFlag Name=Crash
        Title="Warehouse Manager"
        Description="Win a medium or long game on Crash on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_80'
    End Object
    AchievementList(9)=TurboAchievementFlag'Crash'
    
    Begin Object Class=TurboAchievementFlag Name=Departed
        Title="Dear Departed"
        Description="Win a medium or long game on Departed on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_84'
    End Object
    AchievementList(10)=TurboAchievementFlag'Departed'

    Begin Object Class=TurboAchievementFlag Name=FilthsCross
        Title="Pile Up"
        Description="Win a medium or long game on Filth's Cross on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_88'
    End Object
    AchievementList(11)=TurboAchievementFlag'FilthsCross'

    Begin Object Class=TurboAchievementFlag Name=HospitalHorrors
        Title="Not Dead Yet!"
        Description="Win a medium or long game on Hospital Horrors on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_92'
    End Object
    AchievementList(12)=TurboAchievementFlag'HospitalHorrors'

    Begin Object Class=TurboAchievementFlag Name=Icebreaker
        Title="Comet"
        Description="Win a medium or long game on Icebreaker on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_96'
    End Object
    AchievementList(13)=TurboAchievementFlag'Icebreaker'

    Begin Object Class=TurboAchievementFlag Name=MountainPass
        Title="Park Ranger"
        Description="Win a medium or long game on Mountain Pass on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_100'
    End Object
    AchievementList(14)=TurboAchievementFlag'MountainPass'

    Begin Object Class=TurboAchievementFlag Name=Suburbia
        Title="SWAT"
        Description="Win a medium or long game on Suburbia on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_104'
    End Object
    AchievementList(15)=TurboAchievementFlag'Suburbia'

    Begin Object Class=TurboAchievementFlag Name=Waterworks
        Title="Floodgate To Hell"
        Description="Win a medium or long game on Waterworks on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_108'
    End Object
    AchievementList(16)=TurboAchievementFlag'Waterworks'

    Begin Object Class=TurboAchievementFlag Name=EvilSantasLair
        Title="Grandmas got Eaten by a Reindeer"
        Description="Win a medium or long game on Santa's Evil Lair on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_117'
    End Object
    AchievementList(17)=TurboAchievementFlag'EvilSantasLair'

    Begin Object Class=TurboAchievementFlag Name=Aperture
        Title="I'm Making a Note Here, Huge Success"
        Description="Win a medium or long game on Aperture on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_136'
    End Object
    AchievementList(18)=TurboAchievementFlag'Aperture'

    Begin Object Class=TurboAchievementFlag Name=AbusementPark
        Title="On Top of the Big Top"
        Description="Win a medium or long game on Abusement Park on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_141'
    End Object
    AchievementList(19)=TurboAchievementFlag'AbusementPark'

    Begin Object Class=TurboAchievementFlag Name=IceCave
        Title="Anti Freeze"
        Description="Win a medium or long game on Ice Cave on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_174'
    End Object
    AchievementList(20)=TurboAchievementFlag'IceCave'

    Begin Object Class=TurboAchievementFlag Name=Hellride
        Title="Devil's Co-pilot"
        Description="Win a medium or long game on Hellride on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_184'
    End Object
    AchievementList(21)=TurboAchievementFlag'Hellride'

    Begin Object Class=TurboAchievementFlag Name=HillbillyHorror
        Title="First Cousins"
        Description="Win a medium or long game on Hillbilly Horror on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_192'
    End Object
    AchievementList(22)=TurboAchievementFlag'HillbillyHorror'
    
    Begin Object Class=TurboAchievementFlag Name=Moonbase
        Title="One Giant Leap (Back) for Mankind"
        Description="Win a medium or long game on Moonbase on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_207'
    End Object
    AchievementList(23)=TurboAchievementFlag'Moonbase'

    Begin Object Class=TurboAchievementFlag Name=Steamland
        Title="Advanced Omega Wave Resonance Explorer"
        Description="Win a medium or long game on Steamland on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_212'
    End Object
    AchievementList(24)=TurboAchievementFlag'Steamland'

    Begin Object Class=TurboAchievementFlag Name=FrightYard
        Title="Wharfinger"
        Description="Win a medium or long game on Fright Yard on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_231'
    End Object
    AchievementList(25)=TurboAchievementFlag'FrightYard'

    Begin Object Class=TurboAchievementFlag Name=Hell
        Title="Lucifer"
        Description="Win a medium or long game on Hell on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_246'
    End Object
    AchievementList(26)=TurboAchievementFlag'Hell'

    Begin Object Class=TurboAchievementFlag Name=Forgotton
        Title="Dementia"
        Description="Win a medium or long game on Forgotton on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_250'
    End Object
    AchievementList(27)=TurboAchievementFlag'Forgotton'
    
    Begin Object Class=TurboAchievementFlag Name=SirensBelch
        Title="Trappist Monk"
        Description="Win a medium or long game on Siren's Belch on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_252'
    End Object
    AchievementList(28)=TurboAchievementFlag'SirensBelch'

    Begin Object Class=TurboAchievementFlag Name=Stronghold
        Title="King"
        Description="Win a medium or long game on Stronghold on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_256'
    End Object
    AchievementList(29)=TurboAchievementFlag'Stronghold'

    Begin Object Class=TurboAchievementFlag Name=Transit
        Title="First Class"
        Description="Win a medium or long game on Transit on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_260'
    End Object
    AchievementList(30)=TurboAchievementFlag'Transit'

    Begin Object Class=TurboAchievementFlag Name=Clandestine
        Title="Hangover from Hell"
        Description="Win a medium or long game on Clandestine on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_278'
    End Object
    AchievementList(31)=TurboAchievementFlag'Clandestine'

    Begin Object Class=TurboAchievementFlag Name=ThrillsChills
        Title="Hollow of Horror"
        Description="Win a medium or long game on ThrillsChills on Hell on Earth difficulty"
        Icon=Texture'KillingFloor2HUD.Achievements.Achievement_283'
    End Object
    AchievementList(32)=TurboAchievementFlag'ThrillsChills'
    */
}