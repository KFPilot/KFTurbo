//Killing Floor Turbo W_Dual9MM_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Dual9MM_Fire extends DualiesFire;

function DoFireEffect()
{
    class'WeaponHelper'.static.OnWeaponFire(Self);
    Super.DoFireEffect();
}

function DoTrace(Vector Start, Rotator Direction)
{
	class'WeaponHelper'.static.PenetratingWeaponTrace(Start, Direction, KFWeapon(Weapon), self, 0, 0.0);
}

defaultproperties
{
    
}
