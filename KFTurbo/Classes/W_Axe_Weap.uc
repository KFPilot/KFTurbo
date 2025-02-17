//Killing Floor Turbo W_Axe_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Axe_Weap extends Axe;

simulated function BringUp(optional Weapon PrevWeapon)
{
    class'WeaponHelper'.static.WeaponCheckForHint(Self, 22);
    class'WeaponHelper'.static.WeaponPulloutRemark(Self, 24);

    Super.BringUp(PrevWeapon);
}

defaultproperties
{
    PickupClass=Class'KFTurbo.W_Axe_Pickup'
    FireModeClass(0)=Class'KFTurbo.W_Axe_Fire'
    FireModeClass(1)=Class'KFTurbo.W_Axe_Fire_Alt'
}
