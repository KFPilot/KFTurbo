//Killing Floor Turbo W_MP7M_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MP7M_Weap extends MP7MMedicGun;

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
	HealAmmoAmount=700.000000
	HealBoostAmount=30
	HealAmmoCharge=700
	AmmoRegenRate=0.200000
	
	FireModeClass(0)=Class'KFTurbo.W_MP7M_Fire'
	FireModeClass(1)=Class'KFTurbo.W_MP7M_Fire_Alt'
	PickupClass=Class'KFTurbo.W_MP7M_Pickup'
}
