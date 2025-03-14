//Killing Floor Turbo TurboAchievementMut
//Inspired by etsai (Scary Ghost)'s Server Achievements Mutator.
//This mutator was built to more closely align KFTurbo's methodology.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboAchievementMut extends Mutator
    config(TurboServerAchievements);

var() config array<string> AchievementPackList;
var array<TurboAchievementPack> AchievementClassList;

var TurboAchievementTcpLink AchievementTcpLink;

static final function KFTurboAchievementMut FindMutator(GameInfo GameInfo)
{
    local KFTurboAchievementMut TurboAchievementMut;
    local Mutator Mutator;

	if (GameInfo == None)
	{
		return None;
	}

    for ( Mutator = GameInfo.BaseMutator; Mutator != None; Mutator = Mutator.NextMutator )
    {
        TurboAchievementMut = KFTurboAchievementMut(Mutator);

        if (TurboAchievementMut == None)
        {
            continue;
        }

		return TurboAchievementMut;
    }

	return None;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
}

defaultproperties
{
    GroupName="KFServerAchievements"

    FriendlyName="Turbo Server Achievements"

    bAddToServerPackages=true
}
