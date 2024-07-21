class TurboPlusWaveMidGame extends TurboPlusWaveEarly;

defaultproperties
{
     MaxMonsters=45
     TotalMonsters=45
     WaveDifficulty=2.f

     RegularSequenceSize=7
     MinMixInSquadCount=2
     MaxMixInSquadCount=3
     BeatSize=1

	Begin Object Class=TurboMonsterCollectionSquad Name=MidGameSquad0
          Squad(0)=(Monster=Bloat,Count=3)
          Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(6)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveMidGame.MidGameSquad0'

	Begin Object Class=TurboMonsterCollectionSquad Name=MidGameSquad1
          Squad(0)=(Monster=Husk,Count=2)
          Squad(1)=(Monster=Crawler,Count=3)
	End Object
	RegularSquad(7)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveMidGame.MidGameSquad1'

	Begin Object Class=TurboMonsterCollectionSquad Name=MidGameSquad2
          Squad(0)=(Monster=Siren,Count=3)
          Squad(1)=(Monster=Stalker,Count=2)
	End Object
	RegularSquad(8)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveMidGame.MidGameSquad2'

	Begin Object Class=TurboMonsterCollectionSquad Name=MidGameBeatSquad0
          Squad(0)=(Monster=Fleshpound,Count=2)
	End Object
	BeatSquad(1)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveMidGame.MidGameBeatSquad0'

	Begin Object Class=TurboMonsterCollectionSquad Name=MidGameBeatSquad1
          Squad(0)=(Monster=Scrake,Count=2)
          Squad(1)=(Monster=Fleshpound,Count=2)
	End Object
	MixInSquad(2)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveMidGame.MidGameBeatSquad1'
}
