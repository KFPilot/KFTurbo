//Killing Floor Turbo W_M7A3M_AltFire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M7A3M_AltFire extends WeaponM7A3MAltFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnMedicDartFire(self);
     Super.DoFireEffect();
}

defaultproperties
{
     AmmoPerFire=375
     ProjectileClass=Class'KFTurbo.W_M7A3M_Proj'
}
