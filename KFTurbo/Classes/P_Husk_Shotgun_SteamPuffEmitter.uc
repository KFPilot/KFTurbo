class P_Husk_Shotgun_SteamPuffEmitter extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseCollision=True
        FadeOut=True
        FadeIn=True
        SpinParticles=True
        UniformSize=True
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
        FadeOutStartTime=0.400000
        FadeInEndTime=0.100000
        MaxParticles=14
        Opacity=0.100000
      
        SpinsPerSecondRange=(X=(Min=0.100000,Max=0.300000),Y=(Min=0.100000,Max=0.300000),Z=(Min=0.100000,Max=0.300000))
        StartSizeRange=(X=(Min=10.000000,Max=23.000000),Y=(Min=10.000000,Max=23.000000),Z=(Min=10.000000,Max=23.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.Smoke.LightSmoke_8Frame'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.500000,Max=1.500000)
        StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000))
    End Object
    Emitters(0)=SpriteEmitter'P_Husk_Shotgun_SteamPuffEmitter.SpriteEmitter0'

    AutoDestroy=True
   
    bNoDelete=False
}