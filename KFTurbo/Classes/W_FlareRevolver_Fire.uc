//Killing Floor Turbo W_FlareRevolver_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FlareRevolver_Fire extends FlareRevolverFire;

function DoFireEffect()
{
    class'WeaponHelper'.static.OnWeaponFire(self);
    Super.DoFireEffect();
}

defaultproperties
{
     AmmoClass=Class'KFTurbo.W_FlareRevolver_Ammo'
     ProjectileClass=Class'KFTurbo.W_FlareRevolver_Proj'
}