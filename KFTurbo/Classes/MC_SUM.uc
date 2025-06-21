//Killing Floor Turbo MC_SUM
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MC_SUM extends KFMonstersCollection;

defaultproperties
{
     MonsterClasses(0)=(MClassName="KFTurbo.P_Clot_SUM")
     MonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_SUM")
     MonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_SUM")
     MonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_SUM")
     MonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_SUM")
     MonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_SUM")
     MonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_SUM")
     MonsterClasses(7)=(MClassName="KFTurbo.P_Siren_SUM")
     MonsterClasses(8)=(MClassName="KFTurbo.P_Husk_SUM")
     MonsterClasses(9)=(MClassName="KFTurbo.P_ZombieBoss_SUM",Mid="J")
     StandardMonsterClasses(0)=(MClassName="KFTurbo.P_Clot_SUM")
     StandardMonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_SUM")
     StandardMonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_SUM")
     StandardMonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_SUM")
     StandardMonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_SUM")
     StandardMonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_SUM")
     StandardMonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_SUM")
     StandardMonsterClasses(7)=(MClassName="KFTurbo.P_Siren_SUM")
     StandardMonsterClasses(8)=(MClassName="KFTurbo.P_Husk_SUM")
     ShortSpecialSquads(2)=(ZedClass=("KFTurbo.P_Crawler_SUM","KFTurbo.P_Gorefast_SUM","KFTurbo.P_Stalker_SUM","KFTurbo.P_Scrake_SUM"))
     ShortSpecialSquads(3)=(ZedClass=("KFTurbo.P_Bloat_SUM","KFTurbo.P_Siren_SUM","KFTurbo.P_Fleshpound_SUM"))
     NormalSpecialSquads(3)=(ZedClass=("KFTurbo.P_Crawler_SUM","KFTurbo.P_Gorefast_SUM","KFTurbo.P_Stalker_SUM","KFTurbo.P_Scrake_SUM"))
     NormalSpecialSquads(4)=(ZedClass=("KFTurbo.P_Fleshpound_SUM"))
     NormalSpecialSquads(5)=(ZedClass=("KFTurbo.P_Bloat_SUM","KFTurbo.P_Siren_SUM","KFTurbo.P_Fleshpound_SUM"))
     NormalSpecialSquads(6)=(ZedClass=("KFTurbo.P_Bloat_SUM","KFTurbo.P_Siren_SUM","KFTurbo.P_Fleshpound_SUM"))
     LongSpecialSquads(4)=(ZedClass=("KFTurbo.P_Crawler_SUM","KFTurbo.P_Gorefast_SUM","KFTurbo.P_Stalker_SUM","KFTurbo.P_Scrake_SUM"))
     LongSpecialSquads(6)=(ZedClass=("KFTurbo.P_Fleshpound_SUM"))
     LongSpecialSquads(7)=(ZedClass=("KFTurbo.P_Bloat_SUM","KFTurbo.P_Siren_SUM","KFTurbo.P_Fleshpound_SUM"))
     LongSpecialSquads(8)=(ZedClass=("KFTurbo.P_Bloat_SUM","KFTurbo.P_Siren_SUM","KFTurbo.P_Scrake_SUM","KFTurbo.P_Fleshpound_SUM"))
     LongSpecialSquads(9)=(ZedClass=("KFTurbo.P_Bloat_SUM","KFTurbo.P_Siren_SUM","KFTurbo.P_Scrake_SUM","KFTurbo.P_Fleshpound_SUM"))
     FinalSquads(0)=(ZedClass=("KFTurbo.P_Clot_SUM"))
     FinalSquads(1)=(ZedClass=("KFTurbo.P_Clot_SUM","KFTurbo.P_Crawler_SUM"))
     FinalSquads(2)=(ZedClass=("KFTurbo.P_Clot_SUM","KFTurbo.P_Stalker_SUM","KFTurbo.P_Crawler_SUM"))
     FallbackMonsterClass="KFTurbo.P_Stalker_SUM"
     EndGameBossClass="KFTurbo.P_ZombieBoss_SUM"
}
