class TurboMonsterCollectionImpl extends TurboMonsterCollection;

defaultproperties
{
     //Early Game Waves:
	Begin Object Class=TurboPlusWaveEarly Name=Wave1
          MaxMonsters=35
          TotalMonsters=35
          BeatSize=1
	End Object
	WaveList(0)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave1'

	Begin Object Class=TurboPlusWaveEarly Name=Wave2
          MaxMonsters=35
          TotalMonsters=35
          BeatSize=1
	End Object
	WaveList(1)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave2'

	Begin Object Class=TurboPlusWaveEarly Name=Wave3
          MaxMonsters=40
          TotalMonsters=40
          RegularSequenceSize=7
          BeatSize=1
	End Object
	WaveList(2)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave3'

     //Mid Game Waves:
	Begin Object Class=TurboPlusWaveMidGame Name=Wave4
          MaxMonsters=45
          TotalMonsters=45
          RegularSequenceSize=7
          BeatSize=1
	End Object
	WaveList(3)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave4'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave5
          MaxMonsters=45
          TotalMonsters=45
          RegularSequenceSize=6
          BeatSize=2
	End Object
	WaveList(4)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave5'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave6
          MaxMonsters=50
          TotalMonsters=50
          RegularSequenceSize=6
          BeatSize=2
	End Object
	WaveList(5)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave6'
     
	Begin Object Class=TurboPlusWaveMidGame Name=Wave7
          MaxMonsters=50
          TotalMonsters=50
          RegularSequenceSize=6
          BeatSize=2
	End Object
	WaveList(6)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave7'
     
     //Late Game Waves:
	Begin Object Class=TurboPlusWaveLateGame Name=Wave8
          MaxMonsters=55
          TotalMonsters=55
          RegularSequenceSize=6
          BeatSize=1 //Start beat size at 1 for late game because TurboPlusWaveLateGame makes beat squads stronger. 
	End Object
	WaveList(7)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave8'
     
	Begin Object Class=TurboPlusWaveLateGame Name=Wave9
          MaxMonsters=55
          TotalMonsters=55
          RegularSequenceSize=6
          BeatSize=1
	End Object
	WaveList(8)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave9'
     
	Begin Object Class=TurboPlusWaveLateGame Name=Wave10
          MaxMonsters=60
          TotalMonsters=60
          RegularSequenceSize=6
          BeatSize=2
	End Object
	WaveList(9)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave10'
}
