//Killing Floor Turbo W_Syringe_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Syringe_Fire extends KFMod.SyringeFire;


function Timer()
{
	local KFPlayerReplicationInfo PRI;
	local float MedicReward;
	local KFHumanPawn Healed;
	local float HealSum; // for modifying based on perks

	Healed = CachedHealee;
	CachedHealee = None;

	if (Healed == None || Healed.Health <= 0 || Healed == Instigator)
	{
		return;
	}

	Weapon.ConsumeAmmo(ThisModeNum, AmmoPerFire);

	MedicReward = Syringe(Weapon).HealBoostAmount;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		MedicReward *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetHealPotency(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
	}

	HealSum = MedicReward;
    MedicReward = Min(MedicReward, FMax((Healed.HealthMax - float(Healed.Health)) - Healed.HealthToGive, 0.f)); //How much we actually gave as health to heal.

	Healed.GiveHealth(HealSum, Healed.HealthMax);

	// Tell them we're healing them
	PlayerController(Instigator.Controller).Speech('AUTO', 5, "");
	LastHealMessageTime = Level.TimeSeconds;

	if (MedicReward <= 0)
	{
		return;
	}
	
    class'TurboHealEventHandler'.static.BroadcastPawnSyringeHealed(Instigator, Healed, MedicReward);

	PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

	if ( PRI == None )
	{
		return;
	}

	if ( MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
	{
		KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward);
	}

	MedicReward = int((MedicReward / Healed.HealthMax) * 60.f);

	PRI.ReceiveRewardForHealing( MedicReward, Healed );

	if ( KFHumanPawn(Instigator) != none )
	{
		KFHumanPawn(Instigator).AlphaAmount = 255;
	}
}
