//Killing Floor Turbo AfflictionZap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AfflictionZap extends CoreMonsterAfflictionZap;

//Actual zap affliction properties.
var float ZapDischargeDelay; //How long to wait before losing charge.
var float ZapDischargeRate; //How fast to lose charge after delay.

simulated function Tick(CoreMonster Monster, float DeltaTime)
{
	if ((Monster.Level.TimeSeconds - Monster.LastZapTime) < ZapDischargeDelay)
	{
		return;
	}

	Super.Tick(Monster, DeltaTime * ZapDischargeRate);
}

defaultproperties
{
	ZapDischargeDelay=1.f
	ZapDischargeRate=0.5f
}
