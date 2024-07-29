class TurboMonsterCollectionImpl extends TurboMonsterCollection;

defaultproperties
{
     //Early Game Waves:
	Begin Object Class=TurboPlusWaveEarly Name=Wave1
          MaxMonsters=45
          TotalMonsters=45
          BeatSize=1
          RegularSequenceSize=10
          MixInWaveMask=1 //Mask will filter out all MixIn squads in the list except for the first one (2^0 = 1).
	End Object
	WaveList(0)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave1'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave2
          MaxMonsters=45
          TotalMonsters=55
          RegularSequenceSize=10
          BeatSize=1
	End Object
	WaveList(1)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave2'

     //Mid Game Waves:
	Begin Object Class=TurboPlusWaveMidGame Name=Wave3
          MaxMonsters=45
          TotalMonsters=62
          RegularSequenceSize=8
          BeatSize=1
	End Object
	WaveList(2)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave3'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave4
          MaxMonsters=50
          TotalMonsters=65
          RegularSequenceSize=8
          BeatSize=2
	End Object
	WaveList(3)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave4'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave5
          MaxMonsters=50
          TotalMonsters=67
          RegularSequenceSize=7
          BeatSize=2
	End Object
	WaveList(4)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave5'

	Begin Object Class=TurboPlusWaveMidGame Name=Wave6
          MaxMonsters=50
          TotalMonsters=70
          RegularSequenceSize=7
          BeatSize=3
	End Object
	WaveList(5)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave6'
     
	Begin Object Class=TurboPlusWaveMidGame Name=Wave7
          MaxMonsters=50
          TotalMonsters=72
          RegularSequenceSize=6
          BeatSize=3
	End Object
	WaveList(6)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave7'
     
     //Late Game Waves:
	Begin Object Class=TurboPlusWaveLateGame Name=Wave8
          MaxMonsters=60
          TotalMonsters=75
          RegularSequenceSize=6
          BeatSize=1 
	End Object
	WaveList(7)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave8'
     
	Begin Object Class=TurboPlusWaveLateGame Name=Wave9
          MaxMonsters=65
          TotalMonsters=78
          RegularSequenceSize=5
          BeatSize=2
	End Object
	WaveList(8)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave9'
     
	Begin Object Class=TurboPlusWaveLateGame Name=Wave10
          MaxMonsters=70
          TotalMonsters=80
          RegularSequenceSize=5
          BeatSize=3
	End Object
	WaveList(9)=TurboMonsterCollectionWave'KFTurbo.TurboMonsterCollectionImpl.Wave10'
}
