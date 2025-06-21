//Killing Floor Turbo W_Deagle_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Deagle_Fire extends DeagleFire;

function DoFireEffect()
{
    class'WeaponHelper'.static.OnWeaponFire(self);
    Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 1, 0.8);
}

defaultproperties
{
     maxVerticalRecoilAngle=850
     maxHorizontalRecoilAngle=150
     AmmoClass=class'W_Deagle_Ammo'
}