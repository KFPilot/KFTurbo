//Killing Floor Turbo MeleeHelper
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MeleeHelper extends Object;

static final function bool PerformMeleeSwing(KFWeapon Weapon, KFMeleeFire MeleeFire, optional bool bSkipHitBroadcast)
{
	local Actor HitActor;
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local int MyDamage;
	local bool bBackStabbed;
	local Pawn Victims;
	local vector dir, lookdir;
	local float DiffAngle, VictimDist;

	local TurboPlayerEventHandler.MonsterHitData HitData;

	local bool bBroadcastedHit;

	bBroadcastedHit = false;
	MyDamage = MeleeFire.MeleeDamage;

	if (Weapon.bNoHit)
	{
		return false;
	}

	MyDamage = MeleeFire.MeleeDamage;
	StartTrace = MeleeFire.Instigator.Location + MeleeFire.Instigator.EyePosition();

	if( MeleeFire.Instigator.Controller!=None && PlayerController(MeleeFire.Instigator.Controller)==None && MeleeFire.Instigator.Controller.Enemy!=None )
	{
		PointRot = rotator(MeleeFire.Instigator.Controller.Enemy.Location-StartTrace); // Give aimbot for bots.
	}
	else
	{
		PointRot = MeleeFire.Instigator.GetViewRotation();
	}

	EndTrace = StartTrace + vector(PointRot) * MeleeFire.weaponRange;
	HitActor = MeleeFire.Instigator.Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);

	if (HitActor != None)
	{
		MeleeFire.ImpactShakeView();

		if (HitActor.IsA('ExtendedZCollision') && HitActor.Base != None && HitActor.Base.IsA('KFMonster'))
		{
			HitActor = HitActor.Base;
		}

		if ((HitActor.IsA('KFMonster') || HitActor.IsA('KFHumanPawn')) && KFMeleeGun(Weapon).BloodyMaterial != None)
		{
			Weapon.Skins[KFMeleeGun(Weapon).BloodSkinSwitchArray] = KFMeleeGun(Weapon).BloodyMaterial;
			Weapon.Texture = Weapon.default.Texture;
		}

		if (MeleeFire.Level.NetMode == NM_Client)
		{
			return false;
		}

		if (HitActor.IsA('Pawn') && !HitActor.IsA('Vehicle') && (Normal(HitActor.Location-MeleeFire.Instigator.Location) dot vector(HitActor.Rotation)) > 0)
		{
			bBackStabbed = true;
			MyDamage *= 2.f;
		}

		class'TurboPlayerEventHandler'.static.CollectMonsterHitData(HitActor, HitLocation, vector(PointRot), HitData, 1.25f);

		if (HitData.Monster != None)
		{
			HitData.Monster.bBackstabbed = bBackStabbed;
			HitData.Monster.TakeDamage(MyDamage, MeleeFire.Instigator, HitLocation, vector(PointRot), MeleeFire.hitDamageClass);

			if (!bSkipHitBroadcast && HitData.DamageDealt > 0)
			{
				class'TurboPlayerEventHandler'.static.BroadcastPlayerFireHit(Weapon.Instigator.Controller, MeleeFire, HitData);
				bBroadcastedHit = true;
			}

			if (MeleeFire.MeleeHitSounds.Length > 0)
			{
				Weapon.PlaySound(MeleeFire.MeleeHitSounds[Rand(MeleeFire.MeleeHitSounds.length)],SLOT_None,MeleeFire.MeleeHitVolume,,,,false);
			}

			if (VSize(MeleeFire.Instigator.Velocity) > 300 && HitData.Monster.Mass <= MeleeFire.Instigator.Mass)
			{
				HitData.Monster.FlipOver();
			}
		}
		else
		{
			HitActor.TakeDamage(MyDamage, MeleeFire.Instigator, HitLocation, vector(PointRot), MeleeFire.hitDamageClass);
			MeleeFire.Spawn(MeleeFire.HitEffectClass,,, HitLocation, rotator(HitLocation - StartTrace));
		}
	}

	if (MeleeFire.WideDamageMinHitAngle > 0)
	{
		foreach Weapon.VisibleCollidingActors( class 'Pawn', Victims, (MeleeFire.weaponRange * 2), StartTrace ) //, RadiusHitLocation
		{
			if ( (HitActor != none && Victims == HitActor) || Victims.Health <= 0 )
			{
				continue;
			}

			if ( Victims != MeleeFire.Instigator )
			{
				VictimDist = VSizeSquared(MeleeFire.Instigator.Location - Victims.Location);

				if( VictimDist > (((MeleeFire.weaponRange * 1.1) * (MeleeFire.weaponRange * 1.1)) + (Victims.CollisionRadius * Victims.CollisionRadius)) )
				{
					continue;
				}

				lookdir = Normal(Vector(MeleeFire.Instigator.GetViewRotation()));
				dir = Normal(Victims.Location - MeleeFire.Instigator.Location);

				DiffAngle = lookdir dot dir;

				if( DiffAngle > MeleeFire.WideDamageMinHitAngle )
				{
					Victims.TakeDamage(MyDamage * DiffAngle, MeleeFire.Instigator, (Victims.Location + Victims.CollisionHeight * vect(0,0,0.7)), vector(PointRot), MeleeFire.hitDamageClass) ;

					if(MeleeFire.MeleeHitSounds.Length > 0)
					{
						Victims.PlaySound(MeleeFire.MeleeHitSounds[Rand(MeleeFire.MeleeHitSounds.length)],SLOT_None,MeleeFire.MeleeHitVolume,,,,false);
					}
				}
			}
		}
	}

	return bBroadcastedHit;
}

defaultproperties
{
}
