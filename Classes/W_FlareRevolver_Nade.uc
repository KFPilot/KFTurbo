class W_FlareRevolver_Nade extends M79GrenadeProjectile;


var     Emitter     FlameTrail;
var     class<Emitter> FlameTrailEmitterClass;

var		string	AmbientSoundRef;

static function PreloadAssets()
{
	default.ExplosionSound = sound(DynamicLoadObject(default.ExplosionSoundRef, class'Sound', true));
	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));
	default.DisintegrateSound = sound(DynamicLoadObject(default.DisintegrateSoundRef, class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplosionSound = none;
	default.AmbientSound = none;
	default.DisintegrateSound = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function StartDudExplosionTimer()
{
    log("timer set");
    SetTimer(2,false);
}


simulated function PostBeginPlay()
{
    if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			FlameTrail = Spawn(FlameTrailEmitterClass,self);
		}
	}
        OrigLoc = Location;

    if( !bDud )
    {
        Dir = vector(Rotation);
        Velocity = speed * Dir;
    }
    
    super(Projectile).PostBeginPlay();
}


simulated function HitWall(vector HitNormal, actor Wall)
{
    if (Instigator != none)
    {
        OrigLoc = Instigator.Location;
    }

    if( !bDud && ((VSizeSquared(Location - OrigLoc) < ArmDistSquared) || OrigLoc == vect(0,0,0)) )
    {
        bDud = true;
        StartDudExplosionTimer();
        Velocity = vect(0,0,0);
        SetPhysics(PHYS_Falling);
    }

    if (!bDud)
    {
        super(Projectile).HitWall(HitNormal, Wall);
    }
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    // Don't let it hit this player, or blow up on another player
	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

    // Don't collide with bullet whip attachments
    if( KFBulletWhipAttachment(Other) != none )
    {
        return;
    }

    // Don't allow hits on poeple on the same team
    if( KFHumanPawn(Other) != none && Instigator != none
        && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }

	// Use the instigator's location if it exists. This fixes issues with
	// the original location of the projectile being really far away from
	// the real Origloc due to it taking a couple of milliseconds to
	// replicate the location to the client and the first replicated location has
	// already moved quite a bit.
	if( Instigator != none )
	{
		OrigLoc = Instigator.Location;
	}

	if( !bDud && ((VSizeSquared(Location - OrigLoc) < ArmDistSquared) || OrigLoc == vect(0,0,0)) )
	{
		if( Role == ROLE_Authority )
		{
			AmbientSound=none;
			PlaySound(Sound'ProjectileSounds.PTRD_deflect04',,2.0);
			Other.TakeDamage( ImpactDamage, Instigator, HitLocation, Normal(Velocity), ImpactDamageType );
		}

		bDud = true;
		StartDudExplosionTimer();
		Velocity = vect(0,0,0);
		SetPhysics(PHYS_Falling);
	}

	if( !bDud )
	{
	   Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

function Timer()
{
    log("timer ended");
    if(bDisintegrated || bHasExploded)
    {
        Destroy();
    }
    else
    {
	    Explode(Location,vect(0,0,1));
    }
}

simulated function Tick( float DeltaTime )
{
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller C;
	local PlayerController  LocalPlayer;

    log("has exploded");
    if(bHasExploded)
    {
        return;
    }

	bHasExploded = True;

	BlowUp(HitLocation);
	Destroy();

    PlaySound(sound'KF_GrenadeSnd.FlameNade_Explode',,100.5*TransientSoundVolume);

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFTurbo.FlareGrenadeExplosion',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}

    LocalPlayer = Level.GetLocalPlayerController();
	if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < DamageRadius) )
		LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( (PlayerController(C) != None) && (C != LocalPlayer)
			&& (VSize(Location - PlayerController(C).ViewTarget.Location) < DamageRadius) )
			C.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
}

simulated function Landed( vector HitNormal )
{
	SetPhysics(PHYS_None);

	if( !bDud )
	{
	   Explode(Location,HitNormal);
	}
	else
	{

	}
}

simulated function Destroyed()
{
    log("destroyed");
	if ( FlameTrail != none )
	{
        FlameTrail.Kill();
        FlameTrail.SetPhysics(PHYS_None);
	}
    Super.Destroyed();
}


defaultproperties
{
     RotMag=(X=350.000000,Y=350.000000,Z=350.000000)
     RotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)
     RotTime=3.000000
     OffsetMag=(X=3.000000,Y=5.000000,Z=3.000000)
     OffsetRate=(X=150.000000,Y=150.000000,Z=150.000000)
     OffsetTime=2.000000
     Damage=40.000000
     DamageRadius=210.000000
     FlameTrailEmitterClass=Class'KFMod.FlareRevolverTrail'
     MyDamageType=Class'KFMod.DamTypeFlameNade'
     ArmDistSquared=25000000.000000 // 2 seconds of flight time
     ImpactDamageType=Class'KFMod.DamTypeM79GrenadeImpact'
     ImpactDamage=2
     StaticMeshRef="EffectsSM.Ger_Tracer"
     ExplosionSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Hit"
     AmbientSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Loop"
     AmbientVolumeScale=1.500000
     Speed=2500.000000
     MaxSpeed=2500.000000
     LightType=LT_Steady
     LightHue=255
     LightSaturation=64
     LightBrightness=255.000000
     LightRadius=6.000000
     LightCone=16
     bDynamicLight=True
     DrawScale=1.000000
     AmbientGlow=180
     bUnlit=True
}