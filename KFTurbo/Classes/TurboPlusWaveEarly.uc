class TurboPlusWaveEarly extends TurboMonsterWave;

defaultproperties
{
     MaxMonsters=35
     TotalMonsters=35
     WaveDifficulty=1.f
     RegularSequenceSize=10
     MinMixInSquadCount=1
     MaxMixInSquadCount=2
     BeatSize=2

	Begin Object Class=TurboMonsterSquad Name=EarlySquad0
          Squad(0)=(Monster=Clot,Count=2)
          Squad(1)=(Monster=Crawler,Count=2)
          Squad(2)=(Monster=Gorefast,Count=1)
	End Object
	RegularSquad(0)=TurboMonsterSquad'EarlySquad0' // Fully qualified and reusable path

	Begin Object Class=TurboMonsterSquad Name=EarlySquad1
          Squad(0)=(Monster=Gorefast,Count=2)
          Squad(1)=(Monster=Clot,Count=2)
          Squad(2)=(Monster=Bloat,Count=1)
	End Object
	RegularSquad(1)=TurboMonsterSquad'EarlySquad1'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad2
          Squad(0)=(Monster=Crawler,Count=5)
	End Object
	RegularSquad(2)=TurboMonsterSquad'EarlySquad2'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad3
          Squad(0)=(Monster=Siren,Count=1)
          Squad(1)=(Monster=Bloat,Count=2)
          Squad(2)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(3)=TurboMonsterSquad'EarlySquad3'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad4
          Squad(0)=(Monster=Stalker,Count=1)
          Squad(1)=(Monster=Gorefast,Count=2)
	End Object
	RegularSquad(4)=TurboMonsterSquad'EarlySquad4'
     
	Begin Object Class=TurboMonsterSquad Name=EarlySquad5
          Squad(0)=(Monster=Husk,Count=1)
          Squad(1)=(Monster=Crawler,Count=3)
	End Object
	RegularSquad(5)=TurboMonsterSquad'EarlySquad5'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad0
          Squad(0)=(Monster=Scrake,Count=1)
          Squad(1)=(Monster=Stalker,Count=1)
	End Object
	MixInSquad(0)=TurboMonsterSquad'EarlyMixInSquad0'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad1
          Squad(0)=(Monster=Scrake,Count=2)
          Squad(1)=(Monster=Clot,Count=1)
          Squad(2)=(Monster=Stalker,Count=2)
	End Object
	MixInSquad(1)=TurboMonsterSquad'EarlyMixInSquad1'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad2
          Squad(0)=(Monster=Husk,Count=1)
          Squad(1)=(Monster=Scrake,Count=1)
          Squad(2)=(Monster=Gorefast,Count=1)
	End Object
	MixInSquad(2)=TurboMonsterSquad'EarlyMixInSquad2'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad3
          Squad(0)=(Monster=Siren,Count=1)
          Squad(1)=(Monster=Scrake,Count=1)
          Squad(2)=(Monster=Bloat,Count=1)
	End Object
	MixInSquad(3)=TurboMonsterSquad'EarlyMixInSquad3'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad4
          Squad(1)=(Monster=Scrake,Count=1)
	End Object
	MixInSquad(4)=TurboMonsterSquad'EarlyMixInSquad4'

	// Beat Squads require BeatSize > 0
	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad0
          Squad(0)=(Monster=Fleshpound,Count=1)
	End Object
	BeatSquad(0)=TurboMonsterSquad'EarlyBeatSquad0'
     
	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad1
          Squad(0)=(Monster=Scrake,Count=1)
          Squad(1)=(Monster=Siren,Count=1)
	End Object
	BeatSquad(1)=TurboMonsterSquad'EarlyBeatSquad1'

	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad2
          Squad(0)=(Monster=Husk,Count=2)
          Squad(1)=(Monster=Stalker,Count=2)
	End Object
	BeatSquad(2)=TurboMonsterSquad'EarlyBeatSquad2'
}
