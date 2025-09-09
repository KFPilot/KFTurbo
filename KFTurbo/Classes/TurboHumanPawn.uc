//Killing Floor Turbo TurboHumanPawn
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHumanPawn extends SRHumanPawn;


var bool bDebugServerBuyWeapon;

var float NextCloakCheckTime;
var float NextPlayerFlagsCheckTime;

//Replicated properties:
var int HealthHealingTo;
var int NewHealthMax;

//Flags for CustomPlayerState.
const ShoppingFlag = 1;
const LoginMenuFlag = 2;
//const CustomPlayerStateFlag_3 = 4;
//const CustomPlayerStateFlag_4 = 8;
//const CustomPlayerStateFlag_5 = 16;
//const CustomPlayerStateFlag_6 = 32;
//const CustomPlayerStateFlag_7 = 64;
//const CustomPlayerStateFlag_8 = 128; (1 << N)

var byte PlayerFlags;

var float JumpZMultiplier;

var class<CashPickup> CashPickupClass;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		NewHealthMax, HealthHealingTo, PlayerFlags;
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	UpdateHealth();
	UpdatePlayerFlags();

	if (Level.NetMode == NM_DedicatedServer || Level.GRI == None)
	{
		return;
	}

	if (ShowStalkers())
	{
		SpotCloakedMonsters();
	}
}

function UpdatePlayerFlags()
{
	local byte NewPlayerFlags;
	NewPlayerFlags = 0;

	if (NextPlayerFlagsCheckTime > Level.TimeSeconds)
	{
		return;
	}

	NextPlayerFlagsCheckTime = Level.TimeSeconds + 0.125f + (FRand() * 0.125f);

	if (TurboPlayerController(Controller) != None)
	{
		if (TurboPlayerController(Controller).bShopping)
		{
			NewPlayerFlags = NewPlayerFlags | ShoppingFlag;
		}

		if (TurboPlayerController(Controller).bInLoginMenu)
		{
			NewPlayerFlags = NewPlayerFlags | LoginMenuFlag;
		}
	}

	if (NewPlayerFlags != PlayerFlags)
	{
		PlayerFlags = NewPlayerFlags;
	}
}

simulated final function bool IsShopping()
{
	return (PlayerFlags & ShoppingFlag) == ShoppingFlag;
}

simulated final function bool IsInLoginMenu()
{
	return (PlayerFlags & LoginMenuFlag) == LoginMenuFlag;
}

//Fixed not properly dropping weapons until carry weight is valid.
function VeterancyChanged()
{
	local Inventory CurrentInventory;
	local KFWeapon CurrentWeapon;
	local KFPlayerReplicationInfo KFPRI;
	local int MaxAmmo;

	MaxCarryWeight = Default.MaxCarryWeight;

	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	//Attempt to speed up perk selection updates.
	if (KFPRI != None)
	{
		KFPRI.NetUpdateTime = Level.TimeSeconds - 2.f;
	}

	if ( KFPRI != none && KFPRI.ClientVeteranSkill != none )
	{
		MaxCarryWeight += KFPRI.ClientVeteranSkill.Static.AddCarryMaxWeight(KFPRI);
	}

	if ( CurrentWeight > MaxCarryWeight )
	{
		CurrentInventory = Inventory;

		while (CurrentInventory != None)
		{
			CurrentWeapon = KFWeapon(CurrentInventory);
			CurrentInventory = CurrentInventory.Inventory;

			if (CurrentWeapon == None || CurrentWeapon.bKFNeverThrow)
			{
				continue;
			}

			CurrentWeapon.Velocity = Velocity;
			CurrentWeapon.DropFrom(Location + (VRand() * 10.f));

			if ( CurrentWeight <= MaxCarryWeight )
			{
				break;
			}
		}
	}

	// Make sure nothing is over the Max Ammo amount when changing Veterancy
	for ( CurrentInventory = Inventory; CurrentInventory != none; CurrentInventory = CurrentInventory.Inventory )
	{
		if ( Ammunition(CurrentInventory) != none )
		{
			MaxAmmo = Ammunition(CurrentInventory).default.MaxAmmo;

			if ( KFPRI != none && KFPRI.ClientVeteranSkill != none )
			{
				MaxAmmo = float(MaxAmmo) * KFPRI.ClientVeteranSkill.static.AddExtraAmmoFor(KFPRI, Ammunition(CurrentInventory).Class);
			}

			if ( Ammunition(CurrentInventory).AmmoAmount > MaxAmmo )
			{
				Ammunition(CurrentInventory).AmmoAmount = MaxAmmo;
			}
		}
	}
}

//Changed out damage type to ignore (and more importantly not damage) armor.
function TakeFireDamage(int Damage, pawn BurnInstigator)
{
    if( Damage > 0 )
    {
        TakeDamage(float(Damage) * Lerp(ShieldStrength / 100.f, 1.f, 0.25f, true), BurnInstigator, Location, vect(0,0,0), class'TurboHumanBurned_DT');

        if (BurnDown > 0)
        {
            BurnDown--;
        }
        if(BurnDown==0)
        {
            bBurnified = false;
        }
    }
    else
    {
        BurnDown = 0;
        bBurnified = false;
    }
}

function TakeFallingDamage()
{
    local float Shake, EffectiveSpeed;
    local float UsedMaxFallSpeed;

    UsedMaxFallSpeed = MaxFallSpeed;

    if (Instigator != None && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
    {
        UsedMaxFallSpeed *= 2.0;
    }

    if (Velocity.Z < -0.5 * UsedMaxFallSpeed)
    {
        if (Role == ROLE_Authority)
        {
            MakeNoise(1.0);

            if (Velocity.Z < -1 * UsedMaxFallSpeed)
            {
                EffectiveSpeed = Velocity.Z;

                if (TouchingWaterVolume())
				{
                    EffectiveSpeed = FMin(0, EffectiveSpeed + 100);
				}

                if (EffectiveSpeed < -1.f * UsedMaxFallSpeed)
				{
                    TakeDamage(-100.f * (EffectiveSpeed + UsedMaxFallSpeed) / UsedMaxFallSpeed, None, Location, vect(0,0,0), class'TurboHumanFall_DT');
				}
            }
        }
        if (Controller != None)
        {
            Shake = FMin(1, -1 * Velocity.Z/MaxFallSpeed);
            Controller.DamageShake(Shake);
        }
    }
    else if (Velocity.Z < -1.4 * JumpZ)
	{
        MakeNoise(0.5);
	}
}

simulated function bool ShowStalkers()
{
	if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		return KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.Static.ShowStalkers(KFPlayerReplicationInfo(PlayerReplicationInfo));
	}

	return false;
}

simulated function SpotCloakedMonsters()
{
	local KFMonster Monster;
	local float SpottingRange;
	SpottingRange = 2000.f;

	if (NextCloakCheckTime > Level.TimeSeconds)
	{
		return;
	}

	NextCloakCheckTime = Level.TimeSeconds + 0.125f + (FRand() * 0.125f);

	if (!IsLocallyControlled())
	{
		SpottingRange *= 0.5f;
	}

	foreach CollidingActors(class'KFMonster', Monster, SpottingRange)
	{
		if (Monster.Health <= 0)
		{
			continue;
		}
		
		if (P_Stalker(Monster) != None)
		{
			P_Stalker(Monster).SpotStalker();
		}
		else if (P_ZombieBoss(Monster) != None)
		{
			P_ZombieBoss(Monster).SpotBoss();
		}
	}
}

function bool CanBuyNow()
{
	if (!class'KFTurboGameType'.static.StaticIsHighDifficulty(Self))
	{
		return Super.CanBuyNow();
	}

	//High difficulty can trade anywhere during trader wave.
    if( KFGameType(Level.Game) == None || KFGameType(Level.Game).bWaveInProgress || PlayerReplicationInfo == None )
	{
		return false;
	}
	
	return true;
}

simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local Inventory InventoryItem;
	Super.DisplayDebug(Canvas, YL, YPos);

	InventoryItem = Inventory;
	while (InventoryItem != None)
	{
		if (Weapon(InventoryItem) != None)
		{
			DisplayInventoryDebug(Canvas, Weapon(InventoryItem), YL, YPos);
		}
		InventoryItem = InventoryItem.Inventory;
	}
}

simulated function DisplayInventoryDebug(Canvas Canvas, Weapon Weapon, out float YL, out float YPos)
{
    local string T;

    Canvas.SetDrawColor(0,255,0);
    if ( (Pawn(Weapon.Owner) != None) && (Pawn(Weapon.Owner).PlayerReplicationInfo != None) )
		Canvas.DrawText("WEAPON "$Weapon.GetItemName(string(Weapon))$" Owner "$Pawn(Weapon.Owner).PlayerReplicationInfo.PlayerName);
    else
		Canvas.DrawText("WEAPON "$Weapon.GetItemName(string(Weapon))$" Owner "$Weapon.Owner);
    YPos += YL;
    Canvas.SetPos(4,YPos);

    T = "     STATE: "$Weapon.GetStateName()$" Timer: "$Weapon.TimerCounter$" Client State ";
	
	Switch( Weapon.ClientState )
	{
		case WS_None: T=T$"None"; break;
		case WS_Hidden: T=T$"Hidden"; break;
		case WS_BringUp: T=T$"BringUp"; break;
		case WS_PutDown: T=T$"PutDown"; break;
		case WS_ReadyToFire: T=T$"ReadyToFire"; break;
	}

    Canvas.DrawText(T, false);
    YPos += YL;
    Canvas.SetPos(4,YPos);
}

simulated function ChangedWeapon()
{
	local KFWeapon CurrentWeapon;
	local KFPlayerReplicationInfo KFPRI;

	InventorySpeedModifier = 0.f;

    if(PendingWeapon == None || !AllowHoldWeapon(KFWeapon(PendingWeapon)))
	{
		PendingWeapon = None;
		return;
	}

	CurrentWeapon = KFWeapon(Weapon);

	//Let TurboClientModifiers know we're about to swap weapons so they can make changes if they feel like it.
	if (Level.NetMode != NM_DedicatedServer && TurboGameReplicationInfo(Level.GRI) != None)
	{
		TurboGameReplicationInfo(Level.GRI).OnWeaponChange(CurrentWeapon, KFWeapon(PendingWeapon));
	}

	Super(KFPawn).ChangedWeapon();

	if (CurrentWeapon == None)
	{
		return;
	}

	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	if (KFPRI == None)
	{
		return;
	}

	if (CurrentWeapon.bSpeedMeUp)
	{
		BaseMeleeIncrease = default.BaseMeleeIncrease;

		if (KFPRI != None && KFPRI.ClientVeteranSkill != None)
		{
			BaseMeleeIncrease += KFPRI.ClientVeteranSkill.Static.GetMeleeMovementSpeedModifier(KFPRI);
		}
		
        InventorySpeedModifier = ((default.GroundSpeed * BaseMeleeIncrease) - (CurrentWeapon.Weight * 2.f));
	}
	else if (KFMedicGun(CurrentWeapon) != None && class'V_FieldMedic'.static.IsFieldMedic(KFPRI))
	{
		BaseMeleeIncrease = default.BaseMeleeIncrease * 0.5f;
		InventorySpeedModifier = ((default.GroundSpeed * BaseMeleeIncrease) - (CurrentWeapon.Weight * 2.f));
	}
}

function ThrowGrenade()
{
    local Inventory Inv;
    local Frag FragWeapon;
	local KFWeapon CurrentWeapon;

	if (!AllowGrenadeTossing() || bThrowingNade || KFWeapon(Weapon) == None)
	{
		return;
	}

	CurrentWeapon = KFWeapon(Weapon);
	if (CurrentWeapon == None || (Weapon.GetFireMode(0) != None && Weapon.GetFireMode(0).NextFireTime - Level.TimeSeconds > 0.1)
		|| (CurrentWeapon.bIsReloading && !CurrentWeapon.InterruptReload()))
	{
		return;
	}

	if (KFMeleeGun(Weapon) != None && Weapon.GetFireMode(1) != None && (Weapon.GetFireMode(1).NextFireTime - Level.TimeSeconds > 0.1))
	{
		return;
	}

    for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
    {
        FragWeapon = Frag(Inv);

		if (FragWeapon != None)
		{
			break;
		}
    }

	if (FragWeapon == None || !FragWeapon.HasAmmo())
	{
		return;
	}

	CurrentWeapon.ClientGrenadeState = GN_TempDown;
	Weapon.PutDown();
}

simulated function ThrowGrenadeFinished()
{
	SecondaryItem = None;

	if (Weapon != None)
	{
		if (KFWeapon(Weapon) != None)
		{
			KFWeapon(Weapon).ClientGrenadeState = GN_BringUp;
		}
		Weapon.BringUp();
	}

	bThrowingNade = false;
}

simulated function UpdateHealth()
{
	local int NewHealthHealingTo;
	if (Role != ROLE_Authority)
	{
		if (NewHealthMax != 0 && NewHealthMax != HealthMax)
		{
			HealthMax = NewHealthMax;
		}

		return;
	}

	if (HealthMax != NewHealthMax)
	{
		NewHealthMax = HealthMax;
	}
	
	if (HealthToGive <= 0 || Health >= int(HealthMax))
	{
		if (HealthHealingTo != -1)
		{
			HealthHealingTo = -1;
		}
		return;
	}

	NewHealthHealingTo = int(float(Health) + HealthToGive);
	NewHealthHealingTo = Min(NewHealthHealingTo, int(HealthMax));

	if (Health == NewHealthHealingTo)
	{
		if (HealthHealingTo != -1)
		{
			HealthHealingTo = -1;
		}
	}
	else if (NewHealthHealingTo != HealthHealingTo)
	{
		HealthHealingTo = NewHealthHealingTo;
	}
}

simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);
}

final function DebugServerBuyWeapon(Class<Weapon> WClass, float Weight)
{
	if (!bDebugServerBuyWeapon)
	{
		return;
	}

	log("========================");
	log("Testing: "$WClass$" (Pickup: "$WClass.Default.PickupClass$")");
	log("Can Buy Now: "$ CanBuyNow());
	log("KFWeapon Cast: "$ (Class<KFWeapon>(WClass)==None));
	log("KFWeaponPickup Cast: "$ (Class<KFWeaponPickup>(WClass.Default.PickupClass)==None));
	log("Has Weapon Class: "$ HasWeaponClass(WClass));
	log("Can Buy Pickup: "$ CanBuyPickup(WClass));
	log("Get Corrected Weapon Pickup: "$ GetCorrectedWeaponPickup(WClass.Default.PickupClass));
}

function bool CanBuyPickup(class<Weapon> WClass)
{
	// Validate if allowed to buy that weapon.
	if (PerkLink == None)
		PerkLink = FindStats();
	if (PerkLink != None && !PerkLink.CanBuyPickup(GetCorrectedWeaponPickup(WClass.Default.PickupClass)))
		return false;

	return true;
}

static final function class<KFWeaponPickup> GetCorrectedWeaponPickup(class<Pickup> PickupClass)
{
	local class<KFWeaponPickup> WeaponPickup;

	WeaponPickup = Class<KFWeaponPickup>(PickupClass);

	if (WeaponPickup.default.VariantClasses.Length > 0 && WeaponPickup.default.VariantClasses[0] != None)
	{
		return class<KFWeaponPickup>(WeaponPickup.default.VariantClasses[0]);
	}

	return WeaponPickup;
}

function ServerBuyWeapon( Class<Weapon> WClass, float Weight )
{
	local float Price;
	local int OtherPrice;
	local int Index;
	local Inventory I,OI;
	local class<KFWeapon> SecType;
	local class<KFWeaponPickup> WeaponPickup;

	DebugServerBuyWeapon(WClass, Weight);

	if( !CanBuyNow() || Class<KFWeapon>(WClass)==None || Class<KFWeaponPickup>(WClass.Default.PickupClass)==None || HasWeaponClass(WClass) )
		Return;

	if (!CanBuyPickup(WClass))
	{
		return;
	}

	WeaponPickup = class<KFWeaponPickup>(WClass.Default.PickupClass);

	Price = WeaponPickup.Default.Cost;

	if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), GetCorrectedWeaponPickup(WClass.Default.PickupClass));

	Weight = Class<KFWeapon>(WClass).Default.Weight;

	if( class'DualWeaponsManager'.Static.IsDualWeapon(WClass,SecType) )
	{
		if( WClass!=class'Dualies' && HasWeaponClass(SecType,OI) )
		{
			Weight-=SecType.Default.Weight;
			Price*=0.5f;
			OtherPrice = KFWeapon(OI).SellValue;
			if( OtherPrice==-1 )
			{
				OtherPrice = class<KFWeaponPickup>(SecType.Default.PickupClass).Default.Cost * 0.75;
				if ( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
					OtherPrice *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), SecType.Default.PickupClass);
			}
		}
		else if (WeaponPickup.default.VariantClasses.Length > 0)
		{
			for (Index = 0; Index < WeaponPickup.default.VariantClasses.Length; Index++)
			{
				if (class'DualWeaponsManager'.Static.IsDualWeapon(class<Weapon>(WeaponPickup.default.VariantClasses[Index].default.InventoryType), SecType))
				{
					if (class<Weapon>(WeaponPickup.default.VariantClasses[Index].default.InventoryType) != class'Dualies' && HasWeaponClass(SecType, OI))
					{
						Weight -= SecType.Default.Weight;
						Price *= 0.5f;
						OtherPrice = KFWeapon(OI).SellValue;
						if (OtherPrice == -1)
						{
							OtherPrice = class<KFWeaponPickup>(SecType.Default.PickupClass).Default.Cost * 0.75;
							if (KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
								OtherPrice *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), SecType.Default.PickupClass);
						}

						break;
					}
				}
				else if (class'DualWeaponsManager'.Static.HasDualies(class<Weapon>(WeaponPickup.default.VariantClasses[Index].default.InventoryType), Inventory))
					return;
			}
		}
	}
	else if( class'DualWeaponsManager'.Static.HasDualies(WClass,Inventory) )
		return;

	Price = int(Price); // Truncuate price.

	if( Weight>0 && !CanCarry(Weight) )
	{
		ClientMessage("Error: "$WClass.Name$" is too heavy ("$CurrentWeight$"+"$Weight$">"$MaxCarryWeight$")");
		return;
	}
	if ( PlayerReplicationInfo.Score<Price )
	{
		ClientMessage("Error: "$WClass.Name$" is too expensive ("$int(Price)$">"$int(PlayerReplicationInfo.Score)$")");
		Return;
	}

	I = Spawn(WClass);
	if ( I != none )
	{
		if ( KFGameType(Level.Game) != none )
			KFGameType(Level.Game).WeaponSpawned(I);

		KFWeapon(I).UpdateMagCapacity(PlayerReplicationInfo);
		KFWeapon(I).FillToInitialAmmo();
		KFWeapon(I).SellValue = Price * 0.75;
		if( OtherPrice>0 )
			KFWeapon(I).SellValue+=OtherPrice;
		I.GiveTo(self);
		PlayerReplicationInfo.Score -= Price;
        ClientForceChangeWeapon(I);
    }
	else ClientMessage("Error: "$WClass.Name$" failed to spawn.");

	SetTraderUpdate();
}


function bool ServerBuyAmmo(Class<Ammunition> AClass, bool bOnlyClip)
{
	local Inventory I;
	local float Price;
	local Ammunition AM;
	local KFWeapon KW;
	local int c;
	local float UsedMagCapacity;
	local Boomstick DBShotty;

	if (!CanBuyNow() || AClass == None)
	{
		SetTraderUpdate();
		return false;
	}

	for (I = Inventory; I != none; I = I.Inventory)
	{
		if (I.Class == AClass)
		{
			AM = Ammunition(I);
		}
		else if (KW == None && KFWeapon(I) != None && (Weapon(I).AmmoClass[0] == AClass || Weapon(I).AmmoClass[1] == AClass))
		{
			KW = KFWeapon(I);
		}
	}

	if (KW == none || AM == none)
	{
		SetTraderUpdate();
		return false;
	}

	DBShotty = Boomstick(KW);

	AM.MaxAmmo = AM.default.MaxAmmo;

	if (KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
	{
		AM.MaxAmmo = int(float(AM.MaxAmmo) * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(PlayerReplicationInfo), AClass));
	}

	if (AM.AmmoAmount >= AM.MaxAmmo)
	{
		SetTraderUpdate();
		return false;
	}

	Price = class<KFWeaponPickup>(KW.PickupClass).default.AmmoCost * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetAmmoCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), GetCorrectedWeaponPickup(KW.PickupClass)); // Clip price.

	if (KW.bHasSecondaryAmmo && AClass == KW.FireModeClass[1].default.AmmoClass)
	{
		UsedMagCapacity = 1; // Secondary Mags always have a Mag Capacity of 1? KW.default.SecondaryMagCapacity;
	}
	else
	{
		UsedMagCapacity = KW.default.MagCapacity;
	}

	if ( class<W_Huskgun_Pickup>(KW.PickupClass) != None )
	{
		UsedMagCapacity = class<W_Huskgun_Pickup>(KW.PickupClass).default.BuyClipSize;
	}

	if (bOnlyClip)
	{
		if (KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none)
		{
			if ( class<W_Huskgun_Pickup>(KW.PickupClass) != None )
			{
				c = UsedMagCapacity * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(PlayerReplicationInfo), AM.Class);
			}
			else
			{
				c = UsedMagCapacity * KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetMagCapacityMod(KFPlayerReplicationInfo(PlayerReplicationInfo), KW);
			}
		}
		else
		{
			c = UsedMagCapacity;
		}
	}
	else
	{
		c = (AM.MaxAmmo - AM.AmmoAmount);
	}

	Price = int(float(c) / UsedMagCapacity * Price);

	if (PlayerReplicationInfo.Score < Price) // Not enough CASH (so buy the amount you CAN buy).
	{
		c *= (PlayerReplicationInfo.Score / Price);

		if (c == 0)
		{
			SetTraderUpdate();
			return false; // Couldn't even afford 1 bullet.
		}

		AM.AddAmmo(c);
		if (DBShotty != none)
		{
			DBShotty.AmmoPickedUp();
		}

		PlayerReplicationInfo.Score = Max(PlayerReplicationInfo.Score - (float(c) / UsedMagCapacity * Price), 0);

		SetTraderUpdate();

		return false;
	}

	PlayerReplicationInfo.Score = int(PlayerReplicationInfo.Score - Price);
	AM.AddAmmo(c);
	if (DBShotty != none)
	{
		DBShotty.AmmoPickedUp();
	}

	SetTraderUpdate();

	return true;
}

function ServerSellWeapon( Class<Weapon> WClass )
{
	local Inventory I;
	local KFWeapon NewWep;
	local float Price;
	local class<KFWeapon> SecType;

	if (!CanBuyNow() || Class<KFWeapon>(WClass) == None || Class<KFWeaponPickup>(WClass.Default.PickupClass) == None || Class<KFWeapon>(WClass).Default.bKFNeverThrow)
	{
		SetTraderUpdate();
		return;
	}

	for (I = Inventory; I != none; I = I.Inventory)
	{
		if (I.Class == WClass)
		{
			//Check if the runtime version of the item set bKFNeverThrow.
			if (KFWeapon(I) != None && KFWeapon(I).bKFNeverThrow)
			{
				return;
			}

			if (KFWeapon(I) != None && KFWeapon(I).SellValue != -1)
			{
				Price = KFWeapon(I).SellValue;
			}
			else
			{
				Price = (class<KFWeaponPickup>(WClass.default.PickupClass).default.Cost * 0.75f);

				if (KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != None)
				{
					Price *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.Default.PickupClass);
				}
			}

			if (class'DualWeaponsManager'.Static.IsDualWeapon(WClass,SecType))
			{
				NewWep = Spawn(SecType);
				
				if(WClass != class'Dualies')
				{
					Price *= 0.5f;
					NewWep.SellValue = Price;
				}
				
				NewWep.GiveTo(self);
			}

			if (I == Weapon || I == PendingWeapon)
			{
				ClientCurrentWeaponSold();
			}

			PlayerReplicationInfo.Score += int(Price);

			I.Destroy();

			SetTraderUpdate();

			if (KFGameType(Level.Game) != None)
			{
				KFGameType(Level.Game).WeaponDestroyed(WClass);
			}
			return;
		}
	}
}

function ServerBuyKevlar()
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

    if (KFPRI.ClientVeteranSkill != None && KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest') < 0.f)
    {
        return;
    }

	Super.ServerBuyKevlar();
}

function AddDefaultInventory()
{
	Super.AddDefaultInventory();

	if (W_Frag_Weap(Weapon) != None)
	{
		EquipAnythingButGrenade();
	}
}

function EquipAnythingButGrenade()
{
	local Weapon OtherWeapon;
	local float Rating;
	OtherWeapon = Inventory.RecommendWeapon(Rating);

	if (OtherWeapon == None)
	{
		OtherWeapon = Weapon(FindInventoryType(class'KFTurbo.W_Knife_Weap'));

		if (OtherWeapon == None)
		{
			return;
		}
	}

	Weapon = OtherWeapon;
	PendingWeapon = None;
	Weapon.BringUp();
}

function TossWeapon(Vector TossVel)
{
	local Vector X,Y,Z;
	local Inventory WeaponToToss;
	local float Rating;

	if (Level.bLevelChange)
	{
		return;
	}

	if (Health > 0)
	{
		Super.TossWeapon(TossVel);
		return;
	}

	if (KFWeapon(Weapon) == None || !KFWeapon(Weapon).bKFNeverThrow)
	{
		Super.TossWeapon(TossVel);
		return;
	}

	WeaponToToss = Inventory.RecommendWeapon(Rating);

	if (KFWeapon(WeaponToToss) == None || Rating < -50 || KFWeapon(WeaponToToss).bKFNeverThrow)
	{
		return;
	}

	WeaponToToss.Velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	WeaponToToss.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);
}

exec function TossCash(int Amount)
{
    local Vector X,Y,Z;
    local CashPickup CashPickup;
    local Vector TossVel;

	// Relax the fix to cash tossing exploit.
	if (CashTossTimer > Level.TimeSeconds)
	{
		return;
	}
	
	CashTossTimer = Level.TimeSeconds + 0.1f;
	
	Amount = Max(Amount, 50);
	Amount = Min(Amount, int(Controller.PlayerReplicationInfo.Score));
	if(Amount <= 0)
	{
		return;
	}

    GetAxes(Rotation, X, Y, Z);

    TossVel = Vector(GetViewRotation());
    TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);

    CashPickup = Spawn(CashPickupClass, self,, Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);

	if (CashPickup == None)
	{
		return;
	}
	
	CashPickup.CashAmount = Amount;
	CashPickup.bDroppedCash = true;
	CashPickup.RespawnTime = 0;
	CashPickup.Velocity = TossVel;
	CashPickup.DroppedBy = Controller;
	CashPickup.InitDroppedPickupFor(None);
	Controller.PlayerReplicationInfo.Score -= Amount;

	//KFPawn::LastDropCashMessageTime doesn't appear to ever be set.
	if (Level.Game.NumPlayers > 1 && Level.TimeSeconds - LastDropCashMessageTime > DropCashMessageDelay)
	{
		PlayerController(Controller).Speech('AUTO', 4, "");
	}
}

function bool DoJump( bool bUpdating )
{
    local float JumpModifier;
	local bool bResult, bOriginalIsWalking;

	if (Role == Role_Authority)
	{
    	JumpModifier = GetJumpZModifier();
		MaxFallSpeed = FMax(default.MaxFallSpeed * JumpModifier, default.MaxFallSpeed);
		JumpZ = default.JumpZ * JumpModifier;
	}
    
	bOriginalIsWalking = bIsWalking;
	bIsWalking = false;
	bResult = Super(KFPawn).DoJump(bUpdating);
	bIsWalking = bOriginalIsWalking;

	return bResult;
}

simulated function float GetJumpZModifier()
{
	return Super.GetJumpZModifier() * JumpZMultiplier;
}

defaultproperties
{
	bDebugServerBuyWeapon=false
	HealthHealingTo=0
	JumpZMultiplier=1.f
	CashPickupClass=class'TurboCashPickup'

	RequiredEquipment(0)="KFTurbo.W_Knife_Weap"
	RequiredEquipment(1)="KFTurbo.W_9MM_Weap"
	RequiredEquipment(2)="KFTurbo.W_Frag_Weap"
    RequiredEquipment(3)="KFTurbo.W_Syringe_Weap"
	RequiredEquipment(4)="KFMod.Welder"
}
