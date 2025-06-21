//Killing Floor Turbo W_Claymore_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Claymore_Fire extends ClaymoreSwordFire;

function DoFireEffect()
{
    class'WeaponHelper'.static.OnMeleeFire(self);
    Super.DoFireEffect();
}

simulated function Timer()
{
    class'MeleeHelper'.static.PerformMeleeSwing(KFWeapon(Weapon), Self);
}

defaultproperties
{
     MeleeDamage=216
     weaponRange=110.000000
     WideDamageMinHitAngle=0.700000
     FireRate=1.050000
}