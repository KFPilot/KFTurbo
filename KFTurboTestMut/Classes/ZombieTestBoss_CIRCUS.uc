class ZombieTestBoss_CIRCUS extends P_ZombieBoss_SUM;

function Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	Super(ZombieBossBase).Died(Killer, damageType, HitLocation);
}