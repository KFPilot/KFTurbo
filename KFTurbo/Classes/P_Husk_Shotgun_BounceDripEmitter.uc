class P_Husk_Shotgun_BounceDripEmitter extends Emitter;

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
        FadeOutStartTime=0.800000
        MaxParticles=20
        StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=0.100000,Max=0.200000),Z=(Min=5.000000,Max=10.000000))
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'KFX.KFSparkHead'
        LifetimeRange=(Min=0.400000,Max=0.600000)
        StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=500.000000))
    End Object
    Emitters(0)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_BounceDripEmitter.SpriteEmitter0'

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