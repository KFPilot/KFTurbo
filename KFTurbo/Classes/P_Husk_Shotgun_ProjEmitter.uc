class P_Husk_Shotgun_ProjEmitter extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         UseRandomSubdivision=False
         ColorScale(1)=(RelativeTime=0.000000,Color=(B=30,G=30,R=255))  
         ColorScale(2)=(RelativeTime=0.500000,Color=(B=15,G=15,R=200)) 
         ColorScale(3)=(RelativeTime=1.000000,Color=(B=5,G=5,R=100))   
         ColorMultiplierRange=(Z=(Min=0.670000,Max=2.000000))
         FadeOutStartTime=0.200000
         MaxParticles=20
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=1.000000)
         SpinsPerSecondRange=(X=(Max=0.070000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.650000)
         StartSizeRange=(X=(Min=8.000000,Max=15.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         Texture=Texture'Effects_Tex.Smoke.MuzzleCorona1stP'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=0.300000,Max=0.600000)
         StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=10.000000,Max=20.000000))
         MaxAbsVelocity=(X=50.000000,Y=50.000000,Z=50.000000)
     End Object
     Emitters(0)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_ProjEmitter.SpriteEmitter0'

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