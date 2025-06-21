//Killing Floor Turbo TurboPlusWaveEarly
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlusWaveEarly extends TurboMonsterWave;

static final function float GetPlayerCountMaxMonstersModifier(int PlayerCount)
{
	switch (PlayerCount)
	{
		case 1:
			return 0.4f;
		case 2:
			return 0.55f;
		case 3:
			return 0.7f;
		case 4:
			return 0.8f;
		case 5:
			return 0.9f;
		case 6:
			return 1.f;
	}

	return 1.f;
}

function int GetMaxMonsters(int PlayerCount)
{
	return Round(float(MaxMonsters) * GetPlayerCountMaxMonstersModifier(PlayerCount));
}

static final function float GetPlayerNextSquadSpawnTimeModifier(int PlayerCount)
{
	switch (PlayerCount)
	{
		case 1:
			return 15.f;
		case 2:
			return 12.f;
		case 3:
			return 10.f;
		case 4:
			return 8.f;
		case 5:
			return 7.f;
		case 6:
			return 6.f;
	}

	return 6.f;
}

function float GetNextSquadSpawnTime(int PlayerCount)
{
	return NextSquadSpawnTime * GetPlayerNextSquadSpawnTimeModifier(PlayerCount);
}

defaultproperties
{
	MaxMonsters=45
	TotalMonsters=40
	WaveDifficulty=2.35f
	RegularSequenceSize=20
	MinMixInSquadCount=4
	MaxMixInSquadCount=4
	BeatSize=2
	NextSquadSpawnTime=0.f

	//REGULARS
	Begin Object Class=TurboMonsterSquad Name=EarlySquad0
		Squad(0)=(Monster=Clot,Count=2)
		Squad(1)=(Monster=Crawler,Count=2)
	End Object
	RegularSquad(0)=TurboMonsterSquad'EarlySquad0'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad1
		Squad(0)=(Monster=Gorefast,Count=2)
		Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(1)=TurboMonsterSquad'EarlySquad1'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad2
		Squad(0)=(Monster=Bloat,Count=1)
		Squad(1)=(Monster=Crawler,Count=2)
	End Object
	RegularSquad(2)=TurboMonsterSquad'EarlySquad2'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad3
		Squad(0)=(Monster=Siren,Count=1)
		Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(3)=TurboMonsterSquad'EarlySquad3'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad4
		Squad(0)=(Monster=Stalker,Count=2)
		Squad(1)=(Monster=Gorefast,Count=2)
	End Object
	RegularSquad(4)=TurboMonsterSquad'EarlySquad4'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad5
		Squad(0)=(Monster=Husk,Count=1)
		Squad(1)=(Monster=Crawler,Count=2)
	End Object
	RegularSquad(5)=TurboMonsterSquad'EarlySquad5'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad6
		Squad(0)=(Monster=Bloat,Count=1)
		Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(6)=TurboMonsterSquad'EarlySquad6'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad7
		Squad(0)=(Monster=Husk,Count=1)
		Squad(1)=(Monster=Stalker,Count=2)
	End Object
	RegularSquad(7)=TurboMonsterSquad'EarlySquad7'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad8
		Squad(0)=(Monster=Siren,Count=1)
		Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(8)=TurboMonsterSquad'EarlySquad8'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad9
		Squad(0)=(Monster=Gorefast,Count=2)
		Squad(1)=(Monster=Stalker,Count=2)
	End Object
	RegularSquad(9)=TurboMonsterSquad'EarlySquad9'

	Begin Object Class=TurboMonsterSquad Name=EarlySquad10
		Squad(0)=(Monster=Gorefast,Count=2)
		Squad(1)=(Monster=Clot,Count=2)
	End Object
	RegularSquad(10)=TurboMonsterSquad'EarlySquad10'

	//MIXINS
	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad0
		Squad(0)=(Monster=Scrake,Count=1)
		Squad(1)=(Monster=Siren,Count=1)
	End Object
	MixInSquad(0)=TurboMonsterSquad'EarlyMixInSquad0'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad1
		Squad(0)=(Monster=Scrake,Count=2)
	End Object
	MixInSquad(1)=TurboMonsterSquad'EarlyMixInSquad1'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad2
		Squad(0)=(Monster=Scrake,Count=1)
		Squad(1)=(Monster=Husk,Count=1)
	End Object
	MixInSquad(2)=TurboMonsterSquad'EarlyMixInSquad2'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad3
		Squad(0)=(Monster=Scrake,Count=1)
		Squad(1)=(Monster=Bloat,Count=1)
	End Object
	MixInSquad(3)=TurboMonsterSquad'EarlyMixInSquad3'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad4
		Squad(0)=(Monster=Scrake,Count=1)
		Squad(1)=(Monster=Gorefast,Count=2)
	End Object
	MixInSquad(4)=TurboMonsterSquad'EarlyMixInSquad4'

	Begin Object Class=TurboMonsterSquad Name=EarlyMixInSquad5
          Squad(0)=(Monster=Scrake,Count=2)
	End Object
	MixInSquad(5)=TurboMonsterSquad'EarlyMixInSquad5'

	//BEATS
	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad0
		Squad(0)=(Monster=Fleshpound,Count=1)
	End Object
	BeatSquad(0)=TurboMonsterSquad'EarlyBeatSquad0'

	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad1
		Squad(0)=(Monster=Fleshpound,Count=1)
		Squad(1)=(Monster=Scrake,Count=1)
	End Object
	BeatSquad(1)=TurboMonsterSquad'EarlyBeatSquad1'

	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad2
		Squad(0)=(Monster=Fleshpound,Count=1)
		Squad(1)=(Monster=Bloat,Count=1)
	End Object
	BeatSquad(2)=TurboMonsterSquad'EarlyBeatSquad2'

	Begin Object Class=TurboMonsterSquad Name=EarlyBeatSquad3
		Squad(0)=(Monster=Fleshpound,Count=1)
		Squad(1)=(Monster=Siren,Count=1)
	End Object
	BeatSquad(3)=TurboMonsterSquad'EarlyBeatSquad3'
}