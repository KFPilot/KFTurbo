//Killing Floor Turbo W_DualMK23_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_DualMK23_Fire extends DualMK23Fire;

function DoFireEffect()
{
    class'WeaponHelper'.static.OnWeaponFire(self);
    Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 0, 0.0);
}

defaultproperties
{
    Spread=0.011000
    AmmoClass=class'W_MK23_Ammo'
}