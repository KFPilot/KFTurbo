//Killing Floor Turbo MC_Turbo
//KFTurbo monster collection.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MC_Turbo extends MC_DEF;


defaultproperties
{
     //NOTE: THESE CLASSES MUST LINE UP WITH THE PAWNHELPER EMONSTER ENUM LIST.
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
     MonsterClasses(9)=(MClassName="KFTurbo.P_ZombieBoss_STA")

     //Special Monsters
     MonsterClasses(10)=(MClassName="KFTurbo.P_Crawler_Jumper",Mid="K")
     MonsterClasses(11)=(MClassName="KFTurbo.P_Gorefast_Classy",Mid="L")
     MonsterClasses(12)=(MClassName="KFTurbo.P_Gorefast_Assassin",Mid="M")
     MonsterClasses(13)=(MClassName="KFTurbo.P_Bloat_Fathead",Mid="N")
     MonsterClasses(14)=(MClassName="KFTurbo.P_Siren_Caroler",Mid="O")
     MonsterClasses(15)=(MClassName="KFTurbo.P_Husk_Shotgun",Mid="P")

     //Clear all these lists out - they won't be used anyways.
     StandardMonsterClasses=()
     
     ShortSpecialSquads=()
     NormalSpecialSquads=()
     LongSpecialSquads=()
     
     FinalSquads=()
     
     FallbackMonsterClass="KFTurbo.P_Stalker_STA"
     EndGameBossClass="KFTurbo.P_ZombieBoss_STA"
}
