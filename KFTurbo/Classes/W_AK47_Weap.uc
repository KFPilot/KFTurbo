//Killing Floor Turbo W_AK47_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_AK47_Weap extends WeaponAK47AssaultRifle;

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
     if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     Weight=5.000000
     FireModeClass(0)=Class'KFTurbo.W_AK47_Fire'
     PickupClass=Class'KFTurbo.W_AK47_Pickup'

     Begin Object Class=V_CommandoClassification Name=CommandoClassification
     End Object
     WeaponClassification=CoreWeaponClassification'CommandoClassification'
}
