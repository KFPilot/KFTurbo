class P_Husk_Shotgun_BounceEmitter extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        UseSubdivisionScale=True
        Acceleration=(Z=50.000000)
        ColorScale(0)=(Color=(R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=255,A=255))
        FadeOutStartTime=0.102500
        FadeInEndTime=0.050000
        MaxParticles=2
        SizeScale(1)=(RelativeTime=0.140000,RelativeSize=0.500000)
        SizeScale(2)=(RelativeTime=0.500000,RelativeSize=1.500000)
        StartSizeRange=(X=(Min=60.000000,Max=60.000000),Y=(Min=60.000000,Max=60.000000),Z=(Min=60.000000,Max=60.000000))
        InitialParticlesPerSecond=30.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'Effects_Tex.explosions.impact_2frame'
        TextureUSubdivisions=2
        TextureVSubdivisions=1
        LifetimeRange=(Min=0.200000,Max=0.200000)
        StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
    End Object
    Emitters(0)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_BounceEmitter.SpriteEmitter0'

    
    AutoDestroy=True
    LightType=LT_Pulse
    LightHue=255
    LightSaturation=64
    LightBrightness=255.000000
    LightRadius=1.000000
    bNoDelete=False
    bDynamicLight=True
    AmbientSound=Sound'KF_FlamethrowerSnd.FireBase.Fire1Shot1'
    LifeSpan=6.000000
    SoundVolume=255
    SoundRadius=100.000000
}
