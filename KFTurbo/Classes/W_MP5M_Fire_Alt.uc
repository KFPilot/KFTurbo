//Killing Floor Turbo W_MP5M_Fire_Alt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_MP5M_Fire_Alt extends MP5MAltFire;

function DoFireEffect()
{
     class'WeaponHelper'.static.OnMedicDartFire(self);
     Super.DoFireEffect();
}

defaultproperties
{
     ProjectileClass=Class'KFTurbo.W_MP5M_Proj'
}
