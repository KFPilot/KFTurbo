//Killing Floor Turbo ShotgunHusk ProjTrail
//Emitter class for the trail of Husk_Shotgun_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk_Shotgun_ProjTrail extends FlameThrowerFlame;

defaultproperties
{
	mLifeRange(0)=1.000000
	mLifeRange(1)=1.000000

	mSizeRange(0)=8.000000
	mSizeRange(1)=8.000000

	mMassRange(0)=0.000000
	mMassRange(1)=0.000000
	mPosDev=(X=1,Y=1,Z=1)      

	mColorRange(0)=(R=255,G=0,B=0,A=255) 
	mColorRange(1)=(R=200,G=50,B=50,A=255) 

	mGrowthRate=-48.000000

	Skins(0)=Texture'KFX.KFFlames'

	Style=STY_Additive

	AmbientSound=None
	SoundVolume=0
	TransientSoundVolume=0.0
	TransientSoundRadius=0.0

	mRandTextures=True
	Physics=PHYS_Trailer
	bNotOnDedServer=False
	LifeSpan=15.000000
}
