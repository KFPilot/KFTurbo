//Killing Floor Turbo WeaponHelper
//Anti redundancy class. Handles logic for weapons.
//Distributed under the terms of the GPL-2.0 License.
//For more information see https://github.com/KFPilot/KFTurbo.
class WeaponHelper extends Object;

enum ETraceResult
{
	TR_Block,
	TR_Hit,
	TR_None
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

static final function PenetratingWeaponTrace(Vector TraceStart, KFWeapon Weapon, KFFire Fire, int PenetrationMax, float PenetrationMultiplier)
{
	local Actor HitActor, HitActorExtCollision;
	local array<Actor> IgnoreActors;
	local Vector TraceEnd, MomentumVector;
	local Vector HitLocation;
	local int HitCount;
	local float WeaponPenetrationMultiplier;

	HitCount = 0;
	WeaponPenetrationMultiplier = 1.f;

	if (Weapon.Instigator != None && KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo) != None && class<TurboVeterancyTypes>(KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo).ClientVeteranSkill) != None)
	{
		WeaponPenetrationMultiplier = class<TurboVeterancyTypes>(KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo).ClientVeteranSkill).static.GetWeaponPenetrationMultiplier(KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo), Fire);

		if (PenetrationMultiplier < 1.f && WeaponPenetrationMultiplier > 1.f)
		{
			PenetrationMultiplier = PenetrationMultiplier ** (1.f / WeaponPenetrationMultiplier);
		}
		
		PenetrationMax = float(PenetrationMax) * WeaponPenetrationMultiplier;
	} 

	PenetrationMax++;
	GetTraceInfo(Weapon, Fire, TraceStart, TraceEnd, MomentumVector);

	while(HitCount < PenetrationMax)
	{
		HitActor = None;
		HitActorExtCollision = None;

		switch(WeaponTrace(TraceStart, TraceEnd, MomentumVector, Weapon, Fire, HitActor, HitLocation, (PenetrationMultiplier ** float(HitCount))))
		{
		case TR_Block:
			HitCount = PenetrationMax + 1;
			EnableCollision(IgnoreActors);
			return;
		case TR_Hit:
		case TR_None:
			HitCount++;
			break;
		}

		if (HitActor == None)
		{
			TraceStart = HitLocation;

			if (VSize(TraceStart - TraceEnd) < 0.1)
			{
				break;
			}

			continue;
		}

		//Needs to handle both player and monster extended collision.
		if (xPawn(HitActor.Base) != None)
		{
			HitActorExtCollision = HitActor;
			HitActor = HitActor.Base;
			
			HitActorExtCollision.SetCollision(false);
			IgnoreActors[IgnoreActors.Length] = HitActorExtCollision;
		}
		
		HitActor.SetCollision(false);
		IgnoreActors[IgnoreActors.Length] = HitActor;

		TraceStart = HitLocation;

		if(VSize(TraceStart - TraceEnd) < 0.1)
		{
			break;
		}
	}

	EnableCollision(IgnoreActors);
}

static final function ETraceResult WeaponTrace(Vector TraceStart, Vector TraceEnd, Vector MomentumVector, KFWeapon Weapon, KFFire Fire, out Actor HitActor, out Vector HitLocation, float DamageMultiplier)
{
	local KFPawn HitPawn;
	local Vector HitNormal;
	local array<int> HitPoints;

	HitActor = Fire.Instigator.HitPointTrace(HitLocation, HitNormal, TraceEnd, HitPoints, TraceStart,, 1);

	if(ShouldSkipActor(HitActor, Fire.Instigator))
	{
		HitActor = None;
		return TR_None;
	}

	if(IsWorldHit(HitActor))
	{
		if(KFWeaponAttachment(Weapon.ThirdPersonActor) != None)
		{
			KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(HitActor, HitLocation, HitNormal);		
		}

		return TR_Block;
	}

	HitPawn = KFPawn(HitActor);

	if ( HitPawn != none )
	{
		if(!HitPawn.bDeleteMe)
		{
			HitPawn.ProcessLocationalDamage(int(Fire.DamageMax * DamageMultiplier), Fire.Instigator, HitLocation, MomentumVector, Fire.DamageType, HitPoints);
		}
	}
    else
    {
		HitActor.TakeDamage(int(Fire.DamageMax * DamageMultiplier), Fire.Instigator, HitLocation, MomentumVector, Fire.DamageType);
	}

	return TR_Hit;
}

//Gets the trace endpoint and momentum vector given a Weapon and KFFire.
static final function GetTraceInfo(Weapon Weapon, KFFire Fire, Vector Start, out Vector TraceEnd, out Vector Momentum)
{
	local Vector X, Y, Z;
	Weapon.GetViewAxes(X, Y, Z);

	Fire.MaxRange();

	TraceEnd = Start + Fire.TraceRange * X;
	Momentum = Fire.Momentum * X;
}

//Returns true if this actor is a world object.
static final function bool IsWorldHit(Actor Other)
{
	if(Other == None)
	{
		return false;
	}

	return Other.bWorldGeometry || Other == Other.Level;
}

static final function bool ShouldSkipActor(Actor Other, Pawn Instigator)
{
	return Other == None || Other == Instigator || Other.Base == Instigator; 
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

	if (Pawn(HitActor.Base) != None)
	{
		HitActor = HitActor.Base;
	}

	Pawn = Pawn(HitActor);

	if (Pawn == None)
	{
		return false;
	}

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

static final function BeginGrenadeSmoothRotation(Nade Grenade, float DownwardOffset)
{
	local float Roll;
	local Vector X, Y, Z;
	Grenade.DesiredRotation = Rotator(Normal(Vector(Grenade.Rotation) + vect(0, 0, 1000)));
	Grenade.DesiredRotation.Roll = Roll;
	Grenade.SetRotation(Grenade.DesiredRotation);
	
	if (Grenade.Class != class'KFMod.Nade')
	{
		GetUnAxes(Grenade.Rotation, X, Y, Z);
		Grenade.PrePivot += Z * DownwardOffset;
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

static final function OnShotgunFire(KFShotgunFire FireMode)
{
	if (FireMode != None && FireMode.Level != None && TurboGameReplicationInfo(FireMode.Level.GRI) != None)
	{
		TurboGameReplicationInfo(FireMode.Level.GRI).OnShotgunFire(FireMode);
	}
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

defaultproperties
{
}
