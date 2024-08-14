class P_Clot_Undead extends P_Clot_HAL;

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    // if the death wasnt by headshot or explosive, double max health & refill health
	if( !(bDecapitated || class<KFWeaponDamageType>(damageType).default.bIsExplosive)) 
	{
        if (HealthMax <= default.HealthMax*8)
            HealthMax*=2;
        Health=HealthMax;
	}
    else
    {
        super(ZombieClot).Died(Killer, damageType, HitLocation);
    }
}

defaultproperties
{
    MenuName="Revenant"
}