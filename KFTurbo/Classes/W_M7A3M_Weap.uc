//Killing Floor Turbo W_M7A3M_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M7A3M_Weap extends M7A3MMedicGun;

var float HealAmmoAmount;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

simulated function float ChargeBar()
{
	return class'WeaponHelper'.static.GetMedicGunChargeBar(self);
}

simulated function Tick(float dt)
{
	class'WeaponHelper'.static.TickMedicGunRecharge(self, dt, HealAmmoAmount);

	if (Role == ROLE_Authority)
	{
		HealAmmoCharge = HealAmmoAmount;
	}
}

simulated function bool ConsumeAmmo(int Mode, float Load, optional bool bAmountNeededIsMax)
{
	local byte Status;
	if (class'WeaponHelper'.static.ConsumeMedicGunAmmo(self, Mode, Load, HealAmmoAmount, Status))
	{
		HealAmmoCharge = HealAmmoAmount;
		return Status == 0;
	}

	return Super(KFWeapon).ConsumeAmmo(Mode, Load, bAmountNeededIsMax);
}

defaultproperties
{
     HealAmmoAmount=480.000000
     HealBoostAmount=56
     HealAmmoCharge=480
     AmmoRegenRate=0.600000
     MagCapacity=10
     ReloadRate=2.500000
     ReloadAnimRate=1.230000
     FireModeClass(0)=Class'KFTurbo.W_M7A3M_Fire'
     FireModeClass(1)=Class'KFTurbo.W_M7A3M_AltFire'
     PickupClass=Class'KFTurbo.W_M7A3M_Pickup'
}
