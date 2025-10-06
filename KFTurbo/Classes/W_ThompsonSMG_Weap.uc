//Killing Floor Turbo W_ThompsonSMG_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_ThompsonSMG_Weap extends WeaponThompsonSMG;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     ReloadRate=3.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.200000

     Weight=6.000000

     MagCapacity=25
     FireModeClass(0)=Class'KFTurbo.W_ThompsonSMG_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     InventoryGroup=3
     PickupClass=Class'KFTurbo.W_ThompsonSMG_Pickup'
     ItemName="Thompson Incendiary SMG"
}