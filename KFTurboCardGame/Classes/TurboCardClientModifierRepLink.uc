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

struct PhysicsVolumeEntry
{
    var PhysicsVolume Volume;
    var float OriginalGroundFriction;
};
var array<PhysicsVolumeEntry> PhysicsVolumeList;

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
        ZedTimeWeaponBringUpSpeedModifier, ZedTimeWeaponPutDownSpeedModifier;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    CollectAllPhysicsVolumes();
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    UpdatePhysicsVolumes();
    UpdateWeaponEquipSpeed();
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    UpdatePhysicsVolumes();
    UpdateWeaponEquipSpeed();
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
}