//Killing Floor Turbo W_Knife_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Knife_Fire extends KnifeFire;

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

}