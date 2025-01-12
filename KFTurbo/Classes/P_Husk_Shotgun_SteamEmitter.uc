class P_Husk_Shotgun_SteamEmitter extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        FadeOut=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        BlendBetweenSubdivisions=True
        UseRandomSubdivision=True
        Acceleration=(X=300.000000,Z=200.000000)
        ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
        ColorScale(1)=(RelativeTime=0.696969,Color=(B=255,G=255,R=255,A=255))
        ColorScale(2)=(RelativeTime=1.000000)
        Opacity=0.400000
        FadeOutStartTime=0.038000
        CoordinateSystem=PTCS_Relative
        MaxParticles=15
      
        SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
        StartSpinRange=(X=(Max=1.000000),Y=(Max=1.000000),Z=(Max=1.000000))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.500000,RelativeSize=0.800000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=0.750000)
        StartSizeRange=(X=(Min=1.500000,Max=1.500000),Y=(Min=1.500000,Max=1.500000),Z=(Min=1.500000,Max=1.500000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'Effects_Tex.Smoke.LightSmoke_8Frame'
        TextureUSubdivisions=4
        TextureVSubdivisions=4
        LifetimeRange=(Min=0.100000,Max=0.100000)
        StartVelocityRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=-10.000000,Max=-10.000000),Z=(Min=45.000000,Max=75.000000))
    End Object
    Emitters(0)=SpriteEmitter'P_Husk_Shotgun_SteamEmitter.SpriteEmitter0'

    AutoDestroy=True
   
    bNoDelete=False
}