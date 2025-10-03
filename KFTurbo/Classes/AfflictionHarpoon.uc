//Killing Floor Turbo AfflictionHarpoon
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AfflictionHarpoon extends CoreMonsterAfflictionHarpoon;

var float HarpoonSpeedModifier;

simulated function PreTick(KFMonster Monster, float DeltaTime)
{
	if (Monster == None || Monster.bHarpoonStunned)
	{
		CachedMovementSpeedModifier = HarpoonSpeedModifier;
	}
	else
	{
		CachedMovementSpeedModifier = 1.f;
	}
}

defaultproperties
{
	HarpoonSpeedModifier = 0.75f;
}
