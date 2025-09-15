//Killing Floor Turbo KFTurboPlusArmorRegen
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboPlusArmorRegen extends TurboPlayerEventHandler;

struct PawnRegenEntry
{
    var Pawn Pawn;
    var float NextArmorRegen;
};

var globalconfig bool bEnableArmorRegen;
var globalconfig string ArmorRegenActorClassOverride;

var array<PawnRegenEntry> PawnRegenList;
var globalconfig float DamageRegenDelay;
var globalconfig float ArmorRegenDelay;
var globalconfig float ArmorRegenAmount;
var globalconfig float ArmorRegenMaximum;

static final function bool ShouldPerformArmorRegen()
{
    return default.bEnableArmorRegen;
}

static final function class<KFTurboPlusArmorRegen> GetArmorRegenActorClass()
{
    if (default.ArmorRegenActorClassOverride != "")
    {
        return class<KFTurboPlusArmorRegen>(DynamicLoadObject(default.ArmorRegenActorClassOverride, class'Class'));
    }

    return class'KFTurboPlusArmorRegen';
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    OnPlayerReceivedDamage = PlayerDamaged;
}

final function PlayerDamaged(TurboPlayerController Player, KFMonster Instigator, int Damage, class<DamageType> DamageType)
{
    local bool bHasPendingRegenPawns;
    if (Player.Pawn == None)
    {
        return;
    }

    //Residual burn should not reset the armor timer.
    if (class<TurboHumanBurned_DT>(DamageType) != None)
    {
        return;
    }

    bHasPendingRegenPawns = PawnRegenList.Length != 0;
    if (UpdatePlayerDamageTimeStamp(Player.Pawn) && !bHasPendingRegenPawns)
    {
        SetTimer(0.1f, true);
    }
}

function bool UpdatePlayerDamageTimeStamp(Pawn Pawn)
{
    local int Index;
    for (Index = 0; Index < PawnRegenList.Length; Index++)
    {
        if (PawnRegenList[Index].Pawn == Pawn)
        {
            PawnRegenList[Index].NextArmorRegen = Level.TimeSeconds + DamageRegenDelay;
            return false;
        }
    }

    PawnRegenList.Length = PawnRegenList.Length + 1;
    Index = PawnRegenList.Length - 1;

    PawnRegenList[Index].Pawn = Pawn;
    PawnRegenList[Index].NextArmorRegen = Level.TimeSeconds + DamageRegenDelay;
    return true;
}

function Timer()
{
    local int Index;
    local Pawn Pawn;

    for (Index = PawnRegenList.Length - 1; Index >= 0; Index--)
    {
        if (PawnRegenList[Index].NextArmorRegen > Level.TimeSeconds)
        {
            continue;
        }

        Pawn = PawnRegenList[Index].Pawn;
        if (Pawn == None || Pawn.Health <= 0 || Pawn.ShieldStrength >= ArmorRegenMaximum)
        {
            PawnRegenList.Remove(Index, 1);
            continue;
        }

        PawnRegenList[Index].NextArmorRegen += ArmorRegenDelay;
        Pawn.ShieldStrength = FMin(Pawn.ShieldStrength + ArmorRegenAmount, FMax(Pawn.ShieldStrength, ArmorRegenMaximum));

        if (Pawn.ShieldStrength >= ArmorRegenMaximum)
        {
            PawnRegenList.Remove(Index, 1);
        }
    }

    if (PawnRegenList.Length == 0)
    {
        SetTimer(0.f, false);
    }
}

defaultproperties
{
    bEnableArmorRegen = true
    ArmorRegenActorClassOverride = ""
    DamageRegenDelay = 10.f
    ArmorRegenDelay = 4.f
    ArmorRegenAmount = 1.f
    ArmorRegenMaximum = 50.f
}