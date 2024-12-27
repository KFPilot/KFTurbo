class P_Husk_Shotgun_SmokeEmitter extends Emitter;

defaultproperties
{
Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        FadeOut=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        Acceleration=(X=8.000000,Z=12.000000)
        ColorScale(0)=(Color=(B=100,G=100,R=100,A=200))
        ColorScale(1)=(RelativeTime=0.200000,Color=(B=40,G=40,R=40,A=200))
        ColorScale(2)=(RelativeTime=1.000000,Color=(A=255))
        ColorMultiplierRange=(X=(Min=0.000000,Max=0.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
        FadeOutStartTime=1.000000
        MaxParticles=15
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.560000,RelativeSize=0.800000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.100000)
        StartSizeRange=(X=(Min=12.000000,Max=12.000000),Y=(Min=12.000000,Max=12.000000),Z=(Min=12.000000,Max=12.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.Smoke.LightSmoke_8Frame'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Min=20.000000,Max=28.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=20.000000,Max=60.000000))
    End Object
    Emitters(0)=SpriteEmitter'P_Husk_Shotgun_SmokeEmitter.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        Acceleration=(X=4.000000,Z=8.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        ColorMultiplierRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
        Opacity=0.350000
        FadeOutStartTime=1.500000
        FadeInEndTime=1.500000
        MaxParticles=5
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        StartSizeRange=(X=(Min=16.000000,Max=16.000000),Y=(Min=16.000000,Max=16.000000),Z=(Min=16.000000,Max=16.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.Smoke.grenadesmoke_fill'
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=12.000000,Max=12.000000),Z=(Min=16.000000,Max=16.000000))
    End Object
    Emitters(1)=SpriteEmitter'P_Husk_Shotgun_SmokeEmitter.SpriteEmitter1'

    AutoDestroy=True
   
    bNoDelete=False
}