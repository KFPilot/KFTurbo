//Killing Floor Turbo TurboPlayerCardCustomInfo
//Contains per-player info for KFTurbo's Card Game.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerCardCustomInfo extends TurboPlayerCustomInfo;

var ServerTimeActor ServerTimeActor;
var int FireCounter;

var int CheatDeathWave, LastKnownCheatDeathWave;
var float CheatDeathTime;
var const float CheatDeathGracePeriod;
var const int CheatDeathWaveCooldown;
var float CheatDeathRatio;

var int NegateDamageCount;

var float CriticalHitTime, LastKnownCriticalHitTime;
var float PerpetualCriticalHitStartTime;
var const float PerpetualCriticalHitTime;
var float PerpetualCriticalHitRatio;

var int NonCriticalHitCount, LastKnownNonCriticalHitCount;
var float NonCriticalHitRatio;

var class<CriticalHitEffect> HitEffectList[4];

var float GrenadeThrowTime, LastKnownGrenadeThrowTime;
var const float GrenadeBoostTime;
var float GrenadeBoostRatio;

var float HealBoostTime, LastKnownHealBoostTime;
var const float HealBoostBoostTime;
var float HealBoostRatio;

var int RackEmUpHeadshotCount, LastKnownRackEmUpHeadshotCount;
var const float RackEmUpStackDuration;
var float RackEmUpHeadshotStackExpireTime;
var float RackEmUpRatio;

var float LastDropWeaponTime;
var float MinDropWeaponTime;

var int StunningHitFireCounter;

var float MeleeWeaponHoldTime, LastKnownMeleeWeaponHoldTime;

var const float FreezeTagTimeUntilSlow;
var const float FreezeTagTimeUntilFreeze;

var Material CheatDeathIcon;
var Material CritBoostIcon;
var Material HealBoostIcon;
var Material NadeBoostIcon;
var Material RackEmUpIcon;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        GrenadeThrowTime, HealBoostTime, RackEmUpHeadshotCount, RackEmUpHeadshotStackExpireTime, CheatDeathWave,
		MeleeWeaponHoldTime, CriticalHitTime;

	reliable if (Role == ROLE_Authority)
        ClientCriticalHit;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(0.1f, false);
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
		TickDraw(DeltaTime);

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
	return CheatDeathWave == 0 || (CheatDeathWave + CheatDeathWaveCooldown <= Level.Game.GetCurrentWaveNum());
}

//Doesn't use ServerTimeActor because this is only used on server.
final function bool IsInCheatDeathGracePeriod()
{
	return CheatDeathTime > 0.f && Level.TimeSeconds < CheatDeathTime;
}

final function SetCheatDeathWave(int Wave)
{
	CheatDeathWave = Wave;
    CheatDeathTime = Level.TimeSeconds + CheatDeathGracePeriod;
	ForceNetUpdate();
}

final function bool IsInPerpetualCriticalHitTime()
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

final function PlayerHealed()
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

simulated function PostNetReceive()
{
	Super.PostNetReceive();

	if (!IsLocallyOwned())
	{
		return;
	}
	
	if (CheatDeathWave > LastKnownCheatDeathWave)
	{
		CheatDeathRatio = 1.f;
	}

	if (CriticalHitTime > LastKnownCriticalHitTime)
	{
		PerpetualCriticalHitRatio = 1.f;
	}

	if (GrenadeThrowTime > LastKnownGrenadeThrowTime)
	{
		GrenadeBoostRatio = 1.f;
	}

	if (HealBoostTime > LastKnownHealBoostTime)
	{
		HealBoostRatio = 1.f;
	}

	if (RackEmUpHeadshotCount > LastKnownRackEmUpHeadshotCount)
	{
		RackEmUpRatio = 1.f;
	}
}

simulated function TickDraw(float DeltaTime)
{
	if (!IsLocallyOwned() || ServerTimeActor == None)
	{
		return;
	}

	DeltaTime *= 0.5f;

	if (PerpetualCriticalHitRatio > 0.0001f && ServerTimeActor.GetServerTimeSeconds() > (PerpetualCriticalHitStartTime + PerpetualCriticalHitTime))
	{
		PerpetualCriticalHitRatio = Lerp(DeltaTime, PerpetualCriticalHitRatio, 0.f);
	}

	if (GrenadeBoostRatio > 0.0001f && ServerTimeActor.GetServerTimeSeconds() > (GrenadeThrowTime + GrenadeBoostTime))
	{
		GrenadeBoostRatio = Lerp(DeltaTime, GrenadeBoostRatio, 0.f);
	}

	if (HealBoostRatio > 0.0001f && ServerTimeActor.GetServerTimeSeconds() > (HealBoostTime + HealBoostBoostTime))
	{
		HealBoostRatio = Lerp(DeltaTime, HealBoostRatio, 0.f);
	}

	if (RackEmUpRatio > 0.0001f && ServerTimeActor.GetServerTimeSeconds() > RackEmUpHeadshotStackExpireTime)
	{
		RackEmUpRatio = Lerp(DeltaTime, RackEmUpRatio, 0.f);
	}
	
	DeltaTime *= 0.25f;

	if (CheatDeathRatio > 0.0001f && CanCheatDeath())
	{
		CheatDeathRatio = Lerp(DeltaTime, CheatDeathRatio, 0.f);
	}
}

static final function SetupOffset(float DrawX, float DrawY, float IconX, out float OffsetX, out float OffsetY, out int Index)
{
	OffsetX = DrawX - ((IconX * 1.1f) * (Index % 5)); 
	OffsetY = DrawY - (float(Index / 6) * (IconX * 1.1f));
	Index++;
}

//DrawX and DrawY are the bottom right of the draw area.
//This is a pretty lame way to do this but I'd rather not implement a dynamic icon system.
simulated function DrawCardInfo(Canvas C, float DrawX, float DrawY, float DrawHeight, int BaseFontSize)
{
	local float OffsetX, OffsetY;
	local float TextSizeX, TextSizeY;
	local int Index;

	DrawHeight = FMin(DrawHeight, RackEmUpIcon.MaterialVSize());

	DrawX -= DrawHeight;
	DrawY -= DrawHeight;
	
	//Prepare text drawing in advance.
	C.Font = class'TurboHUDKillingFloor'.static.LoadBoldFontStatic(BaseFontSize - 2);
	C.TextSize("00", TextSizeX, TextSizeY);
	C.FontScaleX = (DrawHeight * 0.75f) / TextSizeY;
	C.FontScaleY = C.FontScaleX;

	if (CheatDeathRatio > 0.003f)
	{
		SetupOffset(DrawX, DrawY, DrawHeight, OffsetX, OffsetY, Index);
		DrawCardInfoNumberProgress(C, CheatDeathIcon, -1.f, GetWavesUntilCheatDeath(), OffsetX, OffsetY, DrawHeight, CheatDeathRatio);
	}
	
	if (RackEmUpRatio > 0.003f)
	{
		SetupOffset(DrawX, DrawY, DrawHeight, OffsetX, OffsetY, Index);
		DrawCardInfoNumberProgress(C, RackEmUpIcon, GetRackEmUpStackPercentDuration(), RackEmUpHeadshotCount, OffsetX, OffsetY, DrawHeight, RackEmUpRatio);
	}
	
	if (HealBoostRatio > 0.003f)
	{
		SetupOffset(DrawX, DrawY, DrawHeight, OffsetX, OffsetY, Index);
		DrawCardInfoProgress(C, HealBoostIcon, GetHealBoostPercentDuration(), OffsetX, OffsetY, DrawHeight, HealBoostRatio);
	}

	if (GrenadeBoostRatio > 0.003f)
	{
		SetupOffset(DrawX, DrawY, DrawHeight, OffsetX, OffsetY, Index);
		DrawCardInfoProgress(C, NadeBoostIcon, GetGrenadeThrowPercentDuration(), OffsetX, OffsetY, DrawHeight, GrenadeBoostRatio);
	}

	if (PerpetualCriticalHitRatio > 0.003f)
	{
		SetupOffset(DrawX, DrawY, DrawHeight, OffsetX, OffsetY, Index);
		DrawCardInfoProgress(C, CritBoostIcon, GetPerpetualCriticalPercentDuration(), OffsetX, OffsetY, DrawHeight, PerpetualCriticalHitRatio);
	}
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

	C.SetPos(DrawX, DrawY + (DrawHeight * 0.9));
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255, 0, 0, 180.f * Ratio);
	DrawBox(C, class'TurboHUDKillingFloor'.default.WhiteMaterial, DrawHeight * Progress, DrawHeight * 0.1f);
}

simulated function DrawCardInfoNumberProgress(Canvas C, Material Icon, float Progress, coerce string String, float DrawX, float DrawY, float DrawHeight, float Ratio)
{
	local float TextSizeX, TextSizeY;
	DrawCardInfoProgress(C, Icon, Progress, DrawX, DrawY, DrawHeight, Ratio);

	if (String == "")
	{
		return;
	}

	C.TextSize(String, TextSizeX, TextSizeY);
	DrawX = ((DrawX + DrawHeight) - TextSizeX) + (DrawHeight * 0.15f);
	DrawY = DrawY - (DrawHeight * 0.075f);

	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(0, 0, 0, 120.f * Ratio);
	C.SetPos(DrawX + (TextSizeY * 0.025f), DrawY + (TextSizeY * 0.025f));
	C.DrawText(String);
	C.DrawColor = class'TurboHUDOverlay'.static.MakeColor(255.f, 0, 0, 240.f * Ratio);
	C.SetPos(DrawX, DrawY);
	C.DrawText(String);
}

final simulated function int GetWavesUntilCheatDeath()
{
	if (KFGameReplicationInfo(Level.GRI) == None)
	{
		return 1;
	}

	return Max(KFGameReplicationInfo(Level.GRI).WaveNumber - (CheatDeathWave + CheatDeathWaveCooldown), 1);
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

	return FClamp((ServerTimeActor.GetServerTimeSeconds() - HealBoostTime) / HealBoostBoostTime, 1.f, 0.f); 
}

final simulated function float GetGrenadeThrowPercentDuration()
{
	if (ServerTimeActor == None || GrenadeThrowTime == 0.f)
	{
		return 0.f;
	}

	return FClamp((ServerTimeActor.GetServerTimeSeconds() - GrenadeThrowTime) / GrenadeBoostTime, 1.f, 0.f); 
}

final simulated function float GetPerpetualCriticalPercentDuration()
{
	if (ServerTimeActor == None || PerpetualCriticalHitStartTime == 0.f)
	{
		return 0.f;
	}

	return FClamp((ServerTimeActor.GetServerTimeSeconds() - PerpetualCriticalHitStartTime) / PerpetualCriticalHitTime, 1.f, 0.f); 
}

defaultproperties
{
	CheatDeathWave=-1
	CheatDeathTime=-1.f
	CheatDeathGracePeriod=5.f
	CheatDeathWaveCooldown=3

	NegateDamageCount=0

	PerpetualCriticalHitStartTime=-1.f
	PerpetualCriticalHitTime=5.f

	NonCriticalHitCount=0
    
    HitEffectList(0)=class'CriticalHitEffect'
    HitEffectList(1)=class'CriticalHitEffectDouble'
    HitEffectList(2)=class'CriticalHitEffectTriple'
    HitEffectList(3)=class'CriticalHitEffectMax'

	CheatDeathIcon=Texture'KFTurboCardGame.UI.CheatedDeathIcon_D'
	CritBoostIcon=Texture'KFTurboCardGame.UI.CritBoostIcon_D'
	HealBoostIcon=Texture'KFTurboCardGame.UI.HealBoostIcon_D'
	NadeBoostIcon=Texture'KFTurboCardGame.UI.NadeBoostIcon_D'
	RackEmUpIcon=Texture'KFTurboCardGame.UI.RackEmUpIcon_D'

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