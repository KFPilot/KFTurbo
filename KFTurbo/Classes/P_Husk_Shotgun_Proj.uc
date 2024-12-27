//-------------------------------------------------------------------------------
// Shotgun Husk Projectile
//-------------------------------------------------------------------------------

class P_Husk_Shotgun_Proj extends HuskFireProjectile;

var byte Bounces;
var Sound BounceSound;
var string BounceSoundRef;
var class<Emitter> FlameTrailEmitterClass;
var class<Emitter> ImpactEmitterClass;
var class<Emitter> ExplosionEmitterClass;


simulated function PostBeginPlay()
{
    SetTimer(60.0, false);
    default.BounceSound=Sound(DynamicLoadObject(BounceSoundRef, class'Sound', true));
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (!PhysicsVolume.bWaterVolume)
		{
			FlameTrail = Spawn(FlameTrailEmitterClass,self);
			Trail = Spawn(class'P_Husk_Shotgun_DepthTrail',self);
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
    Dir = vector(Rotation);
    Velocity = speed * Dir;

    super(ROBallisticProjectile).PostBeginPlay();
}


function Timer()
{
    // Check if the projectile has already exploded
    if (!bHasExploded)
    {
        Explode(Location,vect(0, 0, 1));
    }
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	if (Bounces > 0)
    {
        if (!Level.bDropDetail)
            PlaySound(BounceSound, ESoundSlot.SLOT_Misc );

        Velocity = (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        Bounces = Bounces - 1;

    	if (EffectIsRelevant(Location,false))
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


simulated function Destroyed()
{
	if (Trail != none)
	{
		Trail.mRegen=False;
		Trail.SetPhysics(PHYS_None);
		Trail.GotoState('');
	}

	if (FlameTrail != none)
	{
        FlameTrail.Kill();
		FlameTrail.SetPhysics(PHYS_None);
	}

	Super.Destroyed();
}


function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{

}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller C;
    local PlayerController  LocalPlayer;
    local float ShakeScale;

    bHasExploded = True;

    PlaySound(ExplosionSound,,2.0);
    if (EffectIsRelevant(Location,false))
    {
        Spawn(ExplosionEmitterClass,,,HitLocation + HitNormal*20,rotator(HitNormal));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();

    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if (LocalPlayer != none)
    {
        ShakeScale = GetShakeScale(Location, LocalPlayer.ViewTarget.Location);
        if(ShakeScale > 0)
        {
            LocalPlayer.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
        }
    }

    for (C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if (PlayerController(C) != None && C != LocalPlayer)
        {
            ShakeScale = GetShakeScale(Location, PlayerController(C).ViewTarget.Location);
            if( ShakeScale > 0 )
            {
                C.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
            }
        }
    }
}

simulated singular function Touch(Actor Other)
{
    local vector    HitLocation, HitNormal;

	if (Other == None || KFBulletWhipAttachment(Other) != None)
    {
		return;
    }

	if (Other.bProjTarget || Other.bBlockActors)
	{
		LastTouched = Other;
		if (Velocity == vect(0,0,0) || Other.IsA('Mover'))
		{
			ProcessTouch(Other,Location);
			LastTouched = None;
			return;
		}

		if (Other.TraceThisActor(HitLocation, HitNormal, Location, Location - 2*Velocity, GetCollisionExtent()))
			HitLocation = Location;

		ProcessTouch(Other, HitLocation);
		LastTouched = None;
		if ((Role < ROLE_Authority) && (Other.Role == ROLE_Authority) && (Pawn(Other) != None))
			ClientSideTouch(Other, HitLocation);
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
    if (ExtendedZCollision(Other) != None || KFMonster(Other) != None)
    {
        return;
    }

    super(Projectile).ProcessTouch(Other, HitLocation);
}

defaultproperties
{
    FlameTrailEmitterClass=Class'KFTurbo.P_Husk_Shotgun_ProjEmitter'
    ImpactEmitterClass=Class'KFTurbo.P_Husk_Shotgun_BounceEmitter'
    ExplosionEmitterClass=Class'KFTurbo.P_Husk_Shotgun_ExplosionEmitter'
    ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Medium'
    StaticMesh=StaticMesh'EffectsSM.Weapons.Ger_Tracer_Ball'
    BounceSoundRef="KF_FlamethrowerSnd.FireBase.Fire1Shot1"
    Bounces=5
    Damage=10.000000
    LightHue=255
    LightSaturation=64
    AmbientGlow=254
    LightRadius=5.000000
    bNetNotify=False
}