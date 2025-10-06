//Killing Floor Turbo W_M4203_DT_Bullet
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M4203_DT_Bullet extends DamageTypeM4203AssaultRifle
	abstract;

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddBullpupDamage(Amount);
}

defaultproperties
{
     WeaponClass=Class'KFTurbo.W_M4203_Weap'
}
