class TurboPlusWaveEarly extends TurboMonsterWave;

defaultproperties
{
     MaxMonsters=35
     TotalMonsters=35
     WaveDifficulty=1.f

     RegularSequenceSize=10
     MinMixInSquadCount=1
     MaxMixInSquadCount=2

     // Small beat Size for early waves
     BeatSize=1

     // Here is an example of a squad with 2 clots and 3 crawlers.
	Begin Object Class=TurboMonsterSquad Name=EarlySquad0
          Squad(0)=(Monster=Clot,Count=2)
          Squad(1)=(Monster=Crawler,Count=2)
          Squad(2)=(Monster=Gorefast,Count=1)
	End Object
     // These TurboMonsterCollectionSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad0' are fully qualified paths
     // that means that you can define a squad in this class and then reuse the squad in another class!
	RegularSquad(0)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad0'

     //Here is an example of a squad with 2 gorefasts and 1 clot.
	Begin Object Class=TurboMonsterSquad Name=EarlySquad1
          Squad(0)=(Monster=Gorefast,Count=2)
          Squad(1)=(Monster=Clot,Count=2)
          Squad(2)=(Monster=Bloat,Count=1)
	End Object
	RegularSquad(1)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad1'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad2
          Squad(0)=(Monster=Crawler,Count=5)
	End Object
	RegularSquad(2)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad2'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad3
          Squad(0)=(Monster=Siren,Count=1)
          Squad(1)=(Monster=Bloat,Count=2)
          Squad(2)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(3)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad3'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad4
          Squad(0)=(Monster=Stalker,Count=3)
          Squad(1)=(Monster=Gorefast,Count=2)
	End Object
	RegularSquad(4)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad4'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad5
          Squad(0)=(Monster=Husk,Count=1)
          Squad(1)=(Monster=Crawler,Count=4)
	End Object
	RegularSquad(5)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlySquad5'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad0
          Squad(0)=(Monster=Scrake,Count=1)
          Squad(1)=(Monster=Stalker,Count=3)
	End Object
	MixInSquad(0)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad0'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad1
          Squad(0)=(Monster=Scrake,Count=2)
          Squad(1)=(Monster=Clot,Count=1)
          Squad(2)=(Monster=Stalker,Count=2)
	End Object
	MixInSquad(1)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad1'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad2
          Squad(0)=(Monster=Husk,Count=1)
          Squad(1)=(Monster=Scrake,Count=1)
          Squad(2)=(Monster=Gorefast,Count=1)
	End Object
	MixInSquad(2)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad2'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad3
          Squad(0)=(Monster=Siren,Count=1)
          Squad(1)=(Monster=Scrake,Count=1)
          Squad(2)=(Monster=Bloat,Count=1)
	End Object
	MixInSquad(3)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad3'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad4
          Squad(1)=(Monster=Scrake,Count=1)
	End Object
	MixInSquad(4)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyMixInSquad4'

     // Beat Squads: Remember that if the wave's BeatSize is less than or equal to 0, these won't get used (but we can define them anyways).
	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad0
          Squad(0)=(Monster=Fleshpound,Count=1)
	End Object
	BeatSquad(0)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyBeatSquad0'

	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad1
          Squad(0)=(Monster=Scrake,Count=2)
          Squad(1)=(Monster=Siren,Count=1)
	End Object
	BeatSquad(1)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyBeatSquad1'

	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad2
          Squad(0)=(Monster=Husk,Count=2)
          Squad(1)=(Monster=Stalker,Count=5)
	End Object
	BeatSquad(2)=TurboMonsterSquad'KFTurbo.TurboPlusWaveEarly.EarlyBeatSquad2'
}
