//Killing Floor Turbo ZoneModifierManager
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class FogManager extends Info;

struct ZoneInfoEntry
{
    var ZoneInfo Zone;
    var bool bOriginalDistanceFog;
    var bool bOriginalClearToFogColor;
    var Color OriginalFogColor;
    var float OriginalFogStart;
    var float OriginalFogEnd;
};
var array<ZoneInfoEntry> ZoneInfoList;
var array<ZoneInfoEntry> SkyZoneInfoList;

struct PhysicsVolumeEntry
{
    var PhysicsVolume Volume;
    var bool bOriginalDistanceFog;
    var Color OriginalFogColor;
    var float OriginalFogStart;
    var float OriginalFogEnd;
};
var array<PhysicsVolumeEntry> PhysicsVolumeList;

var Color TargetFogColor;
var float TargetFogDistanceStart;
var float TargetFogDistanceEnd;

var bool bHasPendingFogChange;
var Color PendingTargetFogColor;
var float PendingTargetFogDistanceStart;
var float PendingTargetFogDistanceEnd;

var float FadeRate;
var float FadeRatio;

enum EFogState
{
    Original,
    FadingToTarget,
    Target,
    FadingToOriginal
};
var EFogState FogState;

static final function FogManager GetOrCreateFogManager(Actor Context)
{
    local FogManager Manager;
    
    if (Context == None)
    {
        return None;
    }

    foreach Context.DynamicActors(class'FogManager', Manager)
    {
        return Manager;
    }

    return Context.Spawn(class'FogManager', Context);
}

simulated function PostBeginPlay()
{
    local FogManager Other;

    Super.PostBeginPlay();

    foreach DynamicActors(class'FogManager', Other)
    {
        if (Other == Self)
        {
            continue;
        }

        Error("More than one FogManager was created!");
        LifeSpan = 0.1f;
        return;
    }

    Disable('Tick');
}

auto state Initialize
{
    simulated function Tick(float DeltaTime) {}

    simulated function SetFog(Color InFogColor, optional float InFogStart, optional float InFogEnd, optional float InFadeRate)
    {
        if (FadeRate > 0.f)
        {
            FadeRate = InFadeRate;
        }
        else
        {
            FadeRate = default.FadeRate;
        }

        bHasPendingFogChange = true;
        PendingTargetFogColor = InFogColor;
        PendingTargetFogDistanceStart = InFogStart;
        PendingTargetFogDistanceEnd = InFogEnd;
    }

Begin:
    Sleep(0.1f);
    CollectAllZoneInfos();
    Sleep(0.1f);
    CollectAllPhysicsVolumes();
    Sleep(0.1f);
    GotoState('Ready');
}

state Ready
{
Begin:
    if (bHasPendingFogChange)
    {
        ConsumePendingFogChange();
    }
}

simulated function CollectAllZoneInfos()
{
	local ZoneInfo ZoneInfo;
    local ZoneInfoEntry Entry;
    local int Index;

	foreach AllActors(class'ZoneInfo', ZoneInfo)
	{
        Index = ZoneInfoList.Length;
        Entry.Zone = ZoneInfo;
        Entry.bOriginalDistanceFog = ZoneInfo.bDistanceFog;
        Entry.bOriginalClearToFogColor = ZoneInfo.bClearToFogColor;
        Entry.OriginalFogColor = ZoneInfo.DistanceFogColor;
        Entry.OriginalFogStart = ZoneInfo.DistanceFogStart;
        Entry.OriginalFogEnd = ZoneInfo.DistanceFogEnd;

        if (SkyZoneInfo(ZoneInfo) == None)
        {
            ZoneInfoList[ZoneInfoList.Length] = Entry;
        }
        else
        {
            SkyZoneInfoList[SkyZoneInfoList.Length] = Entry;
        }
	}
}

simulated function CollectAllPhysicsVolumes()
{
	local PhysicsVolume Volume;
    local PhysicsVolumeEntry Entry;

	foreach AllActors(class'PhysicsVolume', Volume)
	{
        if (!Volume.bDistanceFog)
        {
            continue;
        }

        Entry.OriginalFogColor = Volume.DistanceFogColor;
        Entry.OriginalFogStart = Volume.DistanceFogStart;
        Entry.OriginalFogEnd = Volume.DistanceFogEnd;
        PhysicsVolumeList[PhysicsVolumeList.Length] = Entry;
	}
}

simulated function SetFog(Color InFogColor, float InFogStart, float InFogEnd, optional float InFadeRate)
{
    if (FadeRate > 0.f)
    {
        FadeRate = InFadeRate;
    }
    else
    {
        FadeRate = default.FadeRate;
    }

    bHasPendingFogChange = true;
    PendingTargetFogColor = InFogColor;
    PendingTargetFogDistanceStart = InFogStart;
    PendingTargetFogDistanceEnd = InFogEnd;

    if (FogState == Original)
    {
        ConsumePendingFogChange();
        return;
    }

    if (FogState == FadingToOriginal)
    {
        return;
    }

    if (FogState == Target || FogState == FadingToTarget)
    {
        FogState = FadingToOriginal;
    }
}

simulated function ClearFog(optional float InFadeRate)
{
    bHasPendingFogChange = false;
    if (FogState == Original)
    {
        return;
    }

    if (FadeRate > 0.f)
    {
        FadeRate = InFadeRate;
    }
    else
    {
        FadeRate = default.FadeRate;
    }

    FogState = FadingToOriginal;
    NotifyUpdatePending();
}

simulated function ConsumePendingFogChange()
{
    bHasPendingFogChange = false;
    TargetFogColor = PendingTargetFogColor;
    TargetFogDistanceStart = PendingTargetFogDistanceStart;
    TargetFogDistanceEnd = PendingTargetFogDistanceEnd;
    
    FogState = FadingToTarget;
    NotifyUpdatePending();
}

simulated function NotifyUpdatePending()
{
    Enable('Tick');
}

simulated function Tick(float DeltaTime)
{
    if (bHasPendingFogChange && FogState == Original)
    {
        ConsumePendingFogChange();
    }

    if (FogState == FadingToTarget)
    {
        FadeFogToTarget(DeltaTime);
    }
    else if (FogState == FadingToOriginal)
    {
        FadeFogToOriginal(DeltaTime);
    }
    else
    {
        Disable('Tick');
    }
}

simulated function FadeFogToTarget(float DeltaTime)
{
    local int Index;

    FadeRatio = Lerp(DeltaTime * FadeRate, 0.f, 1.f);
    if (FadeRatio > 0.999f)
    {
        FadeRatio = 1.f;
    }

    for (Index = ZoneInfoList.Length - 1; Index >= 0; Index--)
    {
        ZoneInfoList[Index].Zone.bDistanceFog = true;
        //We can't predict how skyboxes and fake backdrop are setup on maps so just override bClearToFogColor to true if we're specifying a custom fog.
        ZoneInfoList[Index].Zone.bClearToFogColor = true;
        FadeZone(ZoneInfoList[Index], FadeRatio, TargetFogDistanceStart, TargetFogDistanceEnd);
    }
    
    for (Index = SkyZoneInfoList.Length - 1; Index >= 0; Index--)
    {
        SkyZoneInfoList[Index].Zone.bDistanceFog = true;
        SkyZoneInfoList[Index].Zone.bClearToFogColor = true;
        FadeZone(ZoneInfoList[Index], FadeRatio, -128.f, 4.f);
    }
    
    for (Index = PhysicsVolumeList.Length - 1; Index >= 0; Index--)
    {
        PhysicsVolumeList[Index].Volume.bDistanceFog = true;
        FadeVolume(PhysicsVolumeList[Index], FadeRatio, TargetFogDistanceStart, TargetFogDistanceEnd);
    }

    if (FadeRatio >= 1.f)
    {
        FogState = Original;
    }
}

simulated function FadeFogToOriginal(float DeltaTime)
{
    local int Index;

    FadeRatio = Lerp(DeltaTime * FadeRate, 1.f, 0.f);
    if (FadeRatio < 0.001f)
    {
        FadeRatio = 0.f;
    }

    for (Index = ZoneInfoList.Length - 1; Index >= 0; Index--)
    {
        ZoneInfoList[Index].Zone.bDistanceFog = true;
        //We can't predict how skyboxes and fake backdrop are setup on maps so just override bClearToFogColor to true if we're specifying a custom fog.
        ZoneInfoList[Index].Zone.bClearToFogColor = true;
        FadeZone(ZoneInfoList[Index], FadeRatio, TargetFogDistanceStart, TargetFogDistanceEnd);
    }
    
    for (Index = SkyZoneInfoList.Length - 1; Index >= 0; Index--)
    {
        SkyZoneInfoList[Index].Zone.bDistanceFog = true;
        SkyZoneInfoList[Index].Zone.bClearToFogColor = true;
        FadeZone(SkyZoneInfoList[Index], FadeRatio, -128.f, 4.f);
    }
    
    for (Index = PhysicsVolumeList.Length - 1; Index >= 0; Index--)
    {
        PhysicsVolumeList[Index].Volume.bDistanceFog = true;
        FadeVolume(PhysicsVolumeList[Index], FadeRatio, TargetFogDistanceStart, TargetFogDistanceEnd);
    }
    
    if (FadeRatio > 0.f)
    {
        return;
    }

    for (Index = ZoneInfoList.Length - 1; Index >= 0; Index--)
    {
        ZoneInfoList[Index].Zone.bDistanceFog = ZoneInfoList[Index].bOriginalDistanceFog;
        ZoneInfoList[Index].Zone.bClearToFogColor = ZoneInfoList[Index].bOriginalClearToFogColor;
    }
    
    for (Index = SkyZoneInfoList.Length - 1; Index >= 0; Index--)
    {
        SkyZoneInfoList[Index].Zone.bDistanceFog = SkyZoneInfoList[Index].bOriginalDistanceFog;
        SkyZoneInfoList[Index].Zone.bClearToFogColor = SkyZoneInfoList[Index].bOriginalClearToFogColor;
    }
    
    for (Index = PhysicsVolumeList.Length - 1; Index >= 0; Index--)
    {
        PhysicsVolumeList[Index].Volume.bDistanceFog = PhysicsVolumeList[Index].bOriginalDistanceFog;
    }

    FogState = Original;
}

final simulated function FadeZone(ZoneInfoEntry Entry, float Ratio, float TargetStart, float TargetEnd)
{
    Entry.Zone.DistanceFogStart = Lerp(Ratio, Entry.Zone.DistanceFogStart, TargetStart);
    Entry.Zone.DistanceFogEnd = Lerp(Ratio, Entry.Zone.DistanceFogEnd, TargetEnd);
    Entry.Zone.DistanceFogColor = InterpFogColor(Ratio, Entry.OriginalFogColor, TargetFogColor);
}

final simulated function FadeVolume(PhysicsVolumeEntry Entry, float Ratio, float TargetStart, float TargetEnd)
{
    Entry.Volume.DistanceFogStart = Lerp(Ratio, Entry.OriginalFogStart, TargetStart);
    Entry.Volume.DistanceFogEnd = Lerp(Ratio, Entry.OriginalFogEnd, TargetEnd);
    Entry.Volume.DistanceFogColor = InterpFogColor(Ratio, Entry.OriginalFogColor, TargetFogColor);
}

static final function Color InterpFogColor(float Alpha, Color X, Color Y)
{
    Alpha = FClamp(Alpha, 0.f, 1.f);
    X.R = Round(Lerp(Alpha, X.R, Y.R));
    X.G = Round(Lerp(Alpha, X.G, Y.G));
    X.B = Round(Lerp(Alpha, X.B, Y.B));
    X.A = Round(Lerp(Alpha, X.A, Y.A));
    return X;
}

defaultproperties
{
    RemoteRole=ROLE_None
    FadeRate=2.f

    FogState=Original
}