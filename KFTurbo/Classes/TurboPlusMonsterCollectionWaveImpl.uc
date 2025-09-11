//Killing Floor Turbo TurboPlusMonsterCollectionWaveImpl
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlusMonsterCollectionWaveImpl extends TurboMonsterCollectionWaveBase;

defaultproperties
{
     //Early-Game Waves:
	Begin Object Class=TurboPlusWaveEarly Name=Wave1
          MaxMonsters=45
          TotalMonsters=60
	     WaveDifficulty=2.35f
	     RegularSequenceSize=20
	     NextSquadSpawnTime=0.2f
	End Object
	WaveList(0)=TurboMonsterWave'Wave1'

	Begin Object Class=TurboPlusWaveEarly Name=Wave2
          MaxMonsters=46
          TotalMonsters=65
	     WaveDifficulty=2.40f
	     RegularSequenceSize=20
	     NextSquadSpawnTime=0.19f
	End Object
	WaveList(1)=TurboMonsterWave'Wave2'

     //Mid-Game Waves:
	Begin Object Class=TurboPlusWaveMidGame Name=Wave3
          MaxMonsters=47
          TotalMonsters=70
          WaveDifficulty=2.45f
	     RegularSequenceSize=20
	     NextSquadSpawnTime=0.18f
	End Object
	WaveList(2)=TurboMonsterWave'Wave3'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave4
          MaxMonsters=48
          TotalMonsters=70
          WaveDifficulty=2.55f
	     RegularSequenceSize=19
	     NextSquadSpawnTime=0.17f
	End Object
	WaveList(3)=TurboMonsterWave'Wave4'

     //End-Game Waves:
     Begin Object Class=TurboPlusWaveLateGame Name=Wave5
          MaxMonsters=49
          TotalMonsters=75
	     WaveDifficulty=2.6f
	     RegularSequenceSize=19
	     NextSquadSpawnTime=0.16f
     End Object
	WaveList(4)=TurboMonsterWave'Wave5'
     
	Begin Object Class=TurboPlusWaveLateGame Name=Wave6
          MaxMonsters=50
          TotalMonsters=75
	     WaveDifficulty=2.65f
	     RegularSequenceSize=19
	     NextSquadSpawnTime=0.15f
	End Object
	WaveList(5)=TurboMonsterWave'Wave6'

	Begin Object Class=TurboPlusWaveChallenge Name=Wave7
          MaxMonsters=50
          TotalMonsters=77
	     RegularSequenceSize=18
	     WaveDifficulty=2.75f
	     NextSquadSpawnTime=0.15f
	End Object
	WaveList(6)=TurboMonsterWave'Wave7'

     //Example definition of boss helper squads, their containing boss squads, then storing them into the BossSquadList.

     //Helper squads for each heal round boss squad.
     Begin Object Class=TurboMonsterSquad Name=HelperSquad0
          Squad(0)=(Monster=Clot,Count=4)
	End Object
     Begin Object Class=TurboMonsterSquad Name=HelperSquad1
          Squad(0)=(Monster=Clot,Count=4)
          Squad(1)=(Monster=Crawler,Count=4)
	End Object
     Begin Object Class=TurboMonsterSquad Name=HelperSquad2
          Squad(0)=(Monster=Clot,Count=4)
          Squad(1)=(Monster=Crawler,Count=4)
          Squad(2)=(Monster=Stalker,Count=4)
	End Object

     //Each heal round's boss squad.
	Begin Object Class=TurboMonsterBossSquad Name=BossSquad0
          Squad=TurboMonsterSquad'KFTurbo.TurboPlusMonsterCollectionWaveImpl.HelperSquad0'
	End Object

	Begin Object Class=TurboMonsterBossSquad Name=BossSquad1
          Squad=TurboMonsterSquad'KFTurbo.TurboPlusMonsterCollectionWaveImpl.HelperSquad1'
          SquadSizePerPlayerCount(0)=12
          SquadSizePerPlayerCount(1)=12
          SquadSizePerPlayerCount(2)=16
          SquadSizePerPlayerCount(3)=16
          SquadSizePerPlayerCount(4)=18
          SquadSizePerPlayerCount(5)=22
	End Object
     
	Begin Object Class=TurboMonsterBossSquad Name=BossSquad2
          Squad=TurboMonsterSquad'KFTurbo.TurboPlusMonsterCollectionWaveImpl.HelperSquad2'
          SquadSizePerPlayerCount(0)=16
          SquadSizePerPlayerCount(1)=16
          SquadSizePerPlayerCount(2)=20
          SquadSizePerPlayerCount(3)=20
          SquadSizePerPlayerCount(4)=22
          SquadSizePerPlayerCount(5)=26
	End Object

     //Storing the boss squads for each heal round.
     BossSquadList(0)=TurboMonsterBossSquad'KFTurbo.TurboPlusMonsterCollectionWaveImpl.BossSquad0'
     BossSquadList(1)=TurboMonsterBossSquad'KFTurbo.TurboPlusMonsterCollectionWaveImpl.BossSquad1'
     BossSquadList(2)=TurboMonsterBossSquad'KFTurbo.TurboPlusMonsterCollectionWaveImpl.BossSquad2'

}