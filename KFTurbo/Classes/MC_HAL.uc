//Killing Floor Turbo MC_HAL
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MC_HAL extends KFMonstersCollection;

defaultproperties
{
     MonsterClasses(0)=(MClassName="KFTurbo.P_Clot_HAL")
     MonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_HAL")
     MonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_HAL")
     MonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_HAL")
     MonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_HAL")
     MonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_HAL")
     MonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_HAL")
     MonsterClasses(7)=(MClassName="KFTurbo.P_Siren_HAL")
     MonsterClasses(8)=(MClassName="KFTurbo.P_Husk_HAL")
     MonsterClasses(9)=(MClassName="KFTurbo.P_ZombieBoss_HAL",Mid="J")
     StandardMonsterClasses(0)=(MClassName="KFTurbo.P_Clot_HAL")
     StandardMonsterClasses(1)=(MClassName="KFTurbo.P_Crawler_HAL")
     StandardMonsterClasses(2)=(MClassName="KFTurbo.P_Gorefast_HAL")
     StandardMonsterClasses(3)=(MClassName="KFTurbo.P_Stalker_HAL")
     StandardMonsterClasses(4)=(MClassName="KFTurbo.P_Scrake_HAL")
     StandardMonsterClasses(5)=(MClassName="KFTurbo.P_Fleshpound_HAL")
     StandardMonsterClasses(6)=(MClassName="KFTurbo.P_Bloat_HAL")
     StandardMonsterClasses(7)=(MClassName="KFTurbo.P_Siren_HAL")
     StandardMonsterClasses(8)=(MClassName="KFTurbo.P_Husk_HAL")
     ShortSpecialSquads(2)=(ZedClass=("KFTurbo.P_Crawler_HAL","KFTurbo.P_Gorefast_HAL","KFTurbo.P_Stalker_HAL","KFTurbo.P_Scrake_HAL"))
     ShortSpecialSquads(3)=(ZedClass=("KFTurbo.P_Bloat_HAL","KFTurbo.P_Siren_HAL","KFTurbo.P_Fleshpound_HAL"))
     NormalSpecialSquads(3)=(ZedClass=("KFTurbo.P_Crawler_HAL","KFTurbo.P_Gorefast_HAL","KFTurbo.P_Stalker_HAL","KFTurbo.P_Scrake_HAL"))
     NormalSpecialSquads(4)=(ZedClass=("KFTurbo.P_Fleshpound_HAL"))
     NormalSpecialSquads(5)=(ZedClass=("KFTurbo.P_Bloat_HAL","KFTurbo.P_Siren_HAL","KFTurbo.P_Fleshpound_HAL"))
     NormalSpecialSquads(6)=(ZedClass=("KFTurbo.P_Bloat_HAL","KFTurbo.P_Siren_HAL","KFTurbo.P_Fleshpound_HAL"))
     LongSpecialSquads(4)=(ZedClass=("KFTurbo.P_Crawler_HAL","KFTurbo.P_Gorefast_HAL","KFTurbo.P_Stalker_HAL","KFTurbo.P_Scrake_HAL"))
     LongSpecialSquads(6)=(ZedClass=("KFTurbo.P_Fleshpound_HAL"))
     LongSpecialSquads(7)=(ZedClass=("KFTurbo.P_Bloat_HAL","KFTurbo.P_Siren_HAL","KFTurbo.P_Fleshpound_HAL"))
     LongSpecialSquads(8)=(ZedClass=("KFTurbo.P_Bloat_HAL","KFTurbo.P_Siren_HAL","KFTurbo.P_Scrake_HAL","KFTurbo.P_Fleshpound_HAL"))
     LongSpecialSquads(9)=(ZedClass=("KFTurbo.P_Bloat_HAL","KFTurbo.P_Siren_HAL","KFTurbo.P_Scrake_HAL","KFTurbo.P_Fleshpound_HAL"))
     FinalSquads(0)=(ZedClass=("KFTurbo.P_Clot_HAL"))
     FinalSquads(1)=(ZedClass=("KFTurbo.P_Clot_HAL","KFTurbo.P_Crawler_HAL"))
     FinalSquads(2)=(ZedClass=("KFTurbo.P_Clot_HAL","KFTurbo.P_Stalker_HAL","KFTurbo.P_Crawler_HAL"))
     FallbackMonsterClass="KFTurbo.P_Stalker_HAL"
     EndGameBossClass="KFTurbo.P_ZombieBoss_HAL"
}
