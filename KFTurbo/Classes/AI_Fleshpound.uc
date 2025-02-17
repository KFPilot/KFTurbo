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

	if(!bForcedRage && (bEnableForceRage && Level.TimeSeconds > TimeUntilForcedRage))
		bForcedRage = true;

	if(bForcedRage)
	{
	    ZFP = ZombieFleshPound(Pawn);

	    if( ZFP != none && !ZFP.bFrustrated )
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
		if(!bEnableForceRage)
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
