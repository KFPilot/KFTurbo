class TurboPlusWaveEarly extends TurboMonsterCollectionWave;

defaultproperties
{
     MaxMonsters=35
     TotalMonsters=35
     WaveDifficulty=1.f

     RegularSequenceSize=8
     MinMixInSquadCount=1
     MaxMixInSquadCount=2

     //No "beats" for early wave.
     BeatSize=0

     //Here is an example of a squad with 2 clots and 3 crawlers.
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlySquad0
          Squad(0)=(Monster=Clot,Count=2)
          Squad(1)=(Monster=Crawler,Count=3)
	End Object
     //These TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad0' are fully qualified paths - that means that you can define a squad in this class and then reuse the squad in another class!
	RegularSquad(0)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad0'

     //Here is an example of a squad with 2 gorefasts and 1 clot.
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlySquad1
          Squad(0)=(Monster=Gorefast,Count=2)
          Squad(1)=(Monster=Clot,Count=1)
	End Object
	RegularSquad(1)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad1'
     
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlySquad2
          Squad(0)=(Monster=Crawler,Count=4)
          Squad(1)=(Monster=Clot,Count=1)
	End Object
	RegularSquad(2)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad2'
     
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlySquad3
          Squad(0)=(Monster=Siren,Count=1)
          Squad(1)=(Monster=Bloat,Count=2)
	End Object
	RegularSquad(3)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad3'
     
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlySquad4
          Squad(0)=(Monster=Stalker,Count=4)
          Squad(1)=(Monster=Gorefast,Count=2)
	End Object
	RegularSquad(4)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad4'
     
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlySquad5
          Squad(0)=(Monster=Husk,Count=1)
          Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(5)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad5'

     //An example of a couple of "mix in" squads.
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlyMixInSquad0
          Squad(0)=(Monster=Scrake,Count=1)
          Squad(1)=(Monster=Stalker,Count=3)
	End Object
	MixInSquad(0)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad0'

	Begin Object Class=TurboMonsterCollectionSquad Name=EarlyMixInSquad1
          Squad(0)=(Monster=Scrake,Count=2)
          Squad(1)=(Monster=Clot,Count=1)
	End Object
	MixInSquad(1)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad1'

	Begin Object Class=TurboMonsterCollectionSquad Name=EarlyMixInSquad2
          Squad(0)=(Monster=Husk,Count=3)
          Squad(1)=(Monster=Scrake,Count=1)
	End Object
	MixInSquad(2)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad2'

	Begin Object Class=TurboMonsterCollectionSquad Name=EarlyMixInSquad3
          Squad(0)=(Monster=Siren,Count=3)
          Squad(1)=(Monster=Scrake,Count=1)
	End Object
	MixInSquad(3)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad3'

	Begin Object Class=TurboMonsterCollectionSquad Name=EarlyMixInSquad4
          Squad(0)=(Monster=Bloat,Count=3)
          Squad(1)=(Monster=Scrake,Count=1)
	End Object
	MixInSquad(4)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad4'

     //An example of a "beat" squad. Remember that if the wave's BeatSize is less than or equal to 0, these won't get used (but we can define them anyways).
	Begin Object Class=TurboMonsterCollectionSquad Name=EarlyBeatSquad0
          Squad(0)=(Monster=Fleshpound,Count=1)
	End Object
	BeatSquad(0)=TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlyBeatSquad0'
}
