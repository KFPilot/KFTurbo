class ZombieTestBoss_STANDARD extends P_ZombieBoss_STA;

function Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	Super(ZombieBossBase).Died(Killer, damageType, HitLocation);
}