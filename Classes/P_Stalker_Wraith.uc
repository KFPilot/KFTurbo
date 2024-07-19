class P_Stalker_Wraith extends P_Stalker_XMA;

function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (class<KFWeaponDamageType>(damageType).default.bIsExplosive)
	{
		Damage = 0;
	}

	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);
}

defaultproperties
{
     MeleeDamage=12
     MeleeRange=40.000000
     GroundSpeed=250.000000
     WaterSpeed=200.000000
     Health=80
     MenuName="Wraith"
}