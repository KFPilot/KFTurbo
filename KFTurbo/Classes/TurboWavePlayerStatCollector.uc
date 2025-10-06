//Killing Floor Turbo TurboWavePlayerStatCollector
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboWavePlayerStatCollector extends TurboPlayerStatCollectorBase;

var int Wave;
var class<TurboVeterancyTypes> Perk;

var int Kills, KillsFleshpound, KillsScrake;
var int DamageDone, DamageDoneFleshpound, DamageDoneScrake;

var int ShotsFired, ShotsHit, ShotsHeadshot;
var int MeleeSwings;

var int Reloads;

var int DamageTaken, HealingDone;

var int Deaths;

var KFTurboGameType GameType;

replication
{
	reliable if (Role == ROLE_Authority)
		Wave, Perk,
		Kills, KillsFleshpound, KillsScrake,
		DamageDone, DamageDoneFleshpound, DamageDoneScrake,
		ShotsFired, ShotsHit, ShotsHeadshot,
		MeleeSwings,
		Reloads,
		DamageTaken,
		HealingDone,
		Deaths;
}

function PushStats(TurboPlayerStatCollectorBase Source)
{
	local TurboWavePlayerStatCollector WaveStatsSource;
	WaveStatsSource = TurboWavePlayerStatCollector(Source);

	Perk = WaveStatsSource.Perk;
	Wave = WaveStatsSource.Wave;

	Kills = WaveStatsSource.Kills;
	KillsFleshpound = WaveStatsSource.KillsFleshpound;
	KillsScrake = WaveStatsSource.KillsScrake;

	DamageDone = WaveStatsSource.DamageDone;
	DamageDoneFleshpound = WaveStatsSource.DamageDoneFleshpound;
	DamageDoneScrake = WaveStatsSource.DamageDoneScrake;
	
	ShotsFired = WaveStatsSource.ShotsFired;
	ShotsHit = WaveStatsSource.ShotsHit;
	ShotsHeadshot = WaveStatsSource.ShotsHeadshot;

	MeleeSwings = WaveStatsSource.MeleeSwings;

	Reloads = WaveStatsSource.Reloads;
	
	DamageTaken = WaveStatsSource.DamageTaken;
	HealingDone = WaveStatsSource.HealingDone;
	Deaths = WaveStatsSource.Deaths;
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	if (PlayerTPRI != None)
	{
		Perk = class<TurboVeterancyTypes>(PlayerTPRI.ClientVeteranSkill);
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	GameType = KFTurboGameType(Level.Game);
	Wave = GameType.GetCurrentWaveNum();
}

final function bool ShouldCollectStats()
{
	return GameType != None && GameType.bWaveInProgress;
}

function IncrementKills(class<KFMonster> MonsterClass)
{
	if (!ShouldCollectStats())
	{
		return;
	}

	Kills++;

	if (class<MonsterFleshPound>(MonsterClass) != None)
	{
		KillsFleshpound++;
	}
	else if (class<MonsterScrake>(MonsterClass) != None)
	{
		KillsScrake++;
	}
}

function IncrementDamageDone(int Damage, class<KFMonster> MonsterClass)
{
	if (!ShouldCollectStats())
	{
		return;
	}

	DamageDone += Damage;

	if (class<MonsterFleshPound>(MonsterClass) != None)
	{
		DamageDoneFleshpound += Damage;
	}
	else if (class<MonsterScrake>(MonsterClass) != None)
	{
		DamageDoneScrake += Damage;
	}
}

function IncrementShotsFired()
{
	if (!ShouldCollectStats())
	{
		return;
	}

	ShotsFired++;
}

function IncrementShotsHit(bool bIsHeadshot)
{
	if (!ShouldCollectStats())
	{
		return;
	}

	ShotsHit++;
	
	if (bIsHeadshot)
	{
		ShotsHeadshot++;
	}
}

function IncrementMeleeSwings()
{
	if (!ShouldCollectStats())
	{
		return;
	}

	MeleeSwings++;
}

function IncrementReloads()
{
	if (!ShouldCollectStats())
	{
		return;
	}

	Reloads++;
}

function IncrementDamageTaken(int DamageAmount)
{
	if (!ShouldCollectStats())
	{
		return;
	}

	DamageTaken += DamageAmount;
}

function IncrementHealthHealed(int HealAmount)
{
	if (!ShouldCollectStats())
	{
		return;
	}

	HealingDone += HealAmount;
}

function OnDied(Controller Killer, class<DamageType> DamageType)
{
	if (!ShouldCollectStats())
	{
		return;
	}

	Deaths++;
}

defaultproperties
{
	PlayerStatReplicatorClass=class'TurboWavePlayerStatReplicator'
}