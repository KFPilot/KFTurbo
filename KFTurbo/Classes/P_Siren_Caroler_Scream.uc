//Killing Floor Turbo P_Siren_Caroler_Scream
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Siren_Caroler_Scream extends SirenScream;

defaultproperties
{
    Begin Object Class=MeshEmitter Name=MeshEmitter1
        StaticMesh=StaticMesh'KFTurbo.siren.caroler_scream_ball'
        UseParticleColor=True
        FadeOut=True
        FadeIn=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        AutomaticInitialSpawning=False
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.500000
        FadeInEndTime=0.200000
        MaxParticles=5
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=10.000000)
        InitialParticlesPerSecond=3.000000
        DrawStyle=PTDS_Regular
        LifetimeRange=(Min=2.000000,Max=2.000000)
    End Object
    Emitters(0)=MeshEmitter'KFTurbo.P_Siren_Caroler_Scream.MeshEmitter1'
}
