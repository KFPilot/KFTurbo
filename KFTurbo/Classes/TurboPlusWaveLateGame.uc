class TurboPlusWaveLateGame extends TurboPlusWaveMidGame;

defaultproperties
{
     MaxMonsters=55
     TotalMonsters=55
     WaveDifficulty=3.f

     RegularSequenceSize=6
     MinMixInSquadCount=3
     MaxMixInSquadCount=4
     BeatSize=1

	Begin Object Class=TurboMonsterCollectionSquad Name=LateGameSquad5
          Squad(0)=(Monster=Bloat,Count=2)
          Squad(1)=(Monster=Gorefast,Count=1)
	End Object
	RegularSquad(5)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveLateGame.LateGameSquad5'

	Begin Object Class=TurboMonsterCollectionSquad Name=LateGameSquad6
          Squad(0)=(Monster=Husk,Count=2)
          Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(6)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveLateGame.LateGameSquad6'

	Begin Object Class=TurboMonsterCollectionSquad Name=LateGameSquad7
          Squad(0)=(Monster=Siren,Count=3)
          Squad(1)=(Monster=Crawler,Count=2)
	End Object
	RegularSquad(7)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveLateGame.LateGameSquad7'

	Begin Object Class=TurboMonsterCollectionSquad Name=LateGameBeatSquad3
          Squad(0)=(Monster=Scrake,Count=4)
	End Object
	MixInSquad(3)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveLateGame.LateGameBeatSquad3'

     //Override single FP beat spawn with 3.
	Begin Object Class=TurboMonsterCollectionSquad Name=LateGameBeatSquad0
          Squad(0)=(Monster=Fleshpound,Count=3)
	End Object
	BeatSquad(0)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveLateGame.LateGameBeatSquad0' 

	Begin Object Class=TurboMonsterCollectionSquad Name=LateGameBeatSquad1
          Squad(0)=(Monster=Fleshpound,Count=4)
	End Object
	BeatSquad(3)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveLateGame.LateGameBeatSquad1'
}
