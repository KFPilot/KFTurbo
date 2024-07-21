class TurboPlayerReplicationInfo extends LinkedReplicationInfo;

var KFPlayerReplicationInfo OwningReplicationInfo;

var Actor MarkedActor;
var class<Actor> MarkActorClass;

var Vector MarkLocation;
var class<Object> DataClass;
var Object DataObject;

var float MarkTime;
var float MarkDuration;

enum EMarkColor{
	Invalid,
	Red,
	Green,
	Blue,
	Yellow,
	Purple,
    Cyan,
    Orange,
    Pink,
    Lime,
    White,
    Grey,
    Black
};

var EMarkColor MarkerColor;
var array<Color> MarkerColorList;

var class<Actor> LastReceivedActorClass;
var float LastReceivedMarkTime;

var String MarkDisplayString;
var float WorldZOffset;

var localized String PickupStringLeft;
var localized String PickupStringRight;

var localized String MonsterStringLeft;
var localized String MonsterStringRight;

var localized String PlayerStringLeft;
var localized String PlayerStringRight;

replication
{
    reliable if( bNetInitial && ROLE == ROLE_Authority)
        OwningReplicationInfo;
	reliable if( Role==ROLE_Authority )
		MarkedActor, MarkActorClass, MarkLocation, DataClass, DataObject, MarkDuration, MarkerColor;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    Disable('Tick');
}

simulated function PostNetReceive()
{
    Super.PostNetReceive();

    if (HasMarkUpdate())
    {
        OnReceivedMark();
    }
}

function UpdateMarkerColor(EMarkColor Color)
{
    MarkerColor = Color;
}

static function Color GetMarkerColor(EMarkColor Color)
{
    return default.MarkerColorList[Color];
}

simulated function final vector GetMarkLocation()
{
    if (MarkedActor != None && CanMarkReceiveLocationUpdate())
    {
        return MarkedActor.Location;
    }

    return MarkLocation;
}

function MarkActor(Actor Target)
{
    if (Target == None)
    {
        return;
    }
    
    if (!CanMarkActor(Target))
    {
        return;
    }

    if (MarkedActor == Target)
    {
        MarkTime = Level.TimeSeconds;
        return;
    }

    ClearMarkedActor();

    MarkedActor = Target;
    MarkActorClass = Target.Class;

    MarkLocation = Target.Location;
    DataClass = GetRelevantDataClass(Target);
    DataObject = GetRelevantDataObject(Target);

    MarkTime = Level.TimeSeconds;
    MarkDuration = GetMarkDuration(Target);

    Enable('Tick');

    NetUpdateTime = Level.TimeSeconds - 2.f;

    TryVoiceLine();

    if (Level.NetMode != NM_DedicatedServer)
    {
        PostNetReceive();
    }
}

function ClearMarkedActor()
{
    MarkedActor = None;
    MarkActorClass = None;
    DataClass = None;
    MarkTime = -1;
    MarkDuration = -1;

    MarkDisplayString = "";
    WorldZOffset = 0;

    Disable('Tick');
    
    NetUpdateTime = Level.TimeSeconds - 2.f;
}

function bool CanMarkActor(Actor TargetActor)
{
    if (TargetActor == None)
    {
        return false;
    }

    if (Pickup(TargetActor) != None)
    {
        return Pickup(TargetActor).InventoryType != None || CashPickup(TargetActor) != None || Vest(TargetActor) != None;
    }

    if (Pawn(TargetActor) != None)
    {
        return Pawn(TargetActor).Health > 0;
    }

    return false;
}

function class<Object> GetRelevantDataClass(Actor TargetActor)
{
    if (Pickup(TargetActor) != None && Pickup(TargetActor).InventoryType != None)
    {
        return Pickup(TargetActor).InventoryType;
    }

    return TargetActor.Class;
}

function Object GetRelevantDataObject(Actor TargetActor)
{
    if (Pawn(TargetActor) != None && Pawn(TargetActor).PlayerReplicationInfo != None)
    {
        return Pawn(TargetActor).PlayerReplicationInfo;
    }

    return None;
}

function float GetMarkDuration(Actor TargetActor)
{
    return 5.f;
}

function bool HasMarkData()
{
    if (MarkedActor == None)
    {
        return false;
    }

    return true;
}

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (!CanMarkActor(MarkedActor))
    {
        ClearMarkedActor();
        return;
    }
    
    if (CanMarkReceiveLocationUpdate())
    {
        MarkLocation = MarkedActor.Location;
    }
}

simulated function bool CanMarkReceiveLocationUpdate()
{
    //If we're marking a zed, make sure if it's cloaked we're not providing locational updates.
    if (KFMonster(MarkedActor) != None)
    {
        return !KFMonster(MarkedActor).bCloaked;
    }

    return true;
}

simulated function bool HasMarkUpdate()
{
    if (MarkActorClass == LastReceivedActorClass && MarkTime == LastReceivedMarkTime)
    {
        return false;
    }

    return true;
}

simulated function OnReceivedMark()
{
    MarkDisplayString = GenerateDisplayString();
    WorldZOffset = GetWorldZOffset();

    LastReceivedActorClass = MarkActorClass;
    LastReceivedMarkTime = MarkTime;
}

simulated function String GenerateDisplayString()
{
    if (Pickup(MarkedActor) != None || class<Pickup>(MarkActorClass) != None)
    {
        return GeneratePickupDisplayString(Pickup(MarkedActor), class<Pickup>(MarkActorClass));
    }

    if (KFMonster(MarkedActor) != None || class<KFMonster>(MarkActorClass) != None)
    {
        return GenerateMonsterDisplayString(KFMonster(MarkedActor), class<KFMonster>(MarkActorClass));
    }

    if (KFHumanPawn(MarkedActor) != None || class<KFHumanPawn>(MarkActorClass) != None)
    {
        if (KFPlayerReplicationInfo(DataObject) != None)
        {
            return KFPlayerReplicationInfo(DataObject).PlayerName;
        }
    }

    return "";
}

simulated function String GeneratePickupDisplayString(Pickup PickupActor, class<Pickup> PickupClass)
{
    //Leverage localized values.
    if (PickupActor != None)
    {
        if (Vest(MarkedActor) != None)
        {
            return PickupStringLeft$class'BuyableVest'.default.ItemName$PickupStringRight; //This text is "Combat armour".
        }
        else if (KFAmmoPickup(MarkedActor) != None)
        {
            return PickupStringLeft$GUILabel(class'GUIInvHeaderTabPanel'.default.Controls[1]).Caption$PickupStringRight; //This text is "ammo".
        }
        else if (CashPickup(MarkedActor) != None)
        {
            return PickupStringLeft$CashPickup(MarkedActor).CashAmount@class'KFTab_BuyMenu'.default.MoneyCaption$PickupStringRight; 
        }

        if (Pickup(MarkedActor).InventoryType == None)
        {
            if (DataClass != None)
            {
                return PickupStringLeft$class<Inventory>(DataClass).default.ItemName$PickupStringRight;
            }

            return "";
        }
    
        return PickupStringLeft$Pickup(MarkedActor).InventoryType.default.ItemName$PickupStringRight;
    }

    if (class<Vest>(PickupClass) != None)
    {
        return PickupStringLeft$class'BuyableVest'.default.ItemName$PickupStringRight; //This text is "Combat armour".
    }
    else if (class<KFAmmoPickup>(PickupClass) != None)
    {
        return PickupStringLeft$GUILabel(class'GUIInvHeaderTabPanel'.default.Controls[1]).Caption$PickupStringRight; //This text is "ammo".
    }
    else if (class<CashPickup>(PickupClass) != None)
    {
        return class'KFTab_BuyMenu'.default.MoneyCaption;
    }

    if (class<Inventory>(DataClass) != None)
    {
        return PickupStringLeft$class<Inventory>(DataClass).default.ItemName$PickupStringRight;
    }

    return "";
}

simulated function String GenerateMonsterDisplayString(KFMonster Monster, class<KFMonster> MonsterClass)
{
    if (Monster != None)
    {
        return MonsterStringLeft$Caps(Monster.MenuName)$MonsterStringRight;
    }
    
    return MonsterStringLeft$Caps(MonsterClass.default.MenuName)$MonsterStringRight;
}

simulated function float GetWorldZOffset()
{
    local float ExtraOffset;

    if (KFMonster(MarkedActor) != None || class<KFMonster>(MarkActorClass) != None)
    {
        return GetMonsterZOffset(KFMonster(MarkedActor), class<KFMonster>(MarkActorClass));
    }

    ExtraOffset = 0.f;

    if (KFHumanPawn(MarkedActor) != None || class<KFHumanPawn>(MarkActorClass) != None)
    {
        ExtraOffset = 16.f;
    }

    if (MarkedActor != None)
    {
        return MarkedActor.CollisionHeight + ExtraOffset;
    }

    if (MarkActorClass != None)
    {
        return MarkActorClass.default.CollisionHeight + ExtraOffset;
    }

    return 0.f;
}

simulated function float GetMonsterZOffset(KFMonster Monster, class<KFMonster> MonsterClass)
{
    local float ExtraOffset;

    if (ZombieBoss(MarkedActor) != None || class<ZombieBoss>(MarkActorClass) != None)
    {
        ExtraOffset = 16.f;
    }

    if (Monster != None)
    {
        return Monster.CollisionRadius + Monster.ColHeight + (Monster.ColOffset.Z * 0.5f) + ExtraOffset;
    }
    else if (MonsterClass != None)
    {
        return MonsterClass.default.CollisionRadius + MonsterClass.default.ColHeight + (MonsterClass.default.ColOffset.Z * 0.5f) + ExtraOffset;
    }
    else
    {
        return 0.f;
    }
}

function TryVoiceLine()
{
    local PlayerController PlayerController;

    PlayerController = PlayerController(Owner);

    if (PlayerController == None || FRand() < 0.25f)
    {
        return;
    }
    
    if (KFMonster(MarkedActor) != None)
    {
        TryMonsterVoiceLine(KFMonster(MarkedActor));
        return;
    }
    
    if (Pickup(MarkedActor) != None)
    {
        TryPickupVoiceLine(Pickup(MarkedActor));
        return;
    }
}

function TryMonsterVoiceLine(KFMonster MarkedMonster)
{
    if (ZombieFleshPound(MarkedActor) != None)
    {
        PlayerController(Owner).Speech('AUTO', 12, "");
    }
    else if (ZombieScrake(MarkedActor) != None)
    {
        PlayerController(Owner).Speech('AUTO', 14, "");
    }
}

function TryPickupVoiceLine(Pickup MarkedPickup)
{
    if (CashPickup(MarkedActor) != None)
    {
        PlayerController(Owner).Speech('AUTO', 4, "");
        return;
    }
    
    if (MarkedPickup.InventoryType != None)
    {
        if (FRand() < 0.25f)
        {
            return;
        }

        if (class<W_Boomstick_Weap>(MarkedPickup.InventoryType) != None)
        {
            PlayerController(Owner).Speech('AUTO', 21, "");
        }
        else if (class<W_DualDeagle_Weap>(MarkedPickup.InventoryType) != None)
        {
            PlayerController(Owner).Speech('AUTO', 22, "");
        }
        else if (class<W_LAW_Weap>(MarkedPickup.InventoryType) != None)
        {
            PlayerController(Owner).Speech('AUTO', 23, "");
        }
        else if (class<W_Axe_Weap>(MarkedPickup.InventoryType) != None)
        {
            PlayerController(Owner).Speech('AUTO', 24, "");
        }
        return;
    }

}

static function TurboPlayerReplicationInfo GetTurboPRI(PlayerReplicationInfo PRI)
{
    local LinkedReplicationInfo LRI;
    local TurboPlayerReplicationInfo TPRI;

    if (PRI == None)
    {
        return None;
    }

    for (LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
    {
        if (TurboPlayerReplicationInfo(LRI) != None)
        {
            return TurboPlayerReplicationInfo(LRI);
        }
    }

    foreach PRI.DynamicActors(class'TurboPlayerReplicationInfo', TPRI)
    {
        if (TPRI.OwningReplicationInfo == PRI)
        {
            return TPRI;
        }
    }

    return None;
}

defaultproperties
{
    bAlwaysRelevant=true
    bNetNotify=true

    MonsterStringLeft="["
    MonsterStringRight="]"

    PickupStringLeft=""
    PickupStringRight=""

    MarkerColorList(0)=(R=255,G=255,B=255,A=255) //Invalid
    MarkerColorList(1)=(R=255,G=0,B=0,A=255) //Red
    MarkerColorList(2)=(R=0,G=255,B=0,A=255) //Green
    MarkerColorList(3)=(R=0,G=0,B=255,A=255) //Blue
    MarkerColorList(4)=(R=255,G=255,B=0,A=255) //Yellow
    MarkerColorList(5)=(R=100,G=0,B=200,A=255) //Purple
    MarkerColorList(6)=(R=0,G=255,B=255,A=255) //Cyan
    MarkerColorList(7)=(R=255,G=128,B=0,A=255) //Orange
    MarkerColorList(8)=(R=255,G=0,B=255,A=255) //Pink
    MarkerColorList(9)=(R=50,G=255,B=100,A=255) //Lime
    MarkerColorList(10)=(R=255,G=255,B=255,A=255) //White
    MarkerColorList(11)=(R=128,G=128,B=128,A=255) //Grey
    MarkerColorList(12)=(R=0,G=0,B=0,A=255) //Black
}