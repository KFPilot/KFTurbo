//Killing Floor Turbo WeaponHelper
//Anti redundancy class. Handles logic for weapons.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class WeaponHelper extends Object;

enum ETraceResult
{
	TR_Block,
	TR_Hit,
	TR_None
};

struct TraceHitInfo
{
	var ETraceResult HitResult;
	var Actor HitActor;
	var int HitCount;
	var vector HitLocation;
	var vector HitDirection;
	var array<int> HitPoints;
};

//Takes into account cylinder size when giving back a distance.
static final function float GetDistanceToClosestPointOnActor(Vector Location, Actor Target)
{
	local float DistZ;

	Location = (Location - Target.Location);
	DistZ = FMax(0.f, Abs(Location.Z) - Target.CollisionHeight);
	
	Location.X = Abs(Location.X);
	Location.Y = Abs(Location.Y);
	Location.Z = 0.f;
	
	Location -= (Normal(Location) * Target.CollisionRadius);
	Location.Z = DistZ;

	return VSize(Location);
}

//Takes into account both actors' cylinder size when giving back a distance.
static final function float GetDistanceBetweenActors(Actor A, Actor B)
{
	local float DistZ;
	local Vector Distance;

	Distance = (A.Location - B.Location);
	
	//Get result Z component and clear it out from distance vector for now.
	DistZ = FMax(0.f, Abs(Distance.Z) - (A.CollisionHeight + B.CollisionHeight));
	Distance.Z = 0.f;
	
	//Remove sum of cylinder sizes from the XY component.
	Distance.X = Abs(Distance.X);
	Distance.Y = Abs(Distance.Y);
	Distance -= (Normal(Distance) * (A.CollisionRadius + B.CollisionRadius));

	//Put it all back together.
	Distance.X = FMax(Distance.X, 0.f);
	Distance.Y = FMax(Distance.Y, 0.f);
	Distance.Z = DistZ;
	
	return VSize(Distance);
}

static final function Actor GetExtendedCollisionFor(xPawn Pawn)
{
	if (KFPawn(Pawn) != None)
	{
		return KFPawn(Pawn).AuxCollisionCylinder;
	}
	
	if (KFMonster(Pawn) != None)
	{
		return KFMonster(Pawn).MyExtCollision;
	}

	return None;
}

static final function PenetratingWeaponTrace(Vector TraceStart, Rotator Direction, KFWeapon Weapon, KFFire Fire, int PenetrationMax, float PenetrationMultiplier)
{
	local Actor HitActorExtendedCollision;
	local array<Actor> IgnoreActors;
	local Vector TraceEnd, MomentumVector;
	local KFPlayerReplicationInfo KFPRI;
	local int HitCount;
	local float WeaponPenetrationMultiplier;
	local int NumberMonstersHit;
	local array<TraceHitInfo> HitList;
	local int HitListIndex;

	HitCount = 0;
	NumberMonstersHit = 0;
	WeaponPenetrationMultiplier = 1.f;
	PenetrationMax++;

	KFPRI = KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo);

	if (Weapon.Instigator != None && KFPRI != None && class<TurboVeterancyTypes>(KFPRI.ClientVeteranSkill) != None)
	{
		WeaponPenetrationMultiplier = class<TurboVeterancyTypes>(KFPRI.ClientVeteranSkill).static.GetWeaponPenetrationMultiplier(KFPRI, Fire);
		PenetrationMax = Round(float(PenetrationMax) * WeaponPenetrationMultiplier);
		
		if (PenetrationMax > 1 && PenetrationMultiplier <= 0.f)
		{
			PenetrationMultiplier = 0.5f; //If the weapon didn't provide a weapon penetration modifier (probably because it originally didn't penetrate), give it a nice 50% damage loss.
		}

		if (PenetrationMultiplier < 1.f && WeaponPenetrationMultiplier > 1.f)
		{
			PenetrationMultiplier = PenetrationMultiplier ** (1.f / WeaponPenetrationMultiplier);
		}
	}

	GetTraceInfo(Weapon, Fire, TraceStart, Direction, TraceEnd, MomentumVector);

	while (HitCount < PenetrationMax)
	{
		HitList.Length = HitList.Length + 1;
		HitListIndex = HitList.Length - 1;
		HitList[HitListIndex] = WeaponTrace(TraceStart, TraceEnd, Weapon);
		HitList[HitListIndex].HitCount = HitCount;

		if (HitList[HitListIndex].HitResult == TR_Block)
		{
			break;
		}

		if (HitList[HitListIndex].HitResult == TR_Hit)
		{
			HitCount++;
		}

		if (HitList[HitListIndex].HitActor != None)
		{
			//Need to go find the extended collision if we hit the pawn.
			if (xPawn(HitList[HitListIndex].HitActor) != None)
			{
				HitActorExtendedCollision = GetExtendedCollisionFor(xPawn(HitList[HitListIndex].HitActor));

				if (HitActorExtendedCollision != None)
				{
					HitActorExtendedCollision.SetCollision(false);
					IgnoreActors.Length = IgnoreActors.Length + 1;
					IgnoreActors[IgnoreActors.Length - 1] = HitActorExtendedCollision;
				}
			}
			
			HitList[HitListIndex].HitActor.SetCollision(false);
			IgnoreActors[IgnoreActors.Length] = HitList[HitListIndex].HitActor;
		}

		TraceStart = HitList[HitListIndex].HitLocation;

		if(VSize(TraceStart - TraceEnd) < 0.1)
		{
			break;
		}
	}

	EnableCollision(IgnoreActors);

	NumberMonstersHit = 0;

	for (HitCount = 0; HitCount < HitList.Length; HitCount++)
	{
		if (HitList[HitCount].HitResult == TR_None || HitList[HitCount].HitActor == None)
		{
			continue;
		}

		PerformTraceHit(Fire, HitList[HitCount], MomentumVector, (PenetrationMultiplier ** float(HitCount)), NumberMonstersHit);
	}
}

static final function TraceHitInfo WeaponTrace(Vector TraceStart, Vector TraceEnd, KFWeapon Weapon)
{
	local TraceHitInfo HitInfo;	
	HitInfo.HitActor = Weapon.Instigator.HitPointTrace(HitInfo.HitLocation, HitInfo.HitDirection, TraceEnd, HitInfo.HitPoints, TraceStart,, 1);
	
	if (HitInfo.HitActor == None)
	{
		HitInfo.HitLocation = TraceEnd;
		HitInfo.HitDirection = Normal(TraceEnd - TraceStart);
		HitInfo.HitResult = TR_None;
		return HitInfo;
	}

	if(ShouldSkipActor(HitInfo.HitActor, Weapon.Instigator))
	{
		if (xPawn(HitInfo.HitActor.Base) != None)
		{
			HitInfo.HitActor = HitInfo.HitActor.Base;
		}

		HitInfo.HitResult = TR_None;
		return HitInfo;
	}

	if(IsWorldHit(HitInfo.HitActor))
	{
		if(KFWeaponAttachment(Weapon.ThirdPersonActor) != None)
		{
			KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(HitInfo.HitActor, HitInfo.HitLocation, HitInfo.HitDirection);		
		}

		HitInfo.HitResult = TR_Block;
		return HitInfo;
	}

	if (xPawn(HitInfo.HitActor.Base) != None)
	{
		HitInfo.HitActor = HitInfo.HitActor.Base;
	}

	HitInfo.HitResult = TR_Hit;
	return HitInfo;
}

static final function PerformTraceHit(KFFire Fire, TraceHitInfo HitInfo, Vector Momentum, float PenetrationMultiplier, out int NumberMonstersHit)
{
	local KFPawn HitPawn;
	local TurboPlayerEventHandler.MonsterHitData HitData;

	HitPawn = KFPawn(HitInfo.HitActor);
	if (HitPawn != None)
	{
		if(!HitPawn.bDeleteMe)
		{
			HitPawn.ProcessLocationalDamage(int(Fire.DamageMax * PenetrationMultiplier), Fire.Instigator, HitInfo.HitLocation, Momentum, Fire.DamageType, HitInfo.HitPoints);
		}

		return;
	}

	if (NumberMonstersHit == 0)
	{
		class'TurboPlayerEventHandler'.static.CollectMonsterHitData(HitInfo.HitActor, HitInfo.HitLocation, Normal(Momentum), HitData);
	}

	if (HitData.Monster != None)
	{
		NumberMonstersHit++;
	}

	HitInfo.HitActor.TakeDamage(int(Fire.DamageMax * PenetrationMultiplier), Fire.Instigator, HitInfo.HitLocation, Momentum, Fire.DamageType);

	if (HitData.DamageDealt > 0)
	{
		class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Fire.Instigator.Controller, Fire, HitData);
	}
}

//Gets the trace endpoint and momentum vector given a Weapon and KFFire.
static final function GetTraceInfo(Weapon Weapon, KFFire Fire, Vector Start, Rotator Direction, out Vector TraceEnd, out Vector Momentum)
{
	TraceEnd = Start + (Fire.TraceRange * Vector(Direction));
	Momentum = Fire.Momentum * Vector(Direction);
}

//Returns true if this actor is a world object.
static final function bool IsWorldHit(Actor Other)
{
	if(Other == None)
	{
		return false;
	}

	if (Other.bWorldGeometry || Other == Other.Level)
	{
		return true;
	}

	if (Mover(Other) != None)
	{
		return true;
	}

	if (BlockingVolume(Other) != None)
	{
		return true;
	}

	return false;
}

static final function bool ShouldSkipActor(Actor Other, Pawn Instigator)
{
	return Other == Instigator || Other.Base == Instigator; 
}

static final function EnableCollision(Array<Actor> IgnoreList)
{
	local int i;

	for (i = 0; i < IgnoreList.Length; i++)
	{
		if(IgnoreList[i] != None)
		{
      		IgnoreList[i].SetCollision(true);
		}
	}
}

static final function NotifyPostProjectileSpawned(Projectile SpawnedProjectile)
{
	if (SpawnedProjectile == None || SpawnedProjectile.Role != ROLE_Authority)
	{
		return;
	}

	if (SpawnedProjectile.Instigator == None || SpawnedProjectile.Instigator.Weapon == None)
	{
		return;
	}

	if (BaseProjectileFire(SpawnedProjectile.Instigator.Weapon.GetFireMode(0)) == None)
	{
		return;
	}

	BaseProjectileFire(SpawnedProjectile.Instigator.Weapon.GetFireMode(0)).PostSpawnProjectile(SpawnedProjectile);
}

static final function bool AlreadyHitPawn(out Actor HitActor, out array<Pawn> HitPawnList)
{
	local int Index;
	local Pawn Pawn;

	Pawn = Pawn(HitActor);
	if (Pawn == None)
	{
		Pawn = Pawn(HitActor.Base);
	}

	if (Pawn == None)
	{
		return false;
	}
	
	HitActor = Pawn;

	for (Index = 0; Index < HitPawnList.Length; Index++)
	{
		if (Pawn == HitPawnList[Index])
		{
			return true;
		}
	}

	HitPawnList[HitPawnList.Length] = Pawn;
	return false;
}

static final function float GetMedicGunChargeBar(KFMedicGun Weapon)
{
	return FClamp(float(Weapon.HealAmmoCharge) / float(Weapon.default.HealAmmoCharge), 0, 1);
}

static final function TickMedicGunRecharge(KFMedicGun Weapon, float DeltaTime, out float HealAmmoAmount)
{
	local float RegenAmount;

	if (Weapon.Role != ROLE_Authority)
	{
		return;
	}

	if (HealAmmoAmount >= float(Weapon.default.HealAmmoCharge))
	{
		return;
	}

	RegenAmount = 10.f;

	if (GetVeterancyFromWeapon(Weapon) != None)
	{
		RegenAmount *= GetVeterancyFromWeapon(Weapon).Static.GetSyringeChargeRate(KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo));
	}

	HealAmmoAmount += (RegenAmount * DeltaTime) / Weapon.AmmoRegenRate;
}

static final function bool ConsumeMedicGunAmmo(KFMedicGun Weapon, int Mode, float Amount, out float HealAmmoAmount, out byte Status)
{
	if (Mode == 1)
	{
		Status = 0;

		if (Amount > HealAmmoAmount)
		{
			Status = 1;
		}

		HealAmmoAmount -= Amount;
		return true;
	}

	return false;
}

static final function class<KFVeterancyTypes> GetVeterancyFromWeapon(Weapon Weapon)
{
	if (Weapon == None || Weapon.Instigator == None || KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo) == None)
	{
		return None;
	}

	return KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo).ClientVeteranSkill;
}

static final function BeginGrenadeSmoothRotation(Nade Grenade, float UpwardOffset)
{
	local float Roll;
	local Vector X, Y, Z;
	Grenade.DesiredRotation = Rotator(Normal(Vector(Grenade.Rotation) + vect(0, 0, 1000)));
	Grenade.DesiredRotation.Roll = Roll;
	Grenade.SetRotation(Grenade.DesiredRotation);
	
	if (Grenade.Class != class'KFMod.Nade')
	{
		GetUnAxes(Grenade.Rotation, X, Y, Z);
		Grenade.PrePivot -= Z * UpwardOffset;
	}

	Grenade.SetPhysics(PHYS_None);
}

//Helpers to do hint checking for us.
static final function WeaponCheckForHint(KFWeapon Weapon, int HintID)
{
	local KFPlayerController PC;

	if (Weapon == None || Weapon.ClientGrenadeState == GN_BringUp)
	{
		return;
	}

	PC = KFPlayerController(Weapon.Instigator.Controller);

	if (PC == None)
	{
		return;
	}

	PC.CheckForHint(HintID);
}

//Helpers to do pullout remarks for us.
static final function WeaponPulloutRemark(KFWeapon Weapon, int RemarkID)
{
	local KFPlayerController PC;

	if (Weapon == None || Weapon.ClientGrenadeState == GN_BringUp)
	{
		return;
	}

	PC = KFPlayerController(Weapon.Instigator.Controller);

	if (PC == None)
	{
		return;
	}

	PC.WeaponPulloutRemark(RemarkID);
}

static final function class<KFWeaponPickup> GetOriginalWeaponPickup(class<KFWeaponPickup> WeaponPickup)
{
	if (WeaponPickup == None)
	{
		return None;
	}

	if (WeaponPickup.default.VariantClasses.Length == 0)
	{
		return WeaponPickup;
	}

	return class<KFWeaponPickup>(WeaponPickup.default.VariantClasses[0]);
}

//Checks if pickup is a single version of the provided dual weapon and does "already has gun" notification. Returns true if weapon was rejected (because we have the dual version of it).
static final function bool DualWeaponHandlePickupQuery(KFWeapon DualWeapon, Pickup ItemPickup)
{
	local class<KFWeaponPickup> WeaponPickupClass, DemoReplacementClass;

	if (DualWeapon == None || ItemPickup == None)
	{
		return false;
	}

	//It's hard to tell what we're looking at - so always resolve the non-variant class.
	WeaponPickupClass = GetOriginalWeaponPickup(class<KFWeaponPickup>(ItemPickup.Class));
	if (WeaponPickupClass == None)
	{
		return false;
	}

	DemoReplacementClass = GetOriginalWeaponPickup(class<KFWeaponPickup>(DualWeapon.DemoReplacement.default.PickupClass));
	if (WeaponPickupClass != DemoReplacementClass)
	{
		return false;
	}
	
	if( DualWeapon.LastHasGunMsgTime < DualWeapon.Level.TimeSeconds && PlayerController(DualWeapon.Instigator.Controller) != none )
	{
		DualWeapon.LastHasGunMsgTime = DualWeapon.Level.TimeSeconds + 0.5;
		PlayerController(DualWeapon.Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages', 1);
	}

	return true;
}

static final function DualWeaponGiveTo(KFWeapon DualWeapon, Pawn Other, optional Pickup Pickup)
{
	local class<KFWeaponPickup> WeaponPickupClass;
	local Inventory Inventory;
	local KFWeapon Weapon;
	local int OldAmmo;
	local bool bNoPickup;

	WeaponPickupClass = GetOriginalWeaponPickup(class<KFWeaponPickup>(DualWeapon.DemoReplacement.default.PickupClass));
	DualWeapon.MagAmmoRemaining = 0;

	for(Inventory = Other.Inventory; Inventory != None; Inventory = Inventory.Inventory)
	{
		if (!ClassIsChildOf(Inventory.PickupClass, WeaponPickupClass))
		{
			continue;
		}

		Weapon = KFWeapon(Inventory);

		if( WeaponPickup(Pickup)!= none )
		{
			WeaponPickup(Pickup).AmmoAmount[0] += Weapon(Inventory).AmmoAmount(0);
		}
		else
		{
			OldAmmo = Weapon.AmmoAmount(0);
			bNoPickup = true;
		}

		DualWeapon.MagAmmoRemaining = Weapon.MagAmmoRemaining;
		Inventory.Destroyed();
		Inventory.Destroy();
		break;
	}

	if (KFWeaponPickup(Pickup) != None && Pickup.bDropped)
	{
		DualWeapon.MagAmmoRemaining = Clamp(DualWeapon.MagAmmoRemaining + KFWeaponPickup(Pickup).MagAmmoRemaining, 0, DualWeapon.MagCapacity);
	}
	else
	{
		if (class<KFWeapon>(DualWeapon.DemoReplacement) != None)
		{
			DualWeapon.MagAmmoRemaining = Clamp(DualWeapon.MagAmmoRemaining + class<KFWeapon>(DualWeapon.DemoReplacement).default.MagCapacity, 0, DualWeapon.MagCapacity);
		}
		else
		{
			DualWeapon.MagAmmoRemaining = Clamp(DualWeapon.MagAmmoRemaining, 0, DualWeapon.MagCapacity);
		}
	}

	if (bNoPickup)
	{
		DualWeapon.AddAmmo(OldAmmo, 0);
		Clamp(Ammunition(DualWeapon.Instigator.FindInventoryType(DualWeapon.GetFireMode(0).AmmoClass)).AmmoAmount, 0, DualWeapon.MaxAmmo(0));
	}
}

static final function DualWeaponDropFrom(KFWeapon DualWeapon, Vector StartLocation)
{
	local int ModeIndex;
	local KFWeaponPickup Pickup;
	local KFWeapon Weapon;
	local Ammunition WeaponAmmunition;
	local int AmmoThrown, OtherAmmo;

	if(DualWeapon == None && !DualWeapon.bCanThrow)
	{
		return;
	}

	AmmoThrown = DualWeapon.AmmoAmount(0);
	DualWeapon.ClientWeaponThrown();

	for (ModeIndex = 0; ModeIndex < DualWeapon.NUM_FIRE_MODES; ModeIndex++)
	{
		if (DualWeapon.GetFireMode(ModeIndex).bIsFiring)
		{
			DualWeapon.StopFire(ModeIndex);
		}
	}

	if ( DualWeapon.Instigator != None )
	{
		DualWeapon.DetachFromPawn(DualWeapon.Instigator);
	}

	if(DualWeapon.Instigator != None && DualWeapon.Instigator.Health > 0)
	{
		OtherAmmo = AmmoThrown / 2;
		AmmoThrown -= OtherAmmo;
		Weapon = DualWeapon.Spawn(class<KFWeapon>(DualWeapon.DemoReplacement));
		Weapon.GiveTo(DualWeapon.Instigator);
		
		WeaponAmmunition = Ammunition(DualWeapon.Instigator.FindInventoryType(DualWeapon.GetFireMode(0).AmmoClass));

		if (WeaponAmmunition != None)
		{
			WeaponAmmunition.AmmoAmount = OtherAmmo;
		}

		Weapon.MagAmmoRemaining = DualWeapon.MagAmmoRemaining / 2;
		DualWeapon.MagAmmoRemaining = Max( DualWeapon.MagAmmoRemaining - Weapon.MagAmmoRemaining, 0);
	}

	Pickup = DualWeapon.Spawn(class<KFWeaponPickup>(DualWeapon.DemoReplacement.default.PickupClass),,, StartLocation);

	if (Pickup != None)
	{
		Pickup.InitDroppedPickupFor(DualWeapon);
		Pickup.Velocity = DualWeapon.Velocity;
		Pickup.AmmoAmount[0] = AmmoThrown;

		if(Pickup != None)
		{
			Pickup.MagAmmoRemaining = DualWeapon.MagAmmoRemaining;
		}

		if (DualWeapon.Instigator.Health > 0)
		{
			Pickup.bThrown = true;
		}
	}

    DualWeapon.Destroyed();
	DualWeapon.Destroy();
}

static final function DualWeaponPutDown(KFWeapon DualWeapon)
{
	if (DualWeapon.Instigator.PendingWeapon.class == DualWeapon.DemoReplacement)
	{
		DualWeapon.bIsReloading = false;
	}
}

static final function bool SingleWeaponHandlePickupQuery(KFWeapon SingleWeapon, Pickup ItemPickup)
{
	local class<KFWeaponPickup> WeaponPickupClass, ItemPickupClass;
	WeaponPickupClass = GetOriginalWeaponPickup(class<KFWeaponPickup>(SingleWeapon.PickupClass));
	ItemPickupClass = GetOriginalWeaponPickup(class<KFWeaponPickup>(ItemPickup.Class));

	if (WeaponPickupClass == ItemPickupClass)
	{
		if ( KFPlayerController(SingleWeapon.Instigator.Controller) != none )
		{
			KFPlayerController(SingleWeapon.Instigator.Controller).PendingAmmo = WeaponPickup(ItemPickup).AmmoAmount[0];
		}

		return true;
	}

	return false;
}

static final function bool SingleWeaponSpawnCopy(KFWeaponPickup SingleWeaponPickup, Pawn Other, class<KFWeapon> DualWeaponClass)
{
	local Inventory Inventory;
	local KFWeapon Weapon;
	local class<KFWeaponPickup> WeaponPickupClass, InventoryPickupClass;
	WeaponPickupClass = GetOriginalWeaponPickup(SingleWeaponPickup.Class);

	if (WeaponPickupClass == None)
	{
		return false;
	}

	for(Inventory = Other.Inventory; Inventory != None; Inventory = Inventory.Inventory)
	{
		InventoryPickupClass = GetOriginalWeaponPickup(class<KFWeaponPickup>(Inventory.PickupClass));
		if (InventoryPickupClass != WeaponPickupClass)
		{
			continue;
		}

		if(SingleWeaponPickup.Inventory != None)
		{
			SingleWeaponPickup.Inventory.Destroy();
		}

		SingleWeaponPickup.InventoryType = DualWeaponClass;

		Weapon = KFWeapon(Inventory);

		if (Weapon != None)
		{
			SingleWeaponPickup.AmmoAmount[0] += Weapon.AmmoAmount(0);
			SingleWeaponPickup.MagAmmoRemaining += Weapon.MagAmmoRemaining;
		}

		Inventory.Destroyed();
		Inventory.Destroy();
		return true;
	}

	SingleWeaponPickup.InventoryType = SingleWeaponPickup.default.InventoryType;
	return false;
}

static final function OnShotgunPenetratingProjectileHit(ShotgunBullet Projectile, Actor HitActor, float PreviousDamage)
{
	if (Projectile == None || Projectile.Role != ROLE_Authority)
	{
		return;
	}

	//Not considered a valid penetrated hit if PreviousDamage was default or if PreviousDamage is equal to current Damage.
	if (PreviousDamage == Projectile.default.Damage || PreviousDamage == Projectile.Damage)
	{
		return;
	}
	
	if (Monster(HitActor) == None && ExtendedZCollision(HitActor) == None)
	{
		return;
	}

	if (Projectile.Instigator == None || PlayerController(Projectile.Instigator.Controller) == None)
	{
		return;
	}

	class'V_SupportSpec'.static.RewardPenetrationShotgunDamage(PlayerController(Projectile.Instigator.Controller), Projectile.Damage);
}

static final function OnWeaponFire(WeaponFire FireMode)
{
	if (FireMode != None && FireMode.Level != None)
	{
		TurboGameReplicationInfo(FireMode.Level.GRI).OnWeaponFire(FireMode);
	}
	
	if (FireMode.Instigator != None)
	{
		class'TurboPlayerEventHandler'.static.BroadcastPlayerFire(FireMode.Instigator.Controller, FireMode);
	}   
}

static final function OnShotgunFire(KFShotgunFire FireMode, int FireEffectCount, out array<W_BaseShotgunBullet.HitRegisterEntry> HitRegistryList)
{
	HitRegistryList.Length = HitRegistryList.Length + 1;
	HitRegistryList[HitRegistryList.Length - 1].HitRegisterCount = FireEffectCount;
	HitRegistryList[HitRegistryList.Length - 1].Expiration = FireMode.Level.TimeSeconds + 4.f;

	if (FireMode != None && FireMode.Level != None)
	{
		TurboGameReplicationInfo(FireMode.Level.GRI).OnShotgunFire(FireMode);
	}

	OnWeaponFire(FireMode);
}

// Melee weapons are considered a separate "fire" from guns and do not call OnWeaponFire.
static final function OnMeleeFire(KFMeleeFire FireMode)
{
	if (FireMode != None && FireMode.Level != None)
	{
		TurboGameReplicationInfo(FireMode.Level.GRI).OnMeleeFire(FireMode);
	}
	
	if (FireMode.Instigator != None)
	{
		class'TurboPlayerEventHandler'.static.BroadcastPlayerMeleeFire(FireMode.Instigator.Controller, FireMode);
	}
}

static final function OnMedicDartFire(WeaponFire FireMode)
{
	if (FireMode != None && FireMode.Level != None)
	{
		TurboGameReplicationInfo(FireMode.Level.GRI).OnMedicDartFire(FireMode);
	}
	
	if (FireMode.Instigator != None)
	{
		class'TurboPlayerEventHandler'.static.BroadcastPlayerMedicDartFire(FireMode.Instigator.Controller, FireMode);
	}   
}

static final function OnWeaponReload(KFWeapon Weapon)
{
	if (Weapon.Instigator != None)
	{
		class'TurboPlayerEventHandler'.static.BroadcastPlayerReload(Weapon.Instigator.Controller, Weapon);
	}
}

static final function Projectile SpawnProjectile(BaseProjectileFire ProjectileFire, Vector Start, Rotator Dir)
{
    local Projectile Projectile;

    if (ProjectileFire.GetDesiredProjectileClass() != None)
	{
		Projectile = ProjectileFire.Weapon.Spawn(ProjectileFire.GetDesiredProjectileClass(), ProjectileFire.Weapon,, Start, Dir);
	}
    
    if (Projectile == None)
    {
        Projectile = ProjectileFire.ForceSpawnProjectile(Start,Dir);
    }

    if (Projectile == None)
    {
        return None;
    }

    ProjectileFire.PostSpawnProjectile(Projectile);

    return Projectile;
}

static final function Projectile ForceSpawnProjectile(BaseProjectileFire ProjectileFire, Vector Start, Rotator Dir)
{
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local Projectile Projectile;

    Other = ProjectileFire.Weapon.Trace(HitLocation, HitNormal, Start, ProjectileFire.Instigator.Location + ProjectileFire.Instigator.EyePosition(), false,vect(0,0,1));

    if (Other != None)
    {
        Start = HitLocation;
    }

    if (ProjectileFire.GetDesiredProjectileClass() != None)
	{
		Projectile = ProjectileFire.Weapon.Spawn(ProjectileFire.GetDesiredProjectileClass(), ProjectileFire.Weapon,, Start, Dir);
	}
    
    return Projectile;
}

static final function GrenadeTakeDamage(Nade Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (Monster(InstigatedBy) != none || InstigatedBy == Projectile.Instigator)
	{
        if(class<SirenScreamDamage>(DamageType) != None)
        {
            Projectile.Disintegrate(HitLocation, vect(0,0,1));
        }
        else
        {
            Projectile.Explode(HitLocation, vect(0,0,1));
        }
    }
}

static final function M79GrenadeTakeDamage(M79GrenadeProjectile Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (Monster(InstigatedBy) != none || InstigatedBy == Projectile.Instigator)
	{
        if(class<SirenScreamDamage>(DamageType) != None)
        {
            Projectile.Disintegrate(HitLocation, vect(0,0,1));
        }
        else
        {
            Projectile.Explode(HitLocation, vect(0,0,1));
        }
    }
}

static final function LawProjTakeDamage(LawProj Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (Monster(InstigatedBy) != none || InstigatedBy == Projectile.Instigator)
	{
        if(class<SirenScreamDamage>(DamageType) == None)
        {
            Projectile.Explode(HitLocation, vect(0,0,1));
        }
    }
}

static final function SealSquealProjTakeDamage(SealSquealProjectile Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if (Monster(InstigatedBy) != none || InstigatedBy == Projectile.Instigator)
	{
        if(class<SirenScreamDamage>(DamageType) != None)
        {
			return; //Seal Squeal does not disintegrate;
        }
        else
        {
            Projectile.Explode(HitLocation, vect(0,0,1));
        }
    }
}

static final function SeekerSixProjTakeDamage(SeekerSixRocketProjectile Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if(class<SirenScreamDamage>(DamageType) != None)
	{
		Projectile.Disintegrate(HitLocation, vect(0,0,1));
	}
}

static final function HuskGunProjTakeDamage(HuskGunProjectile Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if(!Projectile.bDud)
	{
		Projectile.Explode(HitLocation, vect(0,0,0));
	}
}

static final function FlareRevolverProjTakeDamage(FlareRevolverProjectile Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if(class<SirenScreamDamage>(DamageType) != None)
	{
		Projectile.Disintegrate(HitLocation, vect(0,0,1));
	}
	else
	{
		if(!Projectile.bDud)
		{
			Projectile.Explode(HitLocation, vect(0,0,0));
		}
	}
}

static final function SPGrenadeProjTakeDamage(SPGrenadeProjectile Projectile, int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	if(class<SirenScreamDamage>(DamageType) != None)
	{
		Projectile.Disintegrate(HitLocation, vect(0,0,1));
	}
    else
    {
        Projectile.Explode(HitLocation, vect(0,0,0));
    }
}

static final function CrossbowProjectileProcessTouch(Projectile Projectile, float HeadshotDamageMulti, class<DamageType> HeadshotDamageType, Actor Other, vector HitLocation, Sound HitArmor, Sound HitFlesh, out Pawn IgnoreImpactPawn, out byte bHasRegisteredHit)
{
	local vector X,End,HL,HN;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
    local KFPawn HitPawn;
	local bool	bHitWhipAttachment;
	
	local TurboPlayerEventHandler.MonsterHitData HitData;

	if (Other == None || Other == Projectile.Instigator || Other.Base == Projectile.Instigator || !Other.bBlockHitPointTraces || Other == IgnoreImpactPawn || (IgnoreImpactPawn != None && Other.Base == IgnoreImpactPawn))
	{
		return;
	}

	X =  Vector(Projectile.Rotation);

 	if (ROBulletWhipAttachment(Other) != None)
	{
    	bHitWhipAttachment=true;
		
        if (Other.Base.bDeleteMe)
		{
			return;
		}

		Other = Projectile.Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (65535 * X), HitPoints, HitLocation,, 1);

		if (Other == None || HitPoints.Length == 0)
		{
			return;
		}

		HitPawn = KFPawn(Other);

		if (Projectile.Role == ROLE_Authority && HitPawn != None)
		{
			if (!HitPawn.bDeleteMe)
			{
				HitPawn.ProcessLocationalDamage(Projectile.Damage, Projectile.Instigator, TempHitLocation, Projectile.MomentumTransfer * X, Projectile.MyDamageType, HitPoints);
			}

			Projectile.Damage /= 1.25;
			Projectile.Velocity *= 0.85;

			IgnoreImpactPawn = HitPawn;

			if (Projectile.Level.NetMode != NM_Client)
			{
				PlayHitNoise(Projectile, Pawn(Other) != None && Pawn(Other).ShieldStrength > 0, HitArmor, HitFlesh);
			}
		}

		return;
	}

	if (Projectile.Level.NetMode != NM_Client)
	{
		PlayHitNoise(Projectile, Pawn(Other) != None && Pawn(Other).ShieldStrength > 0, HitArmor, HitFlesh);
	}

	if (ExtendedZCollision(Other) != None)
	{
		Other = Other.Base;
	}

	if (Projectile.Physics == PHYS_Projectile && Pawn(Other) != None && Vehicle(Other) == None)
	{
		IgnoreImpactPawn = Pawn(Other);
    	class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Other, HitLocation, X, HitData);

		if (HitData.bIsHeadshot)
		{
			Other.TakeDamage(Projectile.Damage * HeadshotDamageMulti, Projectile.Instigator, HitLocation, Projectile.MomentumTransfer * X, HeadshotDamageType);
		}
		else
		{
			Other.TakeDamage(Projectile.Damage, Projectile.Instigator, HitLocation, Projectile.MomentumTransfer * X, Projectile.MyDamageType);
		}

		if (bHasRegisteredHit == 0 && Weapon(Projectile.Owner) != None && Projectile.Owner.Instigator != None)
		{
			bHasRegisteredHit = 1;
			class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Projectile.Owner.Instigator.Controller, Weapon(Projectile.Owner).GetFireMode(0), HitData);
		}

		Projectile.Damage /= 1.25;
		Projectile.Velocity *= 0.85;

		return;
	}

	if (Projectile.Level.NetMode != NM_DedicatedServer && SkeletalMesh(Other.Mesh) != None && Other.DrawType == DT_Mesh && Pawn(Other) != None)
	{
		End = Other.Location + X * 600.f;

		if (Other.Trace(HL, HN, End, Other.Location, False) != None)
		{
			Projectile.Spawn(Class'BodyAttacher', Other,, HitLocation).AttachEndPoint = HL - HN;
		}
	}
}

static function PlayHitNoise(Projectile Projectile, bool bArmored, Sound HitArmor, Sound HitFlesh)
{
	if (bArmored)
	{
		Projectile.PlaySound(HitArmor);   // implies hit a target with shield/armor
	}
	else
	{
		Projectile.PlaySound(HitFlesh);
	}
}

defaultproperties
{
}
