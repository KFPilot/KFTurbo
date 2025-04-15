//Killing Floor Turbo CriticalHitEffect
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CriticalHitEffect extends Emitter;

#exec OBJ LOAD FILE=Steamland_SND.uax

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        PlayOwnedSound(Sound'Steamland_SND.SlotMachine_ReelStop', SLOT_None, 4.f,, 5000.f);
    }
}

defaultproperties                                                                                                                             
{
    Begin Object Class=SpriteEmitter Name=CriticalHitSpriteEmitter
        UseDirectionAs=PTDU_Scale
        UseColorScale=True
        RespawnDeadParticles=false
        ZTest=False
        UseRegularSizeScale=false
        Acceleration=(Z=5.000000)
        MaxCollisions=(Min=3.000000,Max=6.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255))
        ColorScale(1)=(RelativeTime=0.050000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=0.125000,Color=(B=255,G=255,R=255,A=200))
        ColorScale(3)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(4)=(RelativeTime=0.125000,Color=(B=255,G=255,R=255,A=200))
        ColorScale(5)=(RelativeTime=0.150000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(6)=(RelativeTime=0.175000,Color=(B=255,G=255,R=255,A=200))
        ColorScale(7)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(8)=(RelativeTime=0.225000,Color=(B=255,G=255,R=255,A=200))
        ColorScale(9)=(RelativeTime=0.250000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(10)=(RelativeTime=0.500000,Color=(B=255,G=255,R=255,A=255))
        ColorScale(11)=(RelativeTime=0.550000,Color=(B=255,G=255,R=255))
        ColorScale(12)=(RelativeTime=1.000000)
        FadeOutFactor=(W=6.000000)
        FadeInFactor=(W=5.000000)
        MaxParticles=1
        AutomaticInitialSpawning=false
        InitialParticlesPerSecond=5000
        EffectAxis=PTEA_PositiveZ
        UseRotationFrom=PTRS_Offset
        StartSizeRange=(X=(Min=16.000000,Max=16.000000),Y=(Min=-8.000000,Max=-8.000000),Z=(Min=0.000000,Max=0.000000))
        ScaleSizeByVelocityMax=0.000000
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'KFTurboCardGame.Effects.CriticalHit_D'
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=75.000000,Max=75.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=4.000000,Max=4.000000))
        AutoDestroy=true
    End Object
    Emitters(0)=SpriteEmitter'CriticalHitSpriteEmitter'

    AutoDestroy=true
    bNoDelete=false
    RemoteRole=ROLE_None
    bNotOnDedServer=true
}