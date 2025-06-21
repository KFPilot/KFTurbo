class ZombieTestBoss_HALLOWEEN extends P_ZombieBoss_HAL;

function Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	Super(ZombieBossBase).Died(Killer, damageType, HitLocation);
}