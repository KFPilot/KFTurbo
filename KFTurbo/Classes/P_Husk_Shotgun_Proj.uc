class P_Husk_Shotgun_Proj extends HuskFireProjectile;

var byte Bounces;
var string ImpactSoundRef;
var class<Emitter> FlameTrailEmitterClass;

static function PreloadAssets()
{
	default.ImpactSound = sound(DynamicLoadObject(default.ImpactSoundRef, class'Sound', true));
    super.PreloadAssets();
}


static function bool UnloadAssets()
{
	default.ImpactSound = none;
    super.UnloadAssets();
}

simulated function PostBeginPlay()
{

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			FlameTrail = Spawn(FlameTrailEmitterClass,self);
			Trail = Spawn(class'FlameThrowerFlame',self);
		}
	}

	// Difficulty Scaling
	if (Level.Game != none)
	{
        if( Level.Game.GameDifficulty < 2.0 )
        {
            Damage = default.Damage * 0.75;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            Damage = default.Damage * 1.0;
        }
        else if( Level.Game.GameDifficulty < 5.0 )
        {
            Damage = default.Damage * 1.15;
        }
        else // Hardest difficulty
        {
            Damage = default.Damage * 1.3;
        }
	}

    OrigLoc = Location;

    if( !bDud )
    {
        Dir = vector(Rotation);
        Velocity = speed * Dir;
    }

    super(ROBallisticProjectile).PostBeginPlay();
}


simulated function HitWall( vector HitNormal, actor Wall )
{
    if ( !Wall.bStatic && !Wall.bWorldGeometry
		&& ((Mover(Wall) == None) || Mover(Wall).bDamageTriggered) )
    {
        if ( Level.NetMode != NM_Client )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
            Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
		}
        Destroy();
        return;
    }

    SetRotation(rotator(Normal(Velocity)));
    
	if (Bounces > 0)
    {
		if ( !Level.bDropDetail && (FRand() < 0.4) )
			Playsound(ImpactSound, SLOT_Misc );

        Velocity = 0.65 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        Bounces = Bounces - 1;

    	if ( !Level.bDropDetail && (Level.NetMode != NM_DedicatedServer))
    	{
            Spawn(class'ROEffects.ROBulletHitMetalEffect',,,Location, rotator(hitnormal));
    	}

        return;
    }
    else
    {
		super(Projectile).HitWall(HitNormal,Wall);
    }
	bBounce = false;
}

defaultproperties
{
    FlameTrailEmitterClass=Class'KFTurbo.P_Husk_Shotgun_ProjEmitter'
    ImpactSoundRef="ProjectileSounds.Bullets.Impact_Metal"
    StaticMesh=StaticMesh'EffectsSM.Weapons.Ger_Tracer_Ball'
    Bounces=1
    bBounce=true
    Damage=5.000000
    LightHue=255
    LightSaturation=64
    AmbientGlow=254
}