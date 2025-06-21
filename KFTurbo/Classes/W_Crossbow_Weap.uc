//Killing Floor Turbo W_Crossbow_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Crossbow_Weap extends Crossbow;

simulated event StopFire(int Mode)
{
    if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
    Super.StopFire(Mode);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 16);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_Crossbow_Fire'
     PickupClass=Class'KFTurbo.W_Crossbow_Pickup'
}
