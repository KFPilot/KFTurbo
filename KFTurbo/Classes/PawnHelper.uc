//Killing Floor Turbo PawnHelper
//Anti redundancy class. Handles logic for zeds.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PawnHelper extends Object;

static final simulated function InitializePawnHelper(KFMonster Monster)
{
	if (Monster.Level.NetMode != NM_DedicatedServer && TurboGameReplicationInfo(Monster.Level.GRI) != None)
	{
		TurboGameReplicationInfo(Monster.Level.GRI).ModifyMonster(Monster);
	}
}

static final function bool UpdateStunProperties(KFMonster KFM, float LastStunCount, out float UnstunTime, bool bUnstunTimeReady)
{
	if (LastStunCount == KFM.StunsRemaining)
	{
		return bUnstunTimeReady;
	}

	UnstunTime = KFM.Level.TimeSeconds + KFM.StunTime;
	bUnstunTimeReady = true;

	if (KFM.BurnDown <= 0)
	{
		//Don't uncomment this - is responsible for flinch slow raging.
		//KFM.SetTimer(-1.f, false);
	}
	else
	{
		//Need to avoid a case where SetTimer() resets itself instead of just starting a new timer.
		if ((1.f - KFM.TimerCounter) < 0.0001f)
		{
			KFM.Timer();
		}
		else
		{
			//AActor::TimerCounter is the amount of time that the current timer has elapsed.
			KFM.SetTimer(1.f - KFM.TimerCounter, false); //burn timer is not a var and always 1 second.
		}
	}

	return bUnstunTimeReady;
}

defaultproperties
{

}
