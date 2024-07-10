class W_FlareRevolver_NadeExplosion extends KFIncendiaryExplosion;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         BlendBetweenSubdivisions=True
         Acceleration=(Z=-100.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=50.000000)
         SpinCCWorCW=(X=0.000000)
         SpinsPerSecondRange=(X=(Max=0.500000))
         StartSizeRange=(X=(Min=30.000000,Max=35.000000),Y=(Min=30.000000,Max=35.000000),Z=(Min=30.000000,Max=35.000000))
         Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.201000,Max=0.300100)
         StartVelocityRange=(Z=(Min=50.000000,Max=500.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFTurbo.W_FlareRevolver_NadeExplosion.SpriteEmitter2'

     Emitters(2)=None

     Emitters(3)=None

     Emitters(4)=None

     LightType=LT_Flicker
     LightSaturation=50
     LightBrightness=500.000000
     LightRadius=8.000000
}