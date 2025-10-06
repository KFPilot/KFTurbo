//Killing Floor Turbo W_BoomStick_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BoomStick_Weap extends WeaponBoomStick;

simulated function SetPendingReload()
{
    Super.SetPendingReload();
    if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
     class'WeaponHelper'.static.WeaponCheckForHint(Self, 17);
     class'WeaponHelper'.static.WeaponPulloutRemark(Self, 21);

     Super.BringUp(PrevWeapon);
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_BoomStick_Fire_Alt'
     FireModeClass(1)=Class'KFTurbo.W_BoomStick_Fire'
     PickupClass=Class'KFTurbo.W_BoomStick_Pickup'
}