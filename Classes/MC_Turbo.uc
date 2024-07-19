class MC_Turbo extends MC_DEF;

//NOTE: THESE ENUMS MUST LINE UP WITH THE MC_TURBO MONSTERCLASSES LIST.
enum EMonster
{
     Clot,
     Crawler,
     Gorefast,
     Stalker,
     Scrake,
     Fleshpound,
     Bloat,
     Siren,
     Husk,

     //Some event zeds we want to use.
     Scrake_Halloween,
     Fleshpound_Halloween,
     Bloat_Halloween,
     Siren_Halloween,

     //"Custom" zeds.
     Crawler_Jumper,
     Gorefast_Classy,
     Gorefast_Assassin,
     Bloat_Fathead,
     Siren_Caroler,
};

defaultproperties
{
     //NOTE: THESE CLASSES MUST LINE UP WITH THE EMONSTER ENUM LIST.
     //Standard Monsters
     MonsterClasses(0)=(MClassName="KFTurbo.P_Clot_STA")
     MonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_STA")
     MonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_STA")
     MonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_STA")
     MonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_STA")
     MonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_STA")
     MonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_STA")
     MonsterClasses(7)=(MClassName="KFTurbo.P_Siren_STA")
     MonsterClasses(8)=(MClassName="KFTurbo.P_Husk_STA")

     //Event Monsters
     MonsterClasses(9)=(MClassName="KFTurbo.P_Scrake_HAL",Mid="J")
     MonsterClasses(10)=(MClassName="KFTurbo.P_Fleshpound_HAL",Mid="K")
     MonsterClasses(11)=(MClassName="KFTurbo.P_Bloat_HAL",Mid="L")
     MonsterClasses(12)=(MClassName="KFTurbo.P_Siren_HAL",Mid="M")

     //Special Monsters
     MonsterClasses(13)=(MClassName="KFTurbo.P_Crawler_Jumper",Mid="N")
     MonsterClasses(14)=(MClassName="KFTurbo.P_Gorefast_Classy",Mid="O")
     MonsterClasses(15)=(MClassName="KFTurbo.P_Gorefast_Assassin",Mid="P")
     MonsterClasses(16)=(MClassName="KFTurbo.P_Bloat_Fathead",Mid="Q")
     MonsterClasses(17)=(MClassName="KFTurbo.P_Siren_Caroler",Mid="R")


     //Clear all these lists out - they won't be used anyways.
     StandardMonsterClasses=()
     
     ShortSpecialSquads=()
     NormalSpecialSquads=()
     LongSpecialSquads=()
     
     FinalSquads=()
     
     FallbackMonsterClass="KFTurbo.P_Stalker_STA"
     EndGameBossClass="KFTurbo.P_ZombieBoss_STA"
}
