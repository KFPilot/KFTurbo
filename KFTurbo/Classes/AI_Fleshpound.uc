//Killing Floor Turbo AI_Fleshpound
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AI_Fleshpound extends FleshpoundZombieController;

var bool bEnableForceRage;
var float TimeUntilForcedRage;
var bool bForcedRage;

function Tick(float dt)
{
	local ZombieFleshPound ZFP;

	Super.Tick(dt);

	if (!bForcedRage && (bEnableForceRage && Level.TimeSeconds > TimeUntilForcedRage))
	{
		bForcedRage = true;
	}

	if (bForcedRage)
	{
	    ZFP = ZombieFleshPound(Pawn);

	    if(ZFP != None && !ZFP.bFrustrated)
	    {
	        ZFP.StartCharging();
	        ZFP.bFrustrated = true;
	    }
	}
}

state ZombieCharge
{
	function BeginState()
	{
		if (!bEnableForceRage)
		{
			bEnableForceRage = true;
			TimeUntilForcedRage = Level.TimeSeconds + 180.f; //Forced raged in 3 minutes.			
		}

        Super.BeginState();
	}
}

//If a Fleshpound kills a player, reset their forced rage timer/state.
function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
	if (Killer == self && KFHumanPawn(Other) != None)
	{
		ResetForcedRage();
	}

	Super.NotifyKilled(Killer, Killed, Other);
}

function ResetForcedRage()
{
	if (!bEnableForceRage)
	{
		return;
	}

	bForcedRage = false;
	TimeUntilForcedRage = Level.TimeSeconds + 180.f;
}

defaultproperties
{
	
}