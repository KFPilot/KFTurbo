class P_Husk_Shotgun_Proj extends HuskFireProjectile;

var byte Bounces;
var string BounceSoundRef;
var Sound BounceSound;
var class<Emitter> FlameTrailEmitterClass;
var class<Emitter> ImpactEmitterClass;
var class<Emitter> ImpactDripEmitterClass;

static function PreloadAssets()
{
    Super.PreloadAssets();
	default.BounceSound = Sound(DynamicLoadObject(default.BounceSoundRef, class'Sound', true));
}


static function bool UnloadAssets()
{
    Super.UnloadAssets();
	default.BounceSound = none;
	return true;
}

simulated function PostBeginPlay()
{
    log("PostBeginPlay: BounceSound is " @ BounceSound); //None
    log("PostBeginPlay: BounceSoundRef is " @ BounceSoundRef);
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
    SetRotation(rotator(Normal(Velocity)));
    
	if (Bounces > 0)
    {
        if (!Level.bDropDetail)
            PlaySound(BounceSound, ESoundSlot.SLOT_Misc );

        Velocity = 0.65 * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        Bounces = Bounces - 1;

    	if ( !Level.bDropDetail && (Level.NetMode != NM_DedicatedServer))
    	{
            Spawn(ImpactDripEmitterClass,,,Location, rotator(hitnormal)); //doesn't spawn
            Spawn(ImpactEmitterClass,,,Location);
    	}

        return;
    }
    else
    {
		super(Projectile).HitWall(HitNormal,Wall);
    }
}

defaultproperties
{
    FlameTrailEmitterClass=Class'KFTurbo.P_Husk_Shotgun_ProjEmitter'
    ImpactEmitterClass=Class'KFTurbo.P_Husk_Shotgun_BounceEmitter'
    ImpactDripEmitterClass=Class'KFTurbo.P_Husk_Shotgun_BounceDripEmitter'
    BounceSoundRef="KF_FlamethrowerSnd.FireBase.Fire1Shot1" 
    StaticMesh=StaticMesh'EffectsSM.Weapons.Ger_Tracer_Ball'
    Bounces=1
    Damage=5.000000
    LightHue=255
    LightSaturation=64
    AmbientGlow=254
}