//Killing Floor Turbo W_FlameThrower_Proj_Low
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FlameThrower_Proj_Low extends W_FlameThrower_Proj;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	bDynamicLight = false;
	LightType = LT_None;
	LightBrightness = 0;
	LightRadius = 0;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	bDynamicLight = false;
	LightType = LT_None;
	LightBrightness = 0;
	LightRadius = 0;
}

simulated function PerformImpactEffect(vector HitNormal, bool bFinalImpact)
{
	if (!bFinalImpact && Level.TimeSeconds < NextExplodeEffectTime)
	{
		return;
	}

	NextExplodeEffectTime = Level.TimeSeconds + 0.25f + (FRand() * 0.25f);

	if (!EffectIsRelevant(Location,false))
	{
		return;
	}

	Spawn(class'FuelFlame',self,,Location).LightType = LT_None;
}

defaultproperties
{
	LightType=LT_None
	LightBrightness=0
	LightRadius=0
}
