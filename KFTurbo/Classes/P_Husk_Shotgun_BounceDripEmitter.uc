class P_Husk_Shotgun_BounceDripEmitter extends Emitter;

defaultproperties
{
    Begin Object Class=SparkEmitter Name=SparkEmitter0
        TimeBetweenSegmentsRange=(Min=0.200000,Max=0.200000)
        UseCollision=True
        UseColorScale=True
        FadeOut=True
        RespawnDeadParticles=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=-500.000000)
        ColorScale(0)=(Color=(R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=128,A=255))
        MaxParticles=20
      
        StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'KFX.KFSparkHead'
        LifetimeRange=(Min=0.700000,Max=1.000000)
        StartVelocityRange=(X=(Min=-75.000000,Max=75.000000),Y=(Min=-75.000000,Max=75.000000),Z=(Min=150.000000,Max=150.000000))
    End Object
    Emitters(0)=SparkEmitter'KFTurbo.P_Husk_Shotgun_BounceDripEmitter.SparkEmitter0'

    AutoDestroy=True
    bNoDelete=False
    bSuperHighDetail=True
    AmbientSound=Sound'KF_FlamethrowerSnd.FireBase.Fire1Shot1'
    LifeSpan=6.000000
    CollisionRadius=17.600000
    CollisionHeight=17.600000
    SoundVolume=153
    SoundOcclusion=OCCLUSION_None
    SoundRadius=20.000000
    TransientSoundVolume=100.000000
    TransientSoundRadius=100.000000
}