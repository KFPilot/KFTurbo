//Killing Floor Turbo TurboPlayerCardCustomInfo
//Contains per-player info for KFTurbo's Card Game.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCardCustomInfo extends TurboPlayerCustomInfo;

var ServerTimeActor ServerTimeActor;
var int FireCounter;

var int CheatDeathWave;
var float CheatDeathTime;
var const float CheatDeathGracePeriod;
var const int CheatDeathWaveCooldown;

var int SubstituteDamageCount;
var const int SubstituteDamageCountBase;
var float SubstituteDamageTime;

var float CriticalHitTime;
var float PerpetualCriticalHitStartTime;
var const float PerpetualCriticalHitTime;

var int NonCriticalHitCount;

var class<CriticalHitEffect> HitEffectList[4];

var float GrenadeThrowTime;
var const float GrenadeBoostTime;

var float HealBoostTime;
var const float HealBoostBoostTime;

var int RackEmUpHeadshotCount;
var const float RackEmUpStackDuration;
var float RackEmUpHeadshotStackExpireTime;

var float LastDropWeaponTime;
var float MinDropWeaponTime;

var int StunningHitFireCounter;

var float MeleeWeaponHoldTime;
var float LastFreezeTagEvaluation;
var const float FreezeTagTimeUntilSlow;
var const float FreezeTagTimeUntilFreeze;

var int BleedCount;
var float NextBleedTime;

var private TurboCardOverlay CachedTurboCardOverlay;

const MARKED_FOR_DEATH = 1;
const NO_REST_FOR_THE_WICKED = 2;
var int PlayerFlags; //Pack binary states in here.

replication
{
    reliable if (Role == ROLE_Authority)
        GrenadeThrowTime, HealBoostTime, RackEmUpHeadshotCount, RackEmUpHeadshotStackExpireTime, CheatDeathWave,
		SubstituteDamageCount, BleedCount, NextBleedTime, PlayerFlags;

	reliable if (Role == ROLE_Authority)
        ClientCriticalHit;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(0.1f, false);
}

simulated final function TurboCardOverlay GetTurboCardOverlay()
{
	if (PlayerTPRI == None)
	{
		return None;
	}

	if (CachedTurboCardOverlay == None)
	{
		CachedTurboCardOverlay = class'TurboCardOverlay'.static.FindCardOverlay(PlayerController(PlayerTPRI.Owner));
	}

	return CachedTurboCardOverlay;
}

simulated function Timer()
{
	if (TurboGameReplicationInfo(Level.GRI) != None)
	{
		ServerTimeActor = TurboGameReplicationInfo(Level.GRI).ServerTimeActor;
	}
	
	if (ServerTimeActor != None)
	{
		return;
	}

	SetTimer(0.1f, false);
}

simulated function Tick(float DeltaTime)
{
	local bool bNeedsTick;
	bNeedsTick = false;
	
	Super.Tick(DeltaTime);

	if (!bRegistered)
	{
		return;
	}

	if (Level.NetMode != NM_DedicatedServer)
	{
		if (Role != ROLE_Authority)
		{
			return;
		}
	}

	if (RackEmUpHeadshotCount != 0)
	{
		if (RackEmUpHeadshotStackExpireTime > Level.TimeSeconds)
		{
			bNeedsTick = true;
		}
		else
		{
			ResetPlayerHeadshot();
		}
	}

	if (!bNeedsTick)
	{
		Disable('Tick');
	}
	else
	{
		Enable('Tick');
	}
}

simulated function float UpdateFreezeTagMoveSpeed(KFWeapon Weapon)
{
	local float TimeSinceWeaponHoldTime;

	LastFreezeTagEvaluation = Level.TimeSeconds;

	if (Weapon == None || Weapon.bMeleeWeapon)
	{
		MeleeWeaponHoldTime = Level.TimeSeconds;
		ForceNetUpdate();
		return 1.f;
	}

	TimeSinceWeaponHoldTime = FMax(Level.TimeSeconds - MeleeWeaponHoldTime, 0.f);
	if (TimeSinceWeaponHoldTime < FreezeTagTimeUntilSlow)
	{
		return 1.f;
	}

	TimeSinceWeaponHoldTime -= FreezeTagTimeUntilSlow;
	if (TimeSinceWeaponHoldTime >= FreezeTagTimeUntilFreeze)
	{
		return 0.0001f;
	}

	return Lerp(TimeSinceWeaponHoldTime / FreezeTagTimeUntilFreeze, 1.f, 0.0001f);
}

final simulated function bool CanCheatDeath()
{
	return CheatDeathWave == -1 || (CheatDeathWave + CheatDeathWaveCooldown <= InvasionGameReplicationInfo(Level.GRI).WaveNumber);
}

//Doesn't use ServerTimeActor because this is only used on server.
final function bool IsInCheatDeathGracePeriod()
{
	return CheatDeathTime > 0.f && Level.TimeSeconds < CheatDeathTime;
}

final simulated function SetCheatDeathWave(int Wave)
{
	CheatDeathWave = Wave;
    CheatDeathTime = Level.TimeSeconds + CheatDeathGracePeriod;
	ForceNetUpdate();
}

final function SetMarkedForDeath(bool bEnable)
{
	if (bEnable)
	{
		PlayerFlags = MARKED_FOR_DEATH | PlayerFlags;
	}
	else
	{
		PlayerFlags = (~MARKED_FOR_DEATH) & PlayerFlags;
	}
	
	ForceNetUpdate();
}

final simulated function bool IsMarkedForDeath()
{
	return (MARKED_FOR_DEATH & PlayerFlags) != 0;
}

final function SetNoRestForTheWickedActive(bool bEnable)
{
	if (bEnable)
	{
		PlayerFlags = NO_REST_FOR_THE_WICKED | PlayerFlags;
	}
	else
	{
		PlayerFlags = (~NO_REST_FOR_THE_WICKED) & PlayerFlags;
	}

	ForceNetUpdate();
}

final simulated function bool IsNoRestForTheWickedActive()
{
	return (NO_REST_FOR_THE_WICKED & PlayerFlags) != 0;
}

final function bool AttemptSubstituteDamage()
{
	//Block all damage for the frame.
	if (SubstituteDamageTime == Level.TimeSeconds)
	{
		return true;
	}

	if (SubstituteDamageCount == 0)
	{
		return false;
	}

	SubstituteDamageTime = Level.TimeSeconds;
	SubstituteDamageCount--;
	ForceNetUpdate();
	return true;
}

final function ResetSubstituteDamage()
{
	SubstituteDamageCount = SubstituteDamageCountBase;
}

final simulated function bool IsInPerpetualCriticalHitTime()
{
	if (ServerTimeActor == None || PerpetualCriticalHitStartTime <= 0.f)
	{
		return false;
	}
	
	return ServerTimeActor.GetServerTimeSeconds() < PerpetualCriticalHitStartTime + PerpetualCriticalHitTime;
}

final function AttemptGrantPerpetualCriticalHit()
{
	PerpetualCriticalHitStartTime = Level.TimeSeconds;
	ForceNetUpdate();
}

final function PlayerFire(TurboPlayerController Player, WeaponFire FireMode)
{
	FireCounter++;
	if (FireCounter < 0)
	{
		FireCounter = 0;
		StunningHitFireCounter = -1;
	}
}

final function PlayerThrewGrenade()
{
	GrenadeThrowTime = Level.TimeSeconds;
	ForceNetUpdate();
}

final simulated function bool IsInGrenadeBuffTime()
{
	return ServerTimeActor != None && GrenadeThrowTime > 0.f && (GrenadeThrowTime + GrenadeBoostTime > ServerTimeActor.GetServerTimeSeconds());
}

final function ApplyHealingBoost()
{
	HealBoostTime = Level.TimeSeconds;
	ForceNetUpdate();
}

final simulated function bool IsInHealBoostTime()
{
	return ServerTimeActor != None && HealBoostTime > 0.f && (HealBoostTime + HealBoostBoostTime > ServerTimeActor.GetServerTimeSeconds());
}

final function PlayerScoredHeadshot()
{
	RackEmUpHeadshotCount++;
	RackEmUpHeadshotStackExpireTime = Level.TimeSeconds + RackEmUpStackDuration;
	Enable('Tick');
	ForceNetUpdate();
}

final simulated function float GetPlayerHeadshotBonus()
{
	return 1.f + (float(Min(RackEmUpHeadshotCount, 10)) * 0.05f);
}

final function ResetPlayerHeadshot()
{
	RackEmUpHeadshotCount = 0;
	RackEmUpHeadshotStackExpireTime = 0.f;
	ForceNetUpdate();
}

final simulated function bool CanPlayerDropWeapon()
{
	return Level.TimeSeconds > LastDropWeaponTime + MinDropWeaponTime;
}

final simulated function PlayerDroppedWeapon()
{
	LastDropWeaponTime = Level.TimeSeconds;
}

final function SendClientCriticalHit(Vector Location, int CriticalHitCount)
{
	if (Level.TimeSeconds - CriticalHitTime < 0.25f)
	{
		return;
	}

	ClientCriticalHit(Location, CriticalHitCount);
	CriticalHitTime = Level.TimeSeconds;
}

simulated function ClientCriticalHit(Vector Location, int CriticalHitCount)
{
    if (Level.NetMode == NM_DedicatedServer || CriticalHitCount <= 0 || PlayerTPRI == None)
    {
        return;
    }

    Spawn(HitEffectList[Min(CriticalHitCount - 1, ArrayCount(HitEffectList) - 1)], PlayerTPRI.Owner,, Location);
}

final function bool AttemptStunningHit()
{
	if (StunningHitFireCounter >= FireCounter)
	{
		return false;
	}

	StunningHitFireCounter = FireCounter;
	return true;
}

final function UpdateBleedCounter(int Count, float Time)
{
	BleedCount = Count;
	NextBleedTime = Time;
	ForceNetUpdate();
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	if (!IsLocallyOwned() && GetTurboCardOverlay() != None)
	{
		return;
	}

	GetTurboCardOverlay().OnPlayerCardInfoUpdate();
}

static final function SetupOffset(float DrawX, float DrawY, float IconX, out float OffsetX, out float OffsetY, out int Index)
{
	OffsetX = DrawX - ((IconX * 1.2f) * (Index % 5)); 
	OffsetY = DrawY - (float(Index / 6) * (IconX * 1.2f));
	Index++;
}

simulated final function DrawBox(Canvas C, Material Material, float SizeX, float SizeY)
{
	C.DrawTile(Material, SizeX, SizeY, 0.f, 0.f, Material.MaterialUSize(), Material.MaterialVSize());
}

//DrawX is an out param so the next icon to the left knows where to draw.
simulated function DrawCardInfoIcon(Canvas C, Material Icon, float DrawX, float DrawY, float DrawHeight, float Ratio)
{
	C.SetPos(DrawX, DrawY);
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(0, 0, 0, 80.f * Ratio);
	DrawBox(C, class'TurboHUDKillingFloor'.default.WhiteMaterial, DrawHeight, DrawHeight);
	
	C.SetPos(DrawX, DrawY);
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 255, 255, 255.f * Ratio);
	DrawBox(C, Icon, DrawHeight, DrawHeight);
}

simulated function DrawCardInfoProgress(Canvas C, Material Icon, float Progress, float DrawX, float DrawY, float DrawHeight, float Ratio)
{
	DrawCardInfoIcon(C, Icon, DrawX, DrawY, DrawHeight, Ratio);

	if (Progress <= 0.001f)
	{
		return;
	}

	C.SetPos(DrawX, DrawY + (DrawHeight * 0.8));
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 0, 0, 180.f * Ratio);
	DrawBox(C, class'TurboHUDKillingFloor'.default.WhiteMaterial, DrawHeight * Progress, DrawHeight * 0.2f);
}

simulated function DrawCardInfoNumberProgress(Canvas C, Material Icon, float Progress, coerce string String, float DrawX, float DrawY, float DrawHeight, float Ratio, float TextScale)
{
	local float TextSizeX, TextSizeY;
	local float OriginalTextScale;

	DrawCardInfoProgress(C, Icon, Progress, DrawX, DrawY, DrawHeight, Ratio);

	if (String == "")
	{
		return;
	}

	OriginalTextScale = C.FontScaleX;
	C.FontScaleX *= TextScale;
	C.FontScaleY = C.FontScaleX;
	C.TextSize(String, TextSizeX, TextSizeY);
	DrawX = ((DrawX + DrawHeight) - TextSizeX) + (DrawHeight * 0.1f);
	DrawY = DrawY - (DrawHeight * 0.2f);

	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(0, 0, 0, 120.f * Ratio);
	C.SetPos(DrawX + (TextSizeY * 0.025f), DrawY + (TextSizeY * 0.025f));
	C.DrawText(String);
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255.f, 0, 0, 240.f * Ratio);
	C.SetPos(DrawX, DrawY);
	C.DrawText(String);

	C.FontScaleX = OriginalTextScale;
	C.FontScaleY = OriginalTextScale;
}

final simulated function int GetWavesUntilCheatDeath()
{
	if (InvasionGameReplicationInfo(Level.GRI) == None)
	{
		return 1;
	}

	return Max((CheatDeathWave + CheatDeathWaveCooldown) - InvasionGameReplicationInfo(Level.GRI).WaveNumber, 1);
}

final simulated function float GetRackEmUpStackPercentDuration()
{
	if (ServerTimeActor == None || RackEmUpHeadshotCount == 0 || RackEmUpHeadshotStackExpireTime == 0.f)
	{
		return 0.f;
	}

	return FClamp((RackEmUpHeadshotStackExpireTime - ServerTimeActor.GetServerTimeSeconds()) / RackEmUpStackDuration, 0.f, 1.f); 
}

final simulated function float GetHealBoostPercentDuration()
{
	if (ServerTimeActor == None || HealBoostTime == 0.f)
	{
		return 0.f;
	}

	return Lerp(FClamp((ServerTimeActor.GetServerTimeSeconds() - HealBoostTime) / HealBoostBoostTime, 0.f, 1.f), 1.f, 0.f);
}

final simulated function float GetGrenadeThrowPercentDuration()
{
	if (ServerTimeActor == None || GrenadeThrowTime == 0.f)
	{
		return 0.f;
	}

	return Lerp(FClamp((ServerTimeActor.GetServerTimeSeconds() - GrenadeThrowTime) / GrenadeBoostTime, 0.f, 1.f), 1.f, 0.f); 
}

final simulated function float GetPerpetualCriticalPercentDuration()
{
	if (ServerTimeActor == None || PerpetualCriticalHitStartTime == 0.f)
	{
		return 0.f;
	}

	return Lerp(FClamp((ServerTimeActor.GetServerTimeSeconds() - PerpetualCriticalHitStartTime) / PerpetualCriticalHitTime, 0.f, 1.f), 1.f, 0.f); 
}

final simulated function float GetTimePercentUntilFreeze()
{
	return FClamp((Level.TimeSeconds - MeleeWeaponHoldTime) / FreezeTagTimeUntilSlow, 0.f, 1.f);
}

final simulated function float GetTimePercentUntilBleed()
{
	if (ServerTimeActor == None || NextBleedTime == 0.f)
	{
		return 0.f;
	}

	return Lerp(FClamp((NextBleedTime - ServerTimeActor.GetServerTimeSeconds()) / class'PlayerBleedActor'.default.BleedInterval, 0.f, 1.f), 1.f, 0.f);
}

defaultproperties
{
	CheatDeathWave=-1
	CheatDeathTime=-1.f
	CheatDeathGracePeriod=5.f
	CheatDeathWaveCooldown=2

	SubstituteDamageCount=0
	SubstituteDamageCountBase=10

	PerpetualCriticalHitStartTime=-1.f
	PerpetualCriticalHitTime=5.f

	NonCriticalHitCount=0
    
    HitEffectList(0)=class'CriticalHitEffect'
    HitEffectList(1)=class'CriticalHitEffectDouble'
    HitEffectList(2)=class'CriticalHitEffectTriple'
    HitEffectList(3)=class'CriticalHitEffectMax'

	GrenadeThrowTime=0.f
	GrenadeBoostTime=5.f

	HealBoostTime=0.f
	HealBoostBoostTime=5.f

	MinDropWeaponTime=0.f

	FreezeTagTimeUntilSlow=9.f
	FreezeTagTimeUntilFreeze=4.f

	RackEmUpStackDuration=10.f

	//Replicates now that the client has to be aware of certain properties on here.
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=false
    bOnlyRelevantToOwner=true
	bNetNotify=true
    NetUpdateFrequency=0.5
	
	bDisableTickOnRegister=false
}