//Killing Floor Turbo W_SCARMK17_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_SCARMK17_Fire extends WeaponSCARMK17Fire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnWeaponFire(self);
     Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 1, 0.75);
}

defaultproperties
{
     MaxSpread=0.090000
     AmmoClass=class'W_SCARMK17_Ammo'
     DamageMin=60
     DamageMax=65
}