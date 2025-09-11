//Killing Floor Turbo TurboPlusWaveChallenge
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlusWaveChallenge extends TurboPlusWaveLateGame; 

defaultproperties
{
	MaxMonsters=50
	TotalMonsters=48
	WaveDifficulty=2.75f
	RegularSequenceSize=18
	MinMixInSquadCount=6
	MaxMixInSquadCount=6
	BeatSize=4
	NextSquadSpawnTime=0.f

    //REGULARS
	Begin Object Class=TurboMonsterSquad Name=ChallengeSquad0
		Squad(0)=(Monster=Siren,Count=1)
		Squad(1)=(Monster=Gorefast,Count=1)
	End Object
	RegularSquad(14)=TurboMonsterSquad'ChallengeSquad0'

	Begin Object Class=TurboMonsterSquad Name=ChallengeSquad1
		Squad(0)=(Monster=Husk,Count=1)
		Squad(1)=(Monster=Gorefast,Count=1)
	End Object
	RegularSquad(15)=TurboMonsterSquad'ChallengeSquad1'

	Begin Object Class=TurboMonsterSquad Name=ChallengeSquad2
		Squad(0)=(Monster=Bloat,Count=1)
	End Object
	RegularSquad(16)=TurboMonsterSquad'ChallengeSquad2'

    //MIXINS
	Begin Object Class=TurboMonsterSquad Name=ChallengeMixInSquad0
		Squad(0)=(Monster=Scrake,Count=2)
	End Object
	MixInSquad(9)=TurboMonsterSquad'ChallengeMixInSquad0'

	Begin Object Class=TurboMonsterSquad Name=ChallengeMixInSquad1
		Squad(0)=(Monster=Scrake,Count=2)
	End Object
	MixInSquad(10)=TurboMonsterSquad'ChallengeMixInSquad1'

	Begin Object Class=TurboMonsterSquad Name=ChallengeMixInSquad2
		Squad(0)=(Monster=Scrake,Count=1)
		Squad(1)=(Monster=Siren,Count=2)
	End Object
	MixInSquad(11)=TurboMonsterSquad'ChallengeMixInSquad2'

	Begin Object Class=TurboMonsterSquad Name=ChallengeMixInSquad3
		Squad(0)=(Monster=Scrake,Count=1)
		Squad(1)=(Monster=Husk,Count=2)
	End Object
	MixInSquad(12)=TurboMonsterSquad'ChallengeMixInSquad3'

	Begin Object Class=TurboMonsterSquad Name=ChallengeMixInSquad4
		Squad(0)=(Monster=Scrake,Count=1)
		Squad(1)=(Monster=Bloat,Count=2)
	End Object
	MixInSquad(13)=TurboMonsterSquad'ChallengeMixInSquad4'

	//BEATS
	Begin Object Class=TurboMonsterSquad Name=ChallengeBeatSquad0
		Squad(0)=(Monster=Fleshpound,Count=1)
		Squad(1)=(Monster=Scrake,Count=1)
	End Object
	BeatSquad(6)=TurboMonsterSquad'ChallengeBeatSquad0'

	Begin Object Class=TurboMonsterSquad Name=ChallengeBeatSquad1
		Squad(0)=(Monster=Fleshpound,Count=1)
		Squad(1)=(Monster=Scrake,Count=1)
	End Object
	BeatSquad(7)=TurboMonsterSquad'ChallengeBeatSquad1'
}
