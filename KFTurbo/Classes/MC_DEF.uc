//Killing Floor Turbo MC_DEF
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MC_DEF extends KFMonstersCollection;

defaultproperties
{
     MonsterClasses(0)=(MClassName="KFTurbo.P_Clot_STA")
     MonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_STA")
     MonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_STA")
     MonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_STA")
     MonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_STA")
     MonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_STA")
     MonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_STA")
     MonsterClasses(7)=(MClassName="KFTurbo.P_Siren_STA")
     MonsterClasses(8)=(MClassName="KFTurbo.P_Husk_STA")
     MonsterClasses(9)=(MClassName="KFTurbo.P_ZombieBoss_STA",Mid="J")
     StandardMonsterClasses(0)=(MClassName="KFTurbo.P_Clot_STA")
     StandardMonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_STA")
     StandardMonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_STA")
     StandardMonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_STA")
     StandardMonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_STA")
     StandardMonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_STA")
     StandardMonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_STA")
     StandardMonsterClasses(7)=(MClassName="KFTurbo.P_Siren_STA")
     StandardMonsterClasses(8)=(MClassName="KFTurbo.P_Husk_STA")
     ShortSpecialSquads(2)=(ZedClass=("KFTurbo.P_Crawler_STA","KFTurbo.P_Gorefast_STA","KFTurbo.P_Stalker_STA","KFTurbo.P_Scrake_STA"))
     ShortSpecialSquads(3)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_Fleshpound_STA"))
     NormalSpecialSquads(3)=(ZedClass=("KFTurbo.P_Crawler_STA","KFTurbo.P_Gorefast_STA","KFTurbo.P_Stalker_STA","KFTurbo.P_Scrake_STA"))
     NormalSpecialSquads(4)=(ZedClass=("KFTurbo.P_Fleshpound_STA"))
     NormalSpecialSquads(5)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_Fleshpound_STA"))
     NormalSpecialSquads(6)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_Fleshpound_STA"))
     LongSpecialSquads(4)=(ZedClass=("KFTurbo.P_Crawler_STA","KFTurbo.P_Gorefast_STA","KFTurbo.P_Stalker_STA","KFTurbo.P_Scrake_STA"))
     LongSpecialSquads(6)=(ZedClass=("KFTurbo.P_Fleshpound_STA"))
     LongSpecialSquads(7)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_Fleshpound_STA"))
     LongSpecialSquads(8)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_Scrake_STA","KFTurbo.P_Fleshpound_STA"))
     LongSpecialSquads(9)=(ZedClass=("KFTurbo.P_Bloat_STA","KFTurbo.P_Siren_STA","KFTurbo.P_Scrake_STA","KFTurbo.P_Fleshpound_STA"))
     FinalSquads(0)=(ZedClass=("KFTurbo.P_Clot_STA"))
     FinalSquads(1)=(ZedClass=("KFTurbo.P_Clot_STA","KFTurbo.P_Crawler_STA"))
     FinalSquads(2)=(ZedClass=("KFTurbo.P_Clot_STA","KFTurbo.P_Stalker_STA","KFTurbo.P_Crawler_STA"))
     FallbackMonsterClass="KFTurbo.P_Stalker_STA"
     EndGameBossClass="KFTurbo.P_ZombieBoss_STA"
}
