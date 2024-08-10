class TurboMonsterCollectionWaveImpl extends TurboMonsterCollectionWaveBase;

defaultproperties
{
     //Early Game Waves:
	Begin Object Class=TurboPlusWaveEarly Name=Wave1
          MaxMonsters=45
          TotalMonsters=45
          BeatSize=1
          RegularSequenceSize=10
          MixInWaveMask=1 //Mask will filter out all MixIn squads in the list except for the first one (2^0 = 1).
          NextSquadSpawnTime=2.5f
	End Object
	WaveList(0)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave1'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave2
          MaxMonsters=45
          TotalMonsters=55
          RegularSequenceSize=10
          BeatSize=1
          NextSquadSpawnTime=2.5f
	End Object
	WaveList(1)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave2'

     //Mid Game Waves:
	Begin Object Class=TurboPlusWaveMidGame Name=Wave3
          MaxMonsters=45
          TotalMonsters=62
          RegularSequenceSize=8
          BeatSize=1
          NextSquadSpawnTime=2.5f
	End Object
	WaveList(2)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave3'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave4
          MaxMonsters=50
          TotalMonsters=65
          RegularSequenceSize=8
          BeatSize=2
          NextSquadSpawnTime=2.f
	End Object
	WaveList(3)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave4'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave5
          MaxMonsters=50
          TotalMonsters=67
          RegularSequenceSize=7
          BeatSize=2
          NextSquadSpawnTime=2.f
	End Object
	WaveList(4)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave5'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave6
          MaxMonsters=50
          TotalMonsters=70
          RegularSequenceSize=7
          BeatSize=3
          NextSquadSpawnTime=2.f
	End Object
	WaveList(5)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave6'
     
	Begin Object Class=TurboPlusWaveMidGame Name=Wave7
          MaxMonsters=50
          TotalMonsters=72
          RegularSequenceSize=6
          BeatSize=3
          NextSquadSpawnTime=2.f
	End Object
	WaveList(6)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave7'
     
     //Late Game Waves:
	Begin Object Class=TurboPlusWaveLateGame Name=Wave8
          MaxMonsters=60
          TotalMonsters=75
          RegularSequenceSize=6
          BeatSize=1 
          NextSquadSpawnTime=1.f
	End Object
	WaveList(7)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave8'
     
	Begin Object Class=TurboPlusWaveLateGame Name=Wave9
          MaxMonsters=65
          TotalMonsters=78
          RegularSequenceSize=5
          BeatSize=2
          NextSquadSpawnTime=1.f
	End Object
	WaveList(8)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave9'
     
	Begin Object Class=TurboPlusWaveLateGame Name=Wave10
          MaxMonsters=70
          TotalMonsters=80
          RegularSequenceSize=5
          BeatSize=3
          NextSquadSpawnTime=1.f
	End Object
	WaveList(9)=TurboMonsterWave'KFTurbo.TurboMonsterCollectionWaveImpl.Wave10'

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
          Squad=TurboMonsterSquad'KFTurbo.TurboMonsterCollectionWaveImpl.HelperSquad0'
	End Object

	Begin Object Class=TurboMonsterBossSquad Name=BossSquad1
          Squad=TurboMonsterSquad'KFTurbo.TurboMonsterCollectionWaveImpl.HelperSquad1'
          SquadSizePerPlayerCount(0)=12
          SquadSizePerPlayerCount(1)=12
          SquadSizePerPlayerCount(2)=16
          SquadSizePerPlayerCount(3)=16
          SquadSizePerPlayerCount(4)=18
          SquadSizePerPlayerCount(5)=22
	End Object
     
	Begin Object Class=TurboMonsterBossSquad Name=BossSquad2
          Squad=TurboMonsterSquad'KFTurbo.TurboMonsterCollectionWaveImpl.HelperSquad2'
          SquadSizePerPlayerCount(0)=16
          SquadSizePerPlayerCount(1)=16
          SquadSizePerPlayerCount(2)=20
          SquadSizePerPlayerCount(3)=20
          SquadSizePerPlayerCount(4)=22
          SquadSizePerPlayerCount(5)=26
	End Object

     //Storing the boss squads for each heal round.
     BossSquadList(0)=TurboMonsterBossSquad'KFTurbo.TurboMonsterCollectionWaveImpl.BossSquad0'
     BossSquadList(1)=TurboMonsterBossSquad'KFTurbo.TurboMonsterCollectionWaveImpl.BossSquad1'
     BossSquadList(2)=TurboMonsterBossSquad'KFTurbo.TurboMonsterCollectionWaveImpl.BossSquad2'

}
