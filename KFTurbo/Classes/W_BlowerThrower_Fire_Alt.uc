//Killing Floor Turbo W_BlowerThrower_Fire_Alt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_BlowerThrower_Fire_Alt extends BlowerThrowerAltFire;

function DoFireEffect()
{
	class'WeaponHelper'.static.OnWeaponFire(self);
	Super.DoFireEffect();
}

defaultproperties
{

}
