//Killing Floor Turbo ShotgunHusk BounceEmitter
//Emitter class for the bounce effect of Husk_Shotgun_Proj
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk_Shotgun_BounceEmitter extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseDirectionAs=PTDU_Up
        UseCollision=True
        DrawStyle=PTDS_Brighten
        Texture=Texture'KFX.KFSparkHead'

        MaxParticles=8
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.200000,Max=0.400000)

        UseColorScale=True
        ColorScale(0)=(Color=(R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(R=128,A=255))
        FadeOut=True
        FadeOutStartTime=0.400000

        UniformSize=True
        StartSizeRange=(X=(Min=2.000000,Max=6.000000),Y=(Min=0.050000,Max=0.100000),Z=(Min=2.000000,Max=6.000000))

        StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=500.000000))
        Acceleration=(Z=-500.000000)
    End Object
    Emitters(0)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_BounceEmitter.SpriteEmitter0'

    Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseDirectionAs=PTDU_Normal
        CoordinateSystem=PTCS_Relative
        ProjectionNormal=(X=1.000000,Y=0.000000,Z=0.000000)
        DrawStyle=PTDS_Brighten
        Texture=Texture'Effects_Tex.BulletHits.waterring_2frame'
        SubdivisionStart=1
        TextureUSubdivisions=2
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True

        MaxParticles=6
        RespawnDeadParticles=False
        AutomaticInitialSpawning=False
        InitialParticlesPerSecond=5000.000000
        LifetimeRange=(Min=0.500000,Max=0.750000)

        UseColorScale=True
        ColorScale(0)=(Color=(B=0,G=0,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.660000,Color=(B=0,G=0,R=170,A=40))
        ColorScale(2)=(RelativeTime=1.000000,Color=(B=0,G=0,R=100,A=0))
        ColorMultiplierRange=(Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
        FadeOut=True
        FadeOutStartTime=0.00000

        UniformSize=True
        StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
        UseSizeScale=True
        SizeScale(0)=(RelativeTime=0.330000,RelativeSize=5.000000)
        SizeScale(1)=(RelativeTime=0.660000,RelativeSize=6.500000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=7.000000)
        UseRegularSizeScale=False
    End Object
    Emitters(1)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_BounceEmitter.SpriteEmitter1'

    AutoDestroy=True
    bNoDelete=False
    bSuperHighDetail=True
    LifeSpan=6.000000
}