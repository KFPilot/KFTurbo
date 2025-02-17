//Killing Floor Turbo W_M4203_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M4203_Proj extends M203GrenadeProjectile;

function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    class'WeaponHelper'.static.M79GrenadeTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bHasExploded)
	{
		return;
	}

	Super.Explode(HitLocation, HitNormal);
}

defaultproperties
{
    MyDamageType=Class'KFTurbo.W_M4203_DT'
    ImpactDamageType=Class'KFTurbo.W_M4203_Impact_DT'
    bGameRelevant=false
}
