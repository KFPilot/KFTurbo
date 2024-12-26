class P_Husk_Shotgun_Proj extends HuskFireProjectile;

var byte Bounces;
var Sound BounceSound;
var string BounceSoundRef;
var class<Emitter> FlameTrailEmitterClass;
var class<Emitter> ImpactEmitterClass;
var class<Emitter> ExplosionEmitterClass;

simulated function PostBeginPlay()
{
    default.BounceSound=Sound(DynamicLoadObject(BounceSoundRef, class'Sound', true));
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

    	if ( EffectIsRelevant(Location,false))
    	{
            Spawn(ImpactEmitterClass,,,Location, rotator(hitnormal));
    	}

        return;
    }
    else
    {
		super(Projectile).HitWall(HitNormal,Wall);
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller C;
    local PlayerController  LocalPlayer;
    local float ShakeScale;

    bHasExploded = True;

    // Don't explode if this is a dud
    if( bDud )
    {
        Velocity = vect(0,0,0);
        LifeSpan=1.0;
        SetPhysics(PHYS_Falling);
    }

    PlaySound(ExplosionSound,,2.0);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionEmitterClass,,,HitLocation + HitNormal*20,rotator(HitNormal));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();

    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if ( LocalPlayer != none )
    {
        ShakeScale = GetShakeScale(Location, LocalPlayer.ViewTarget.Location);
        if( ShakeScale > 0 )
        {
            LocalPlayer.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
        }
    }

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if ( PlayerController(C) != None && C != LocalPlayer )
        {
            ShakeScale = GetShakeScale(Location, PlayerController(C).ViewTarget.Location);
            if( ShakeScale > 0 )
            {
                C.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
            }
        }
    }
}

defaultproperties
{
    FlameTrailEmitterClass=Class'KFTurbo.P_Husk_Shotgun_ProjEmitter'
    ImpactEmitterClass=Class'KFTurbo.P_Husk_Shotgun_BounceEmitter'
    ExplosionEmitterClass=Class'KFTurbo.P_Husk_Shotgun_ExplosionEmitter'
    ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Medium'
    StaticMesh=StaticMesh'EffectsSM.Weapons.Ger_Tracer_Ball'
    BounceSoundRef="KF_FlamethrowerSnd.FireBase.Fire1Shot1"
    Bounces=1
    Damage=5.000000
    LightHue=255
    LightSaturation=64
    AmbientGlow=254
}