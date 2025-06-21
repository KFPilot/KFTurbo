//Killing Floor Turbo AI_Scrake
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AI_Scrake extends SawZombieController;

var bool bEnableForceRage;
var float TimeUntilForcedRage;
var bool bForcedRage;

function Tick(float dt)
{
	Super.Tick(dt);

	if(!bForcedRage && (bEnableForceRage && Level.TimeSeconds > TimeUntilForcedRage))
	{
		ForceRage(Pawn);
	}
}

function ForceRage(Pawn Pawn)
{
	local P_Scrake Scrake;
	Scrake = P_Scrake(Pawn);

	bForcedRage = true;

	if (Scrake == none)
	{
		return;
	}

	//Attempt a ranged attack to try the normal rage flow.
	if (Scrake.HealthRageThreshold < 1000.f)
	{
		Scrake.HealthRageThreshold = 1000.f;
		Scrake.RangedAttack(None);
	}
}


state ZombieCharge
{
	function BeginState()
	{
		if(!bEnableForceRage && Level.Game.GameDifficulty >= 5.0)
		{
			bEnableForceRage = true;
			TimeUntilForcedRage = Level.TimeSeconds + 180.f; //Forced raged in 3 minutes.			
		}

        Super.BeginState();
	}
}

defaultproperties
{
}
