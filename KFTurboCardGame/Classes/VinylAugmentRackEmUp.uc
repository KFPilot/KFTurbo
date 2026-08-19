//Killing Floor Turbo VinylAugmentRackEmUp
//Augment for the Classic RackEmUp vinyl. Player headshots grant a stacking headshot damage bonus
//that expires when no headshots land for a while - the same behavior as the Rack Em Up card.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylAugmentRackEmUp extends VinylAugmentReplicationInfo;

var int HeadshotCount;
var float HeadshotStackExpireTime;

var const float StackDuration;
var const float DamageBonusPerHeadshot;
var const int MaxStackCount;

//Client-side status icon state.
var float StatusRatio;
var float StatusNumberScale;
var int StatusNumber;
var int LastKnownHeadshotCount;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		HeadshotCount, HeadshotStackExpireTime;
}

function NotifyPlayerHeadshot(TurboPlayerController Player, KFMonster HitMonster, class<DamageType> DamageType)
{
	HeadshotCount++;
	HeadshotStackExpireTime = Level.TimeSeconds + StackDuration;
	Enable('Tick');
	ForceNetUpdate();
}

function Tick(float DeltaTime)
{
	if (HeadshotCount == 0)
	{
		Disable('Tick');
		return;
	}

	if (Level.TimeSeconds >= HeadshotStackExpireTime)
	{
		HeadshotCount = 0;
		HeadshotStackExpireTime = 0.f;
		ForceNetUpdate();
		Disable('Tick');
	}
}

function float GetHeadshotDamageMultiplier(KFPlayerReplicationInfo KFPRI, KFPawn Pawn, class<DamageType> DamageType)
{
	return 1.f + (float(Min(HeadshotCount, MaxStackCount)) * DamageBonusPerHeadshot);
}

simulated function TickStatusIcon(TurboCardOverlay CardOverlay, TurboPlayerCardCustomInfo PlayerCustomInfo, float DeltaTime)
{
	if (HeadshotCount != LastKnownHeadshotCount)
	{
		StatusRatio = 1.f;
		StatusNumberScale = 1.66f;
		LastKnownHeadshotCount = HeadshotCount;

		//If the stacks expire, it shouldn't immediately show 0 on the icon.
		if (HeadshotCount != 0)
		{
			StatusNumber = HeadshotCount;
		}
	}

	if (StatusRatio > 0.0001f)
	{
		StatusNumberScale = Lerp(DeltaTime * 4.f, StatusNumberScale, 1.f);

		if (CardOverlay.ServerTimeActor != None && CardOverlay.ServerTimeActor.GetServerTimeSeconds() > HeadshotStackExpireTime)
		{
			StatusRatio -= DeltaTime;
		}
	}
}

//Draws the same stack count and duration icon the Rack Em Up card does.
simulated function bool DrawStatusIcon(TurboCardOverlay CardOverlay, TurboPlayerCardCustomInfo PlayerCustomInfo, Canvas Canvas, float DrawX, float DrawY, float DrawHeight)
{
	if (StatusRatio > 0.003f)
	{
		PlayerCustomInfo.DrawCardInfoNumberProgress(Canvas, Texture'KFTurboCardGame.UI.RackEmUpIcon_D', GetStackPercentDuration(CardOverlay), StatusNumber,
			DrawX, DrawY, DrawHeight, StatusRatio, StatusNumberScale);
		return true;
	}

	return false;
}

simulated function float GetStackPercentDuration(TurboCardOverlay CardOverlay)
{
	if (CardOverlay.ServerTimeActor == None || HeadshotCount == 0 || HeadshotStackExpireTime == 0.f)
	{
		return 0.f;
	}

	return FClamp((HeadshotStackExpireTime - CardOverlay.ServerTimeActor.GetServerTimeSeconds()) / StackDuration, 0.f, 1.f);
}

defaultproperties
{
	bWantsHeadshotDamageMultiplier=true
	bWantsPlayerHeadshotEvents=true
	bHasStatusIcon=true
	bWantsStatusIconTick=true

	StackDuration=10.f
	DamageBonusPerHeadshot=0.05f
	MaxStackCount=10
}
