//Killing Floor Turbo ShotgunHusk Projectile
//Emitter class for the Shotgun Husk projectile
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk_Shotgun_Proj extends HuskFireProjectile;

var byte Bounces; // Amount of times the projectile can bounce
var Sound BounceSound; // Sound played when bouncing
var class<Emitter> FlameTrailEmitterClass; // Particles spawned constantly while in flight
var class<Emitter> ImpactEmitterClass; // Particles spawned when bouncing
var class<Emitter> ExplosionEmitterClass; // Particles spawned when exploding
var class<xEmitter> TrailEmitterClass; // Line trail that follows the projectile
var float ProjectileLifeSpan; // How long the projectile is allowed to exist before automatically blowing up

simulated function PostBeginPlay()
{
	SetTimer(ProjectileLifeSpan, false); // Explode this projectile after a while

	if (Level.NetMode != NM_DedicatedServer)
	{
		if (!PhysicsVolume.bWaterVolume)
		{
			FlameTrail = Spawn(FlameTrailEmitterClass, self);
			Trail = Spawn(TrailEmitterClass, self);
		}
	}

	// Difficulty Scaling
	if (Level.Game != None)
	{
		if (Level.Game.GameDifficulty < 2.0)
		{
			Damage = default.Damage * 0.75;
		}
		else if (Level.Game.GameDifficulty < 4.0)
		{
			Damage = default.Damage * 1.0;
		}
		else if (Level.Game.GameDifficulty < 5.0)
		{
			Damage = default.Damage * 1.15;
		}
		else // Hardest difficulty
		{
			Damage = default.Damage * 1.3;
		}
	}

	OrigLoc = Location;
	Dir = vector(Rotation);
	Velocity = speed * Dir;

	super(ROBallisticProjectile).PostBeginPlay();
}

function Timer()
{
	Explode(Location, vect(0, 0, 1));
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	if (Bounces > 0) // Handle bouncing
	{
		if (!Level.bDropDetail)
		{
			PlaySound(BounceSound, ESoundSlot.SLOT_Misc); // Play bounce sound
		}

		Velocity = (Velocity - 2.0 * HitNormal * (Velocity dot HitNormal)); // Reflect velocity

		Bounces--;

		if (EffectIsRelevant(Location, false))
		{
			Spawn(ImpactEmitterClass, , , Location, rotator(hitnormal)); // Spawn impact particles if relevant
		}

		return;
	}
	else
	{
		super(Projectile).HitWall(HitNormal, Wall);
	}
}

function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	// Prevent projectile from being blown up or disintegrated
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local Controller C;
	local PlayerController LocalPlayer;
	local float ShakeScale;

	if (bHasExploded)
	{
		return;
	}

	bHasExploded = True;

	PlaySound(ExplosionSound, , 2.0);

	if (EffectIsRelevant(Location, false))
	{
		Spawn(ExplosionEmitterClass, , , HitLocation + HitNormal * 20, rotator(HitNormal));
		Spawn(ExplosionDecal, self, , HitLocation, rotator(-HitNormal));
	}
	
	BlowUp(HitLocation);
	Destroy();	// Trail and FlameTrail are properly destroyed in HuskFireProjectile's Destroyed Function

	// Shake nearby players screens
	LocalPlayer = Level.GetLocalPlayerController();
	if (LocalPlayer != None)
	{
		ShakeScale = GetShakeScale(Location, LocalPlayer.ViewTarget.Location);
		if (ShakeScale > 0)
		{
			LocalPlayer.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
		}
	}

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (PlayerController(C) != None && C != LocalPlayer)
		{
			ShakeScale = GetShakeScale(Location, PlayerController(C).ViewTarget.Location);
			if (ShakeScale > 0)
			{
				C.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
			}
		}
	}
}

simulated singular function Touch(Actor Other) // Overriding Touch here, because HuskFireProjectile has incorrect early return
{
	local vector HitLocation, HitNormal;

	if (Other == None || KFBulletWhipAttachment(Other) != None || ExtendedZCollision(Other) != None)
	{
		return;
	}

	if (Other.bProjTarget || Other.bBlockActors)
	{
		LastTouched = Other;
		if (Velocity == vect(0, 0, 0) || Other.IsA('Mover'))
		{
			ProcessTouch(Other, Location);
			LastTouched = None;
			return;
		}

		if (Other.TraceThisActor(HitLocation, HitNormal, Location, Location - 2 * Velocity, GetCollisionExtent()))
		{
			HitLocation = Location;
		}

		ProcessTouch(Other, HitLocation);
		LastTouched = None;
		if ((Role < ROLE_Authority) && (Other.Role == ROLE_Authority) && (Pawn(Other) != None))
		{
			ClientSideTouch(Other, HitLocation);
		}
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation) // HuskFireProjectile calls LAWProj instead of Projectile in ProcessTouch resulting in accessing None
{
	if (KFMonster(Other) != None)
	{
		return;
	}

	super(Projectile).ProcessTouch(Other, HitLocation);
}

defaultproperties
{
	FlameTrailEmitterClass=class'KFTurbo.P_Husk_Shotgun_ProjEmitter'
	TrailEmitterClass=class'P_Husk_Shotgun_ProjTrail'
	ImpactEmitterClass=class'KFTurbo.P_Husk_Shotgun_BounceEmitter'
	ExplosionEmitterClass=class'KFTurbo.P_Husk_Shotgun_ExplosionEmitter'
	ExplosionDecal=class'KFTurbo.P_Husk_Shotgun_ExplosionDecal'
	StaticMesh=StaticMesh'EffectsSM.Weapons.Ger_Tracer_Ball'
	BounceSound=Sound'KF_FlamethrowerSnd.FireBase.Fire1Shot1' // Use hard reference for BounceSound

	Bounces=5
	Damage=6.000000
	
	MomentumTransfer=24000.000000
	ProjectileLifeSpan=60.000000
	LightHue=255
	LightSaturation=64
	LightRadius=5.000000
	
	AmbientGlow=254

	SoundVolume=120

	bNetNotify=false // Not needed due to being immune to disintegration
}