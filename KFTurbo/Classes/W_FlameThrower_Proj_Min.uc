//Killing Floor Turbo W_FlameThrower_Proj_Min
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FlameThrower_Proj_Min extends W_FlameThrower_Proj;

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

}

defaultproperties
{
	LightType=LT_None
	LightBrightness=0
	LightRadius=0
}
