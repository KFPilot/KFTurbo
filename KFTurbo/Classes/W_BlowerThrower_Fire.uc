//Killing Floor Turbo W_BlowerThrower_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BlowerThrower_Fire extends WeaponBlowerThrowerFire;

var int FireEffectCount;

function DoFireEffect()
{
     if (++FireEffectCount >= 10) { class'WeaponHelper'.static.OnWeaponFire(self); FireEffectCount = 0; }
     Super.DoFireEffect();
}

defaultproperties
{

}
