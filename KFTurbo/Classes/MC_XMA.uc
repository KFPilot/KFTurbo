//Killing Floor Turbo MC_XMA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MC_XMA extends KFMonstersCollection;

defaultproperties
{
     MonsterClasses(0)=(MClassName="KFTurbo.P_Clot_XMA")
     MonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_XMA")
     MonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_XMA")
     MonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_XMA")
     MonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_XMA")
     MonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_XMA")
     MonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_XMA")
     MonsterClasses(7)=(MClassName="KFTurbo.P_Siren_XMA")
     MonsterClasses(8)=(MClassName="KFTurbo.P_Husk_XMA")
     MonsterClasses(9)=(MClassName="KFTurbo.P_ZombieBoss_XMAS",Mid="J")
     StandardMonsterClasses(0)=(MClassName="KFTurbo.P_Clot_XMA")
     StandardMonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_XMA")
     StandardMonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_XMA")
     StandardMonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_XMA")
     StandardMonsterClasses(4)=(MClassName="KFTurbo.P_SC_XMA")
     StandardMonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_XMA")
     StandardMonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_XMA")
     StandardMonsterClasses(7)=(MClassName="KFTurbo.P_Siren_XMA")
     StandardMonsterClasses(8)=(MClassName="KFTurbo.P_Husk_XMA")
     ShortSpecialSquads(2)=(ZedClass=("KFTurbo.P_Crawler_XMA","KFTurbo.P_Gorefast_XMA","KFTurbo.P_Stalker_XMA","KFTurbo.P_SC_XMA"))
     ShortSpecialSquads(3)=(ZedClass=("KFTurbo.P_Bloat_XMA","KFTurbo.P_Siren_XMA","KFTurbo.P_Fleshpound_XMA"))
     NormalSpecialSquads(3)=(ZedClass=("KFTurbo.P_Crawler_XMA","KFTurbo.P_Gorefast_XMA","KFTurbo.P_Stalker_XMA","KFTurbo.P_SC_XMA"))
     NormalSpecialSquads(4)=(ZedClass=("KFTurbo.P_Fleshpound_XMA"))
     NormalSpecialSquads(5)=(ZedClass=("KFTurbo.P_Bloat_XMA","KFTurbo.P_Siren_XMA","KFTurbo.P_Fleshpound_XMA"))
     NormalSpecialSquads(6)=(ZedClass=("KFTurbo.P_Bloat_XMA","KFTurbo.P_Siren_XMA","KFTurbo.P_Fleshpound_XMA"))
     LongSpecialSquads(4)=(ZedClass=("KFTurbo.P_Crawler_XMA","KFTurbo.P_Gorefast_XMA","KFTurbo.P_Stalker_XMA","P_SC_XMA"))
     LongSpecialSquads(6)=(ZedClass=("KFTurbo.P_Fleshpound_XMA"))
     LongSpecialSquads(7)=(ZedClass=("KFTurbo.P_Bloat_XMA","KFTurbo.P_Siren_XMA","KFTurbo.P_Fleshpound_XMA"))
     LongSpecialSquads(8)=(ZedClass=("KFTurbo.P_Bloat_XMA","KFTurbo.P_Siren_XMA","KFTurbo.P_SC_XMA","KFTurbo.P_Fleshpound_XMA"))
     LongSpecialSquads(9)=(ZedClass=("KFTurbo.P_Bloat_XMA","KFTurbo.P_Siren_XMA","KFTurbo.P_SC_XMA","KFTurbo.P_Fleshpound_XMA"))
     FinalSquads(0)=(ZedClass=("KFTurbo.P_Clot_XMA"))
     FinalSquads(1)=(ZedClass=("KFTurbo.P_Clot_XMA","KFTurbo.P_Crawler_XMA"))
     FinalSquads(2)=(ZedClass=("KFTurbo.P_Clot_XMA","KFTurbo.P_Stalker_XMA","KFTurbo.P_Crawler_XMA"))
     FallbackMonsterClass="KFTurbo.P_Stalker_XMA"
     EndGameBossClass="KFTurbo.P_ZombieBoss_XMAS"
}
