class KFTTStatsGenerator extends Object
	abstract;

const STR_NA = "N/A";

final static function string FloatToString(float floatValue) {
	local string Str, Res;
	local int i;
	local float f;
	
	if (Abs(floatValue) <= 0.000)
		return "0.000";
	
	i = int(floatValue * 100.0);
	Str = string(i);
	if (i < 100) {
		Res = "0.";
		if (i < 10)
			Res $= "0";
		Res $= Str;
	}
	else {
		Res = Left(Str, Len(Str) - 2) $ "." $ Right(Str, 2);
	}
	
	f = (floatValue - float(int(floatValue * 100.0)) / 100.0) * 1000.0;
	Res $= string(int(Round(f)));
	
	return Res;
}

final static function string FloatToDegrees(float floatValue) {
	return FloatToString(15.0 * floatValue / 2730.0) $ Chr(176);
}

final static function string FloatToMeters(float floatValue) {
	return FloatToString(floatValue / 52.5) @ "m";
}

final static function string RadiansToDegrees(float floatValue) {
	return FloatToString(180.0 * floatValue / Pi) $ Chr(176);
}

/* NAME AND DESCRIPTION */

final static function string NA() {
	return STR_NA;
}

final static function string GetPerkString(KFPlayerReplicationInfo PRI) {
	if (PRI != None && PRI.ClientVeteranSkill != None)
		return PRI.ClientVeteranSkill.default.VeterancyName @ PRI.ClientVeteranSkillLevel;
	else
		return STR_NA;
}

final static function string GetWeaponName(KFWeapon W) {
	if (W != None && W.ItemName != "")
		return W.ItemName;
	else
		return STR_NA;
}

final static function string GetDescription(KFWeapon W) {
	if (W != None && W.Description != "")
		return W.Description;
	else
		return STR_NA;
}

/* DAMAGE */

private final static function int ActualDamage(KFPlayerReplicationInfo PRI, KFWeapon W, optional byte fireMode) {
	local int damage;

	if (class<KFFire>(W.default.FireModeClass[fireMode]) != None) {
		damage = class<KFFire>(W.default.FireModeClass[fireMode]).default.DamageMax;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			damage = PRI.ClientVeteranSkill.static.AddDamage(PRI, None, None, damage, class<KFFire>(W.default.FireModeClass[0]).default.DamageType);
	}
	else if (class<KFShotgunFire>(W.default.FireModeClass[0]) != None) {
		damage = class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass.default.Damage;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			damage = PRI.ClientVeteranSkill.static.AddDamage(PRI, None, None, damage, class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass.default.MyDamageType);
	}
	else if (class<KFMeleeFire>(W.default.FireModeClass[fireMode]) != None) {
		damage = class<KFMeleeFire>(W.default.FireModeClass[fireMode]).default.MeleeDamage;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			damage = PRI.ClientVeteranSkill.static.AddDamage(PRI, None, None, damage, class<KFMeleeFire>(W.default.FireModeClass[0]).default.HitDamageClass);
	}
	
	return damage;
}

private final static function int ActualImpactDamage(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int impactDamage;

	if (class<LAWProj>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
		impactDamage = class<LAWProj>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamage;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			impactDamage = PRI.ClientVeteranSkill.static.AddDamage(PRI, None, None, impactDamage, class<LAWProj>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType);
	}
	else if (class<M79GrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
		impactDamage = class<M79GrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamage;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			impactDamage = PRI.ClientVeteranSkill.static.AddDamage(PRI, None, None, impactDamage, class<M79GrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType);
	}
	else if (class<SPGrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
		impactDamage = class<SPGrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamage;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			impactDamage = PRI.ClientVeteranSkill.static.AddDamage(PRI, None, None, impactDamage, class<SPGrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType);
	}
	
	return impactDamage;
}

private final static function float ActualHeadshotMulti(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local float multi;

	if (class<KFFire>(W.default.FireModeClass[0]) != None && class<KFWeaponDamageType>(class<KFFire>(W.default.FireModeClass[0]).default.DamageType) != None) {
		multi = class<KFWeaponDamageType>(class<KFFire>(W.default.FireModeClass[0]).default.DamageType).default.HeadShotDamageMult;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<KFFire>(W.default.FireModeClass[0]).default.DamageType);
	}
	else if (class<KFShotgunFire>(W.default.FireModeClass[0]) != None) {
		if (class<ShotgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<ShotgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<ShotgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.MyDamageType);
		}
		else if (class<TrenchgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<TrenchgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<TrenchgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.MyDamageType);
		}
		else if (class<CrossbowArrow>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<CrossbowArrow>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<CrossbowArrow>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.MyDamageType);
		}
		else if (class<CrossbuzzsawBlade>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<CrossbuzzsawBlade>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<CrossbuzzsawBlade>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.MyDamageType);
		}
		else if (class<M99Bullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<M99Bullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<M99Bullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.MyDamageType);
		}
		else if (class<zedGunProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<KFWeaponDamageType>(class<zedGunProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.MyDamageType).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<zedGunProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.MyDamageType);
		}
		else if (class<M79GrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<KFWeaponDamageType>(class<M79GrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<M79GrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType);
		}
		else if (class<SPGrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<KFWeaponDamageType>(class<SPGrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<SPGrenadeProjectile>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType);
		}
		else if (class<LAWProj>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None) {
			multi = class<KFWeaponDamageType>(class<LAWProj>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType).default.HeadShotDamageMult;
			if (PRI != None && PRI.ClientVeteranSkill != None)
				multi *= PRI.ClientVeteranSkill.static.GetHeadshotDamMulti(PRI, None, class<LAWProj>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.ImpactDamageType);
		}
	}
	else if (class<KFMeleeFire>(W.default.FireModeClass[0]) != None && class<DamTypeMelee>(class<KFMeleeFire>(W.default.FireModeClass[0]).default.HitDamageClass) != None) {
		multi = class<DamTypeMelee>(class<KFMeleeFire>(W.default.FireModeClass[0]).default.HitDamageClass).default.HeadShotDamageMult;
	}

	return multi;
}

private final static function int ActualDamageRadius(KFWeapon W) {
	if (W.default.FireModeClass[0] != None && class<KFShotgunFire>(W.default.FireModeClass[0]) != None)
		return class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass.default.damageRadius;
	else
		return 0;
}

final static function string GetDamageRadius(KFWeapon W) {
	if (W.default.FireModeClass[0] != None && class<KFShotgunFire>(W.default.FireModeClass[0]) != None)
		return FloatToMeters(ActualDamageRadius(W));
	else
		return STR_NA;
}

/* DAMAGE TO STRING */

final static function string GetDamage(KFPlayerReplicationInfo PRI, KFWeapon W, optional byte fireMode) {
	if (W.default.FireModeClass[fireMode] != None && (class<KFFire>(W.default.FireModeClass[fireMode]) != None || class<KFShotgunFire>(W.default.FireModeClass[0]) != None || class<KFMeleeFire>(W.default.FireModeClass[fireMode]) != None))
		return string(ActualDamage(PRI, W, fireMode));
	else
		return STR_NA;
}

final static function string GetImpactDamage(KFPlayerReplicationInfo PRI, KFWeapon W) {
	if (W.default.FireModeClass[0] != None && class<KFShotgunFire>(W.default.FireModeClass[0]) != None)
		return string(ActualImpactDamage(PRI, W));
	else
		return STR_NA;
}

final static function string GetHeadshotMulti(KFPlayerReplicationInfo PRI, KFWeapon W) {
	if (W.default.FireModeClass[0] != None && (class<KFFire>(W.default.FireModeClass[0]) != None || class<KFShotgunFire>(W.default.FireModeClass[0]) != None || class<KFMeleeFire>(W.default.FireModeClass[0]) != None))
		return FloatToString(ActualHeadshotMulti(PRI, W));
	else
		return STR_NA;
}

final static function string GetHeadshotDamage(KFPlayerReplicationInfo PRI, KFWeapon W, optional byte fireMode) {
	if (W.default.FireModeClass[fireMode] != None && (class<KFFire>(W.default.FireModeClass[fireMode]) != None || class<KFShotgunFire>(W.default.FireModeClass[0]) != None || class<KFMeleeFire>(W.default.FireModeClass[fireMode]) != None))
		return string(int(ActualHeadshotMulti(PRI, W) * float(ActualDamage(PRI, W, fireMode))));
	else
		return STR_NA;
}

final static function string GetHeadshotImpactDamage(KFPlayerReplicationInfo PRI, KFWeapon W) {
	if (W.default.FireModeClass[0] != None && class<KFShotgunFire>(W.default.FireModeClass[0]) != None)
		return string(int(ActualHeadshotMulti(PRI, W) * float(ActualImpactDamage(PRI, W))));
	else
		return STR_NA;
}

/* RELOAD AND FIRE RATES */

final static function string GetMagCapacity(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int magCapacity;

	magCapacity = W.default.MagCapacity;
	if (PRI != None && PRI.ClientVeteranSkill != None)
		magCapacity *= PRI.ClientVeteranSkill.static.GetMagCapacityMod(PRI, W);
	
	return string(magCapacity);
}

final static function string GetMaxAmmo(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int maxAmmo;

	if (W.default.FireModeClass[0] == None || class<KFAmmunition>(W.default.FireModeClass[0].default.AmmoClass) == None)
		return STR_NA;
	
	maxAmmo = class<KFAmmunition>(W.default.FireModeClass[0].default.AmmoClass).default.maxAmmo;
	if (PRI != None && PRI.ClientVeteranSkill != None)
		maxAmmo *= PRI.ClientVeteranSkill.static.AddExtraAmmoFor(PRI, class<KFAmmunition>(W.default.FireModeClass[0].default.AmmoClass));

	return string(maxAmmo);
}

final static function string GetReloadRate(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local float reloadRate;

	reloadRate = W.default.reloadRate;
	if (PRI != None && PRI.ClientVeteranSkill != None)
		reloadRate /= PRI.ClientVeteranSkill.static.GetReloadSpeedModifier(PRI, W);
	
	return FloatToString(reloadRate) @ "sec";
}

final static function string GetFireRate(KFPlayerReplicationInfo PRI, KFWeapon W, optional byte fireMode) {
	local float fireRate;

	if (W.default.FireModeClass[fireMode] != None && (class<KFFire>(W.default.FireModeClass[fireMode]) != None || class<KFShotgunFire>(W.default.FireModeClass[fireMode]) != None || class<KFMeleeFire>(W.default.FireModeClass[fireMode]) != None)) {
		fireRate = W.default.FireModeClass[fireMode].default.FireRate;
		if (PRI != None && PRI.ClientVeteranSkill != None) {
			fireRate /= PRI.ClientVeteranSkill.static.GetFireSpeedMod(PRI, W);
		}

		return int(60 / fireRate) @ "RPM";
	}
	
	return STR_NA;
}

/* RECOIL */

final static function string GetRecoilSpread(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local float recoilSpread, rec;

	if (KFFire(W.GetFireMode(0)) != None) {
		recoilSpread = KFFire(W.GetFireMode(0)).GetSpread();
		if (PRI != None && PRI.ClientVeteranSkill != None) {
			recoilSpread *= PRI.ClientVeteranSkill.static.ModifyRecoilSpread(PRI, W.GetFireMode(0), rec);
		}
		
		return RadiansToDegrees(Atan(recoilSpread, 1.0));
	}
	else if (KFShotgunFire(W.GetFireMode(0)) != None) {
		recoilSpread = W.GetFireMode(0).default.spread;
		if (PRI != None && PRI.ClientVeteranSkill != None) {
			recoilSpread *= PRI.ClientVeteranSkill.static.ModifyRecoilSpread(PRI, W.GetFireMode(0), rec);
		}
		if (KSGShotgun(W) != None && KSGShotgun(W).bWideSpread) {
			recoilSpread *= 2.05;
		}
		
		return FloatToDegrees(recoilSpread);
	}
	
	return STR_NA;
}

final static function string GetVerticalRecoilAngle(KFWeapon W) {
	if (W.default.FireModeClass[0] != None) {
		if (class<KFFire>(W.default.FireModeClass[0]) != None)
			return FloatToDegrees(class<KFFire>(W.default.FireModeClass[0]).default.maxVerticalRecoilAngle);
		else if (class<KFShotgunFire>(W.default.FireModeClass[0]) != None)
			return FloatToDegrees(class<KFShotgunFire>(W.default.FireModeClass[0]).default.maxVerticalRecoilAngle);
	}

	return STR_NA;
}

final static function string GetHorizontalRecoilAngle(KFWeapon W) {
	if (W.default.FireModeClass[0] != None) {
		if (class<KFFire>(W.default.FireModeClass[0]) != None)
			return FloatToDegrees(class<KFFire>(W.default.FireModeClass[0]).default.maxHorizontalRecoilAngle);
		else if (class<KFShotgunFire>(W.default.FireModeClass[0]) != None)
			return FloatToDegrees(class<KFShotgunFire>(W.default.FireModeClass[0]).default.maxHorizontalRecoilAngle);
	}

	return STR_NA;
}

/* SHOTGUNS */

final static function string GetProjPerFire(KFWeapon W) {
	if (W.default.FireModeClass[0] != None && class<KFShotgunFire>(W.default.FireModeClass[0]) != None)
		return string(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjPerFire);
	else
		return STR_NA;
}

final static function string GetPenDamageReduction(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local float defRed, penRed;

	if (W.default.FireModeClass[0] != None && class<KFShotgunFire>(W.default.FireModeClass[0]) != None) {
		if (class<TrenchgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass) != None)
			defRed = class<TrenchgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.PenDamageReduction;
		else
			defRed = class<ShotgunBullet>(class<KFShotgunFire>(W.default.FireModeClass[0]).default.ProjectileClass).default.PenDamageReduction;
		if (PRI != None && PRI.ClientVeteranSkill != None)
			penRed = PRI.ClientVeteranSkill.static.GetShotgunPenetrationDamageMulti(PRI, defRed);
		else
			penRed = defRed;

		return string(int(100 * (1 - penRed))) $ Chr(37);
	}
	else
		return STR_NA;
}

/* MELEE */

final static function string GetWeaponRange(KFWeapon W) {
	if (W.default.FireModeClass[0] != None && class<KFMeleeFire>(W.default.FireModeClass[0]) != None)
		return FloatToMeters(class<KFMeleeFire>(W.default.FireModeClass[0]).default.weaponRange);
	else
		return STR_NA;
}

final static function string GetChopSlowRate(KFWeapon W) {
	if (KFMeleeGun(W) != None)
		return string(int(100 * (1 - KFMeleeGun(W).default.ChopSlowRate))) $ Chr(37);
	else
		return STR_NA;
}

/* MEDIGUNS */

final static function string GetHealAmount(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int healAmount;

	if (KFMedicGun(W) == None)
		return STR_NA;

	healAmount = KFMedicGun(W).default.healBoostAmount;
	if (PRI != None && PRI.ClientVeteranSkill != None)
		healAmount *= PRI.ClientVeteranSkill.static.GetHealPotency(PRI);

	return string(healAmount) @ "hp";
}

final static function string GetRegenTime(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local float regenAmount, regenSpeed, regenTime;
	
	if (KFMedicGun(W) == None)
		return STR_NA;

	regenAmount = 10.0;
	if (PRI != None && PRI.ClientVeteranSkill != None)
		regenAmount *= PRI.ClientVeteranSkill.Static.GetSyringeChargeRate(PRI);

	regenSpeed = regenAmount / KFMedicGun(W).default.ammoRegenRate;
	regenTime = float(W.default.FireModeClass[1].default.ammoPerFire) / regenSpeed;
	
	return FloatToString(regenTime) @ "sec";
}

/* HUSKGUN */

final static function string GetHuskDamage(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int damage;

	damage = ActualDamage(PRI, W);	
	return string(damage) $ "-" $ string(2 * damage);
}

final static function string GetHuskDamageRadius(KFWeapon W) {
	local int r;

	r = ActualDamageRadius(W);	
	return string(r) $ "-" $ string(3 * r);
}

private final static function int MaxHuskImpactDamage(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int damage;

	damage = ActualImpactDamage(PRI, W);	
	return 7.5 * damage;
}

final static function string GetHuskImpactDamage(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int damage;

	damage = ActualImpactDamage(PRI, W);	
	return string(damage) $ "-" $ string(int(7.5 * damage));
}

final static function string GetHuskHeadshotImpactDamage(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local float multi;
	
	multi = ActualHeadshotMulti(PRI, W);
	return string(int(multi * float(ActualImpactDamage(PRI, W)))) $ "-" $ string(int(multi * MaxHuskImpactDamage(PRI, W)));
}

/* INVENTORY */

final static function string GetWeaponCost(KFPlayerReplicationInfo PRI, KFWeapon W) {
	local int cost;

	if (class<KFWeaponPickup>(W.default.PickupClass) == None || W.bKFNeverThrow)
		return STR_NA;
	
	cost = class<KFWeaponPickup>(W.default.PickupClass).default.cost;
	if (PRI != None && PRI.ClientVeteranSkill != None)
		cost *= PRI.ClientVeteranSkill.static.GetCostScaling(PRI, class<KFWeaponPickup>(W.default.PickupClass));
	
	return Chr(163) $ string(cost);
}

final static function string GetWeight(KFWeapon W) {
	return string(int(W.default.Weight));
}

final static function string GetInventoryGroup(KFWeapon W) {
	return string(int(W.default.InventoryGroup));
}

final static function string GetPriority(KFWeapon W) {
	return string(int(W.default.Priority));
}

defaultproperties
{
}
