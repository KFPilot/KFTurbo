class W_L2A3_DT extends DamTypeAK47AssaultRifle
	abstract;

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddBullpupDamage(Amount);
	KFStatsAndAchievements.AddFlameThrowerDamage(Amount);
	KFStatsAndAchievements.AddMac10BurnDamage(Amount);
}

defaultproperties
{
     bDealBurningDamage=True
     WeaponClass=Class'KFTurbo.W_L2A3_Weap'
     DeathString="%k killed %o (L2A3)."
     HeadShotDamageMult=1.100000
}
