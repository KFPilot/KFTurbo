class TurboPlusWaveMidGame extends TurboPlusWaveEarly;

defaultproperties
{
     MaxMonsters=45
     TotalMonsters=45
     WaveDifficulty=2.f

     RegularSequenceSize=8
     MinMixInSquadCount=2
     MaxMixInSquadCount=3
     BeatSize=1

     Begin Object Class=TurboMonsterSquad Name=MidGameSquad0
          Squad(0)=(Monster=Bloat,Count=3)
          Squad(1)=(Monster=Clot,Count=2)
          Squad(2)=(Monster=Stalker,Count=2)
	End Object
	RegularSquad(6)=TurboMonsterSquad'MidGameSquad0'

	Begin Object Class=TurboMonsterSquad Name=MidGameSquad1
          Squad(0)=(Monster=Husk,Count=2)
          Squad(1)=(Monster=Crawler,Count=3)
          Squad(2)=(Monster=Siren,Count=1)
	End Object
	RegularSquad(7)=TurboMonsterSquad'MidGameSquad1'

	Begin Object Class=TurboMonsterSquad Name=MidGameSquad2
          Squad(0)=(Monster=Gorefast,Count=2)
          Squad(1)=(Monster=Clot,Count=2)
          Squad(2)=(Monster=Siren,Count=2)
	End Object
	RegularSquad(8)=TurboMonsterSquad'MidGameSquad2'

	Begin Object Class=TurboMonsterSquad Name=MidGameBeatSquad0
          Squad(0)=(Monster=Fleshpound,Count=2)
	End Object
	BeatSquad(1)=TurboMonsterSquad'MidGameBeatSquad0'

	Begin Object Class=TurboMonsterSquad Name=MidGameBeatSquad1
          Squad(0)=(Monster=Scrake,Count=2)
          Squad(1)=(Monster=Fleshpound,Count=2)
	End Object
	MixInSquad(2)=TurboMonsterSquad'MidGameBeatSquad1'
}
