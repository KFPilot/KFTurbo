class P_Husk_Shotgun_BounceEmitter extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseDirectionAs=PTDU_Up
        UseCollision=True
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-500.000000)
        ColorScale(0)=(Color=(R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=128,A=255))
        FadeOutStartTime=0.400000
        MaxParticles=8
        StartSizeRange=(X=(Min=2.000000,Max=6.000000),Y=(Min=0.050000,Max=0.100000),Z=(Min=2.000000,Max=6.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'KFX.KFSparkHead'
        LifetimeRange=(Min=0.200000,Max=0.400000)
        StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=500.000000))
    End Object
    Emitters(0)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_BounceEmitter.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Y=0.000000,Z=0.000000)
        FadeOut=True
        RespawnDeadParticles=False
        UseSizeScale=True
        UseColorScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        BlendBetweenSubdivisions=True
        ColorScale(0)=(Color=(B=0,G=0,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.660000,Color=(B=0,G=0,R=170,A=40))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=0,G=0,R=100,A=0))
        ColorMultiplierRange=(Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        FadeOutStartTime=0.00000
        CoordinateSystem=PTCS_Relative
        MaxParticles=6
      
        SizeScale(0)=(RelativeTime=0.330000,RelativeSize=5.000000)
        SizeScale(1)=(RelativeTime=0.660000,RelativeSize=6.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=7.000000)
        StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'Effects_Tex.BulletHits.waterring_2frame'
        TextureUSubdivisions=2
        TextureVSubdivisions=1
        SubdivisionStart=1
        LifetimeRange=(Min=0.500000,Max=0.750000)
    End Object
    Emitters(1)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_BounceEmitter.SpriteEmitter1'

    AutoDestroy=True
    bNoDelete=False
    bSuperHighDetail=True
    LifeSpan=6.000000
}