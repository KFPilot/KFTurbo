//Killing Floor Turbo V_Firebug_Grenade
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class V_Firebug_Grenade extends KFMod.FlameNade;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    class'WeaponHelper'.static.GrenadeTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;
	local PlayerController PC;

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		Explode(Location, HitNormal);
		return;
	}

    if (!bTimerSet)
    {
        SetTimer(ExplodeTimer, false);
        bTimerSet = true;
    }

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(100000);
    Speed = VSize(Velocity);

    if ( Speed < 10 )
    {
        bBounce = False;

		class'WeaponHelper'.static.BeginGrenadeSmoothRotation(self, 6);

		if( Fear == none )
		{
		    Fear = Spawn(class'AvoidMarker');
    		Fear.SetCollisionSize(DamageRadius,DamageRadius);
    		Fear.StartleBots();
		}

        if ( Trail != None )
            Trail.mRegen = false; // stop the emitter from regenerating
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 50) )
		{
			PlaySound(ImpactSound, SLOT_Misc );
		}

        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
        {
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}

defaultproperties
{	
	LightType=LT_Pulse
    LightBrightness=64
	LightPeriod=16
    LightRadius=0.500000
    LightHue=15
    LightSaturation=50
    bDynamicLight=True

    StaticMesh=StaticMesh'KFTurbo.FP7.FP7Proj'
	Skins(0)=Shader'KFTurbo.FP7.FP7_SHDR'
    DrawScale=0.35
	
	Physics=PHYS_Falling
	bUseCollisionStaticMesh = false
	bUseCylinderCollision = false
	bFixedRotationDir = true

	CollisionRadius=0
    CollisionHeight=0
    RotationRate=(Roll=0)
}
