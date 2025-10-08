//Killing Floor Turbo W_ThompsonSMG_DT
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_ThompsonSMG_DT extends DamageTypeMAC10MPInc
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( Killed.IsA('MonsterStalker') )
     {
          KFStatsAndAchievements.AddStalkerKill();
     }
}

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddBullpupDamage(Amount);
	KFStatsAndAchievements.AddFlameThrowerDamage(Amount);
	KFStatsAndAchievements.AddMac10BurnDamage(Amount);
}

defaultproperties
{
     bDealBurningDamage=True
     WeaponClass=Class'KFTurbo.W_ThompsonSMG_Weap'
     DeathString="%k killed %o (Thompson SMG)."
     HeadShotDamageMult=1.100000
     BurnStrength=2.f
     
     bRagdollBullet=True
     KDamageImpulse=5500.000000
     KDeathVel=175.000000
     KDeathUpKick=15.000000
     
     OriginalDamageType=class'KFMod.DamTypeThompson'
}
