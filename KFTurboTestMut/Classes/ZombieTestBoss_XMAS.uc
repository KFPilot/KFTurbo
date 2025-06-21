class ZombieTestBoss_XMAS extends P_ZombieBoss_XMAS;

function Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	Super(ZombieBossBase).Died(Killer, damageType, HitLocation);
}