//Killing Floor Turbo KFTurboPlusResupply
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboPlusResupply extends TurboWaveEventHandler;

var globalconfig bool bEnableResupply;
var globalconfig string ResupplyActorClassOverride;

var globalconfig bool bFillHealth;
var globalconfig bool bFillArmor;
var globalconfig bool bFillAmmo;

static final function bool ShouldPerformResupply()
{
    return default.bEnableResupply;
}

static final function class<KFTurboPlusResupply> GetResupplyActorClass()
{
    if (default.ResupplyActorClassOverride != "")
    {
        return class<KFTurboPlusResupply>(DynamicLoadObject(default.ResupplyActorClassOverride, class'Class'));
    }

    return class'KFTurboPlusResupply';
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    OnWaveEnded = DelayedResupplyPlayers;
    OnWaveStarted = DelayedResupplyPlayers;
}

function DelayedResupplyPlayers(KFTurboGameType GameType, int StartingWave)
{
    SetTimer(0.5f, false);
}

function Timer()
{
    ResupplyPlayers();
}

function ResupplyPlayers()
{
    local array<TurboPlayerController> PlayerList;
    local int Index;

    PlayerList = class'TurboGameplayHelper'.static.GetPlayerControllerList(Level);
    for (Index = 0; Index < PlayerList.Length; Index++)
    {
        if (PlayerList[Index] == None || PlayerList[Index].Pawn == None || PlayerList[Index].Pawn.Health <= 0)
        {
            continue;
        }

        if (bFillHealth)
        {
            PlayerList[Index].Pawn.Health = PlayerList[Index].Pawn.HealthMax;
        }

        if (bFillArmor)
        {
            PlayerList[Index].Pawn.ShieldStrength = FMax(PlayerList[Index].Pawn.ShieldStrength, 100.f);
        }

        if (bFillAmmo)
        {
            FillUpAmmo(PlayerList[Index].Pawn);
        }
    }
}

function FillUpAmmo(Pawn Pawn)
{
	local Inventory Inv;
	local KFWeapon Weapon;
	local int MaxAmmo, CurrentAmmo;

	for(Inv = Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		Weapon = KFWeapon(Inv);

		if(Weapon == None)
		{
			continue;
		}

		GetAmmoCount(Weapon, MaxAmmo, CurrentAmmo);
		Weapon.AddAmmo(MaxAmmo - CurrentAmmo, 0);

		if(!Weapon.bHasSecondaryAmmo)
		{
			continue;
		}

		MaxAmmo = Weapon.MaxAmmo(1);
		CurrentAmmo = Weapon.AmmoAmount(1);
		Weapon.AddAmmo(MaxAmmo - CurrentAmmo, 1);
	}
}

static final function GetAmmoCount(KFWeapon Weapon, out int MaxAmmo, out int CurrentAmmo)
{
	local float AmmoCountMax, AmmoCountCurrent;

	Weapon.GetAmmoCount(AmmoCountMax, AmmoCountCurrent);

	MaxAmmo = int(AmmoCountMax);
	CurrentAmmo = int(AmmoCountCurrent);
}

defaultproperties
{
    bEnableResupply=true
    ResupplyActorClassOverride=""

    bFillArmor=true
    bFillHealth=true
    bFillAmmo=true
}
