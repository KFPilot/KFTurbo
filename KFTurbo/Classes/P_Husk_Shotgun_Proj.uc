class P_Husk_Shotgun_Proj extends HuskFireProjectile;

var byte Bounces;
var string ImpactSoundRef;

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

    SetPhysics(PHYS_Falling);
	if (Bounces > 0)
    {
		if ( !Level.bDropDetail && (FRand() < 0.4) )
			Playsound(ImpactSound);

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
    ImpactSoundRef="ProjectileSounds.Bullets.Impact_Metal"
    Bounces=1
    bBounce=true
    Damage=5.000000
}