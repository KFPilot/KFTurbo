//Killing Floor Turbo ShotgunHusk SteamPuffEmitter
//Emitter class for the steam puff on Husk_Shotgun
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk_Shotgun_SteamPuffEmitter extends Emitter;

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter0
		UseCollision=True
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'Effects_Tex.Smoke.LightSmoke_8Frame'
		TextureUSubdivisions=4
		TextureVSubdivisions=4
		BlendBetweenSubdivisions=True
		UseRandomSubdivision=True

		MaxParticles=14
		LifetimeRange=(Min=0.500000,Max=1.500000)

		Opacity=0.100000
		FadeOut=True
		FadeOutStartTime=0.400000
		FadeIn=True
		FadeInEndTime=0.100000

		UniformSize=True
		StartSizeRange=(X=(Min=10.000000,Max=23.000000),Y=(Min=10.000000,Max=23.000000),Z=(Min=10.000000,Max=23.000000))

		SpinParticles=True
		SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000),Y=(Min=0.100000,Max=0.300000),Z=(Min=0.100000,Max=0.300000))

		StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))

	End Object
	Emitters(0)=SpriteEmitter'P_Husk_Shotgun_SteamPuffEmitter.SpriteEmitter0'

	AutoDestroy=True
	bNoDelete=False
}