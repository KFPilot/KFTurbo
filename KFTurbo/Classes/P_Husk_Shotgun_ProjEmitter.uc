//Killing Floor Turbo ShotgunHusk ProjEmitter
//Emitter class for Husk_Shotgun_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk_Shotgun_ProjEmitter extends Emitter;

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter1
		UseDirectionAs=PTDU_Up
		CoordinateSystem=PTCS_Relative
		DrawStyle=PTDS_Brighten
		Texture=Texture'KillingFloorWeapons.FlameThrower.PilotBloom'

		MaxParticles=8
		LifetimeRange=(Min=0.800000,Max=0.800000)
		StartLocationOffset=(X=7.500000)

		ColorMultiplierRange=(X=(Min=0.700000),Y=(Min=0.000000,Max=0.100000),Z=(Min=0.000000,Max=0.000000))
		FadeOut=True
		FadeOutStartTime=0.352000

		UniformSize=True
		StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
		UseSizeScale=True
		SizeScale(0)=(RelativeSize=1.500000)
		SizeScale(1)=(RelativeTime=0.400000,RelativeSize=1.000000)
		SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.800000)
		UseRegularSizeScale=False

		SpinParticles=True
		SpinsPerSecondRange=(X=(Max=0.050000),Y=(Min=0.500000,Max=1.000000),Z=(Min=0.500000,Max=1.000000))
		StartSpinRange=(X=(Min=1.000000,Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))

		StartVelocityRange=(X=(Min=25.000000,Max=25.000000))
		Acceleration=(X=400.000000)
	End Object
	Emitters(0)=SpriteEmitter'P_Husk_Shotgun_ProjEmitter.SpriteEmitter1'
	
	bDirectional=True
	AutoDestroy=True
	LightType=LT_Pulse
	LightHue=255
	LightSaturation=60
	LightBrightness=200.000000
	LightRadius=3.000000
	bNoDelete=False
	bDynamicLight=True
	bNetTemporary=True
	Physics=PHYS_Trailer
}