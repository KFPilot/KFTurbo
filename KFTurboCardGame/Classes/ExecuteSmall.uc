//Killing Floor Turbo ExecuteSmall
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class ExecuteSmall extends Emitter;

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();
}

defaultproperties
{
    Begin Object Name=ExecuteSmallEmitter Class=SpriteEmitter
        UseDirectionAs=PTDU_Normal
        ProjectionNormal=(X=1.000000,Z=0.000000)
        UseColorScale=True
        RespawnDeadParticles=False
        AutoDestroy=True
        ZTest=False
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=20,G=20,R=255))
        ColorScale(1)=(RelativeTime=0.050000,Color=(B=20,G=20,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.090000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(3)=(RelativeTime=0.130000,Color=(B=20,G=20,R=255,A=255))
        ColorScale(4)=(RelativeTime=0.170000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(5)=(RelativeTime=0.210000,Color=(B=20,G=20,R=255,A=255))
        ColorScale(6)=(RelativeTime=0.250000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(7)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(8)=(RelativeTime=0.750000,Color=(B=255,G=255,R=255))
        ColorScale(9)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
        FadeOutFactor=(W=6.000000)
        FadeInFactor=(W=5.000000)
        CoordinateSystem=PTCS_Relative
        MaxParticles=1
        EffectAxis=PTEA_PositiveZ
        StartLocationRange=(Y=(Min=48.000000,Max=48.000000))
        UseRotationFrom=PTRS_Offset
        StartSizeRange=(X=(Min=32.000000,Max=32.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMax=0.000000
        InitialParticlesPerSecond=5000.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'KFTurboCardGame.Effects.Executed_D'
        StartVelocityRange=(Y=(Min=150.000000,Max=150.000000))
        VelocityLossRange=(X=(Min=8.000000,Max=8.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=8.000000,Max=8.000000))
        GetVelocityDirectionFrom=PTVD_StartPositionAndOwner
    End Object
    Emitters(0)=SpriteEmitter'ExecuteSmallEmitter'

    AutoDestroy=true
    bNoDelete=false
    RemoteRole=ROLE_None
    bNotOnDedServer=true
    bDirectional=true
}
