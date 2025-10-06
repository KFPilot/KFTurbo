//Killing Floor Turbo W_Chainsaw_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Chainsaw_Fire extends WeaponChainsawFire;

var int FireEffectCount;

var int HitRegisterCount;
var int LastHitRegisterCount;

function StartFiring()
{
	FireEffectCount = 10; //Update HitRegisterCount on next DoFireEffect().
	Super.StartFiring();
}

function DoFireEffect()
{
	local KFMeleeGun KFMeleeGun;
	local int Damage;
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local bool bBackStabbed;
	local KFMonster Monster;
	local TurboPlayerEventHandler.MonsterHitData HitData;

	KFMeleeGun = KFMeleeGun(Weapon);

	if (KFMeleeGun == None)
	{
		return;
	}
		
	if (++FireEffectCount >= 10)
	{
		class'WeaponHelper'.static.OnWeaponFire(self);
		FireEffectCount = 0;
		HitRegisterCount++;
	}

	Damage = MeleeDamage + Rand(MaxAdditionalDamage);

	if (KFMeleeGun.bNoHit)
	{
		return;
	}

	Damage = MeleeDamage + Rand(MaxAdditionalDamage);
	StartTrace = Instigator.Location + Instigator.EyePosition();

	if (Instigator.Controller != None && PlayerController(Instigator.Controller) == None && Instigator.Controller.Enemy != None)
	{
		PointRot = rotator(Instigator.Controller.Enemy.Location-StartTrace); // Give aimbot for bots.
	}
	else
	{
		PointRot = Instigator.GetViewRotation();
	}

	EndTrace = StartTrace + vector(PointRot)*weaponRange;
	HitActor = Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);

	if (HitActor == None)
	{
		return;
	}

	if (HitActor.IsA('ExtendedZCollision') && HitActor.Base != None && HitActor.Base.IsA('KFMonster'))
	{
		HitActor = HitActor.Base;
	}

	if ((HitActor.IsA('KFMonster') || HitActor.IsA('KFHumanPawn')) && KFMeleeGun.BloodyMaterial != None)
	{
		Weapon.Skins[KFMeleeGun.BloodSkinSwitchArray] = KFMeleeGun.BloodyMaterial;
		Weapon.texture = Weapon.default.Texture;
	}

	if (Level.NetMode == NM_Client)
	{
		return;
	}

	if (HitActor.IsA('Pawn') && !HitActor.IsA('Vehicle') && (Normal(HitActor.Location-Instigator.Location) Dot vector(HitActor.Rotation)) > 0)
	{
		bBackStabbed = true;
		Damage *= 2;
	}

	Monster = KFMonster(HitActor);

	if (Monster != None)
	{
		Monster.bBackstabbed = bBackStabbed;

		class'TurboPlayerEventHandler'.static.CollectMonsterHitData(Monster, HitLocation, vector(PointRot), HitData, 1.25f);

		HitActor.TakeDamage(Damage, Instigator, HitLocation, vector(PointRot), hitDamageClass);

		if (HitData.DamageDealt > 0 && HitRegisterCount != LastHitRegisterCount && Weapon.Instigator != None)
		{
			class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Weapon.Instigator.Controller, Self, HitData);
			LastHitRegisterCount = HitRegisterCount;
		}

		if (MeleeHitSounds.Length > 0)
		{
			Weapon.PlaySound(MeleeHitSounds[Rand(MeleeHitSounds.length)],SLOT_None,MeleeHitVolume,,,,false);
		}

		if (VSize(Instigator.Velocity) > 300 && Monster.Mass <= Instigator.Mass)
		{
			Monster.FlipOver();
		}
	}
	else
	{
		HitActor.TakeDamage(Damage, Instigator, HitLocation, vector(PointRot), hitDamageClass);

		if (KFWeaponAttachment(Weapon.ThirdPersonActor) != None)
		{
			KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(HitActor,HitLocation,HitNormal);
		}
	}
}

defaultproperties
{
	LastHitRegisterCount=-1
}
