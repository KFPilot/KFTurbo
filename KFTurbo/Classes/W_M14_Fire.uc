//Killing Floor Turbo W_M14_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M14_Fire extends M14EBRFire;

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
     AmmoClass=Class'W_M14_Ammo'
}
