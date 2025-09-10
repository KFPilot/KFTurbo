//Killing Floor Turbo TurboCardClientModifierRepLink
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardClientModifierRepLink extends TurboClientModifierReplicationLink
    hidecategories(Advanced,Display,Events,Object,Sound);

var(Turbo) float MonsterHeadSizeModifier;
var(Turbo) float StalkerDistractionModifier;
var(Turbo) float GroundFrictionModifier, LastGroundFrictionModifier;
var(Turbo) float WeaponBringUpSpeedModifier, LastWeaponBringUpSpeedModifier;
var(Turbo) float WeaponPutDownSpeedModifier, LastWeaponPutDownSpeedModifier;
var(Turbo) float ZedTimeWeaponBringUpSpeedModifier, LastZedTimeWeaponBringUpSpeedModifier;
var(Turbo) float ZedTimeWeaponPutDownSpeedModifier, LastZedTimeWeaponPutDownSpeedModifier;
var(Turbo) bool bBlackout, bLastKnownBlackout;

struct PhysicsVolumeEntry
{
    var PhysicsVolume Volume;
    var float OriginalGroundFriction;
};
var array<PhysicsVolumeEntry> PhysicsVolumeList;

struct ZoneInfoEntry
{
    var ZoneInfo Zone;
    var bool bIsSkyZone;
    var bool bOriginalDistanceFog;
    var bool bOriginalClearToFogColor;
    var color OriginalFogColor;
    var float OriginalFogStart;
    var float OriginalFogEnd;
};
var array<ZoneInfoEntry> ZoneInfoList;

//Where we will store bone scales.
enum EBoneScaleSlots
{
    Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten,
    Eleven, Twelve, Thirteen, Fourteen, Fifteen, Sixteen, Seventeen, Eighteen, Nineteen,
    SpecialL, SpecialR
};

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        StalkerDistractionModifier, MonsterHeadSizeModifier,
        GroundFrictionModifier,
        WeaponBringUpSpeedModifier, WeaponPutDownSpeedModifier,
        ZedTimeWeaponBringUpSpeedModifier, ZedTimeWeaponPutDownSpeedModifier,
        bBlackout;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    Disable('Tick');

    CollectAllPhysicsVolumes();
    CollectAllZoneInfos();
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    UpdatePhysicsVolumes();
    UpdateWeaponEquipSpeed();
    UpdateBlackout();
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    UpdatePhysicsVolumes();
    UpdateWeaponEquipSpeed();
    UpdateBlackout();
}

simulated function CollectAllPhysicsVolumes()
{
	local PhysicsVolume Volume;
    LastGroundFrictionModifier = GroundFrictionModifier;

	foreach AllActors(class'PhysicsVolume', Volume)
	{
		PhysicsVolumeList.Length = PhysicsVolumeList.Length + 1;
        PhysicsVolumeList[PhysicsVolumeList.Length - 1].Volume = Volume;
        PhysicsVolumeList[PhysicsVolumeList.Length - 1].OriginalGroundFriction = Volume.GroundFriction;
        Volume.GroundFriction *= GroundFrictionModifier;
	}
}

simulated function CollectAllZoneInfos()
{
	local ZoneInfo ZoneInfo;
    local int Index;
    LastGroundFrictionModifier = GroundFrictionModifier;

	foreach AllActors(class'ZoneInfo', ZoneInfo)
	{
        Index = ZoneInfoList.Length;
		ZoneInfoList.Length = Index + 1;
        ZoneInfoList[Index].Zone = ZoneInfo;
        ZoneInfoList[Index].bIsSkyZone = SkyZoneInfo(ZoneInfo) != None;
        ZoneInfoList[Index].bOriginalDistanceFog = ZoneInfo.bDistanceFog;
        ZoneInfoList[Index].bOriginalClearToFogColor = ZoneInfo.bClearToFogColor;
        ZoneInfoList[Index].OriginalFogColor = ZoneInfo.DistanceFogColor;
        ZoneInfoList[Index].OriginalFogStart = ZoneInfo.DistanceFogStart;
        ZoneInfoList[Index].OriginalFogEnd = ZoneInfo.DistanceFogEnd;
	}

    if (bBlackout)
    {
        UpdateBlackout();
    }
}

simulated function UpdatePhysicsVolumes()
{
    local int Index;

    if (GroundFrictionModifier == LastGroundFrictionModifier)
    {
        return;
    }

    LastGroundFrictionModifier = GroundFrictionModifier;
    for (Index = PhysicsVolumeList.Length - 1; Index >= 0; Index--)
    {
        PhysicsVolumeList[Index].Volume.GroundFriction = PhysicsVolumeList[Index].OriginalGroundFriction * GroundFrictionModifier;
    }
}

simulated function ModifyMonster(KFMonster Monster) 
{
    Super.ModifyMonster(Monster);

    if (MonsterHeadSizeModifier != 1.f) 
    {
        ApplyHeadSizeModification(Monster);
    }

    if (P_Stalker(Monster) != None)
    {
        ModifyStalker(P_Stalker(Monster));
    }
}

simulated function ApplyHeadSizeModification(KFMonster Monster)
{
    local float ExtCollisionHeightScale, ExtCollisionRadiusScale;

    if (Monster.MyExtCollision != None && Monster.MyExtCollision.Role != ROLE_Authority && MonsterHeadSizeModifier > 1.f)
    {
        ExtCollisionHeightScale = ((MonsterHeadSizeModifier - 1.f) * 0.5f) + 1.f;
        ExtCollisionRadiusScale = ((MonsterHeadSizeModifier - 1.f) * 0.25f) + 1.f;
        Monster.MyExtCollision.SetCollisionSize(Monster.MyExtCollision.CollisionRadius * ExtCollisionRadiusScale, Monster.MyExtCollision.CollisionHeight * ExtCollisionHeightScale);
    }
}

simulated function ModifyStalker(P_Stalker Monster)
{
    if (StalkerDistractionModifier != 1.f)
    {
        Monster.SetBoneScale(EBoneScaleSlots.SpecialL, StalkerDistractionModifier, 'CHR_RibcageBoob_L');
        Monster.SetBoneScale(EBoneScaleSlots.SpecialR, StalkerDistractionModifier, 'CHR_RibcageBoob_R');
    }
}


simulated function OnWeaponChange(KFWeapon CurrentWeapon, KFWeapon PendingWeapon)
{
    Super.OnWeaponChange(CurrentWeapon, PendingWeapon);
    
    ApplyEquipSpeedModifier(PendingWeapon);
}

simulated function UpdateWeaponEquipSpeed()
{
    local PlayerController PlayerController;
    local Pawn Pawn;
    local Inventory Inv;

    if (WeaponBringUpSpeedModifier == LastWeaponBringUpSpeedModifier && WeaponPutDownSpeedModifier == LastWeaponPutDownSpeedModifier)
    {
        return;
    }

    LastWeaponBringUpSpeedModifier = WeaponBringUpSpeedModifier;
    LastWeaponPutDownSpeedModifier = WeaponPutDownSpeedModifier;

    PlayerController = Level.GetLocalPlayerController();

    if (PlayerController == None)
    {
        return;
    }
    
    Pawn = PlayerController.Pawn;

    if (Pawn == None)
    {
        return;
    }
    
    Inv = Pawn.Inventory;

    for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
    {
        ApplyEquipSpeedModifier(KFWeapon(Inv));
    }    
}

simulated final function ApplyEquipSpeedModifier(KFWeapon Weapon)
{
    if (Weapon == None)
    {
        return;
    }

    Weapon.BringUpTime = Weapon.default.BringUpTime * WeaponBringUpSpeedModifier;
    Weapon.SelectAnimRate = Weapon.default.SelectAnimRate / WeaponBringUpSpeedModifier;
    
    Weapon.PutDownTime = Weapon.default.PutDownTime * WeaponPutDownSpeedModifier;
    Weapon.PutDownAnimRate = Weapon.default.PutDownAnimRate / WeaponPutDownSpeedModifier;

    if (Weapon.bDualWeapon && Level.TimeDilation < 0.75f)
    {
        Weapon.PutDownTime *= ZedTimeWeaponBringUpSpeedModifier;
        Weapon.SelectAnimRate /= ZedTimeWeaponBringUpSpeedModifier;

        Weapon.PutDownTime *= ZedTimeWeaponPutDownSpeedModifier;
        Weapon.PutDownAnimRate /= ZedTimeWeaponPutDownSpeedModifier;
    }
}

simulated function UpdateBlackout()
{
    if (bBlackout == bLastKnownBlackout)
    {
        return;
    }

    bLastKnownBlackout = bBlackout;
    Enable('Tick');
}

static final function Color InterpColor(Color X, Color Y, float Alpha)
{
    X.R = Round(Lerp(Alpha, X.R, Y.R));
    X.G = Round(Lerp(Alpha, X.G, Y.G));
    X.B = Round(Lerp(Alpha, X.B, Y.B));
    X.A = Round(Lerp(Alpha, X.A, Y.A));
    return X;
}

simulated function Tick(float DeltaTime)
{
    local bool bUpdated;
    local int Index;

    bUpdated = false;

    if (bBlackout)
    {
        for (Index = ZoneInfoList.Length - 1; Index >= 0; Index--)
        {
            ZoneInfoList[Index].Zone.bDistanceFog = true;
            ZoneInfoList[Index].Zone.bClearToFogColor = true;
            if (ZoneInfoList[Index].bIsSkyZone)
            {
                bUpdated = FadeZone(ZoneInfoList[Index], DeltaTime * 10.f, -128.f, 4.f) || bUpdated;
            }
            else
            {
                bUpdated = FadeZone(ZoneInfoList[Index], DeltaTime, -128.f, 820.f) || bUpdated;
            }
        }
    }
    else
    {
        for (Index = ZoneInfoList.Length - 1; Index >= 0; Index--)
        {
            if (FadeZone(ZoneInfoList[Index], DeltaTime, ZoneInfoList[Index].OriginalFogStart, ZoneInfoList[Index].OriginalFogEnd))
            {
                bUpdated = true;
            }
            else
            {
                ZoneInfoList[Index].Zone.bDistanceFog = ZoneInfoList[Index].bOriginalDistanceFog;
                ZoneInfoList[Index].Zone.bClearToFogColor = ZoneInfoList[Index].bOriginalClearToFogColor;
            }
        }
    }

    if (!bUpdated)
    {
        Disable('Tick');
    }
}

static final function float GetFadeRatio(ZoneInfoEntry Entry, float BlackoutDistance)
{
    return (Entry.Zone.DistanceFogStart - Entry.OriginalFogStart) / (BlackoutDistance - Entry.OriginalFogStart);
}

simulated final function bool FadeZone(ZoneInfoEntry Entry, float DeltaTime, float TargetStart, float TargetEnd)
{
    if (Entry.Zone.DistanceFogEnd != TargetEnd || Entry.Zone.DistanceFogStart != TargetStart)
    {   
        Entry.Zone.DistanceFogStart = Lerp(5.f * DeltaTime, Entry.Zone.DistanceFogStart, TargetStart);
        Entry.Zone.DistanceFogEnd = Lerp(5.f * DeltaTime, Entry.Zone.DistanceFogEnd, TargetEnd);

        if (Abs(Entry.Zone.DistanceFogStart - TargetStart) < 1.f)
        {
            Entry.Zone.DistanceFogStart = TargetStart;
        }
        
        if (Abs(Entry.Zone.DistanceFogEnd - TargetEnd) < 1.f)
        {
            Entry.Zone.DistanceFogEnd = TargetEnd;
        }

        Entry.Zone.DistanceFogColor = InterpColor(Entry.OriginalFogColor, class'HUD'.default.BlackColor, GetFadeRatio(Entry, -128.f));
        return true;
    }

    return false;
}

defaultproperties
{
    bNetNotify=true

    MonsterHeadSizeModifier=1.f
    StalkerDistractionModifier=1.f

    GroundFrictionModifier=1.f
    LastGroundFrictionModifier=1.f

    WeaponBringUpSpeedModifier=1.f
    LastWeaponBringUpSpeedModifier=1.f
    WeaponPutDownSpeedModifier=1.f
    LastWeaponPutDownSpeedModifier=1.f

    ZedTimeWeaponBringUpSpeedModifier=1.f
    LastZedTimeWeaponBringUpSpeedModifier=1.f
    ZedTimeWeaponPutDownSpeedModifier=1.f
    LastZedTimeWeaponPutDownSpeedModifier=1.f

    bBlackout=false
    bLastKnownBlackout=false
}