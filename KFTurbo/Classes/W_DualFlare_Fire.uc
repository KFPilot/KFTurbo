//Killing Floor Turbo W_DualFlare_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_DualFlare_Fire extends DualFlareRevolverFire;

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