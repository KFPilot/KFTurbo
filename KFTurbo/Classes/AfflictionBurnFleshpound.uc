//Killing Floor Turbo AfflictionBurnFleshpound
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AfflictionBurnFleshpound extends AfflictionBurn;

var float RagedBurnDurationMultiplier;

simulated function Tick(CoreMonster Monster, float DeltaTime)
{
	if (MonsterFleshpound(Monster).bChargingPlayer)
	{
		Super.Tick(Monster, DeltaTime / FMax(RagedBurnDurationMultiplier, 0.001f));
	}
	else
	{
		Super.Tick(Monster, DeltaTime);
	}
}

defaultproperties
{
	RagedBurnDurationMultiplier=0.5f
}
