class P_Husk_Shotgun_ExplosionEmitter extends FlameImpact;

defaultproperties
    {
        Begin Object Class=SpriteEmitter Name=SpriteEmitter0
            UseColorScale=True
            RespawnDeadParticles=False
            SpinParticles=True
            UseSizeScale=True
            UseRegularSizeScale=False
            UniformSize=True
            AutomaticInitialSpawning=False
            Acceleration=(Z=15.000000)
            ColorScale(0)=(Color=(B=51,G=152,R=200))
            ColorScale(1)=(RelativeTime=0.300000,Color=(B=48,G=91,R=222))
            ColorScale(2)=(RelativeTime=1.000000,Color=(B=40,G=40,R=40,A=100))
            MaxParticles=6
        
            StartLocationShape=PTLS_Sphere
            SphereRadiusRange=(Min=24.000000,Max=24.000000)
            MeshScaleRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
            SpinsPerSecondRange=(X=(Max=0.100000))
            StartSpinRange=(X=(Max=1.000000))
            SizeScale(0)=(RelativeSize=1.000000)
            SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
            StartSizeRange=(X=(Min=8.000000,Max=16.000000),Y=(Min=8.000000,Max=8.000000),Z=(Min=8.000000,Max=8.000000))
            InitialParticlesPerSecond=1000.000000
            DrawStyle=PTDS_Brighten
            Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
            TextureUSubdivisions=8
            TextureVSubdivisions=8
            SecondsBeforeInactive=0.000000
            LifetimeRange=(Min=1.000000,Max=1.000000)
            StartVelocityRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=15.000000,Max=30.000000))
        End Object
        Emitters(0)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_ExplosionEmitter.SpriteEmitter0'

        Begin Object Class=SpriteEmitter Name=SpriteEmitter1
            UseColorScale=True
            RespawnDeadParticles=False
            SpinParticles=True
            UseSizeScale=True
            UseRegularSizeScale=False
            UniformSize=True
            AutomaticInitialSpawning=False
            Acceleration=(Z=150.000000)
            ColorScale(0)=(Color=(G=255,R=255,A=128))
            ColorScale(1)=(RelativeTime=0.300000,Color=(B=47,G=80,R=179,A=255))
            ColorScale(2)=(RelativeTime=0.600000,Color=(B=40,G=40,R=40,A=255))
            ColorScale(3)=(RelativeTime=1.000000,Color=(B=40,G=40,R=40,A=100))
            MaxParticles=6
        
            StartLocationShape=PTLS_Sphere
            SphereRadiusRange=(Min=10.000000,Max=10.000000)
            SpinsPerSecondRange=(X=(Max=0.100000))
            StartSpinRange=(X=(Max=1.000000))
            SizeScale(0)=(RelativeSize=1.000000)
            SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
            StartSizeRange=(X=(Min=8.000000,Max=16.000000),Y=(Min=8.000000,Max=16.000000))
            InitialParticlesPerSecond=800.000000
            DrawStyle=PTDS_Brighten
            Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
            TextureUSubdivisions=8
            TextureVSubdivisions=8
            LifetimeRange=(Min=1.000000,Max=1.000000)
            StartVelocityRange=(X=(Min=-60.000000,Max=60.000000),Y=(Min=-60.000000,Max=60.000000))
        End Object
        Emitters(1)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_ExplosionEmitter.SpriteEmitter1'

        Begin Object Class=SpriteEmitter Name=SpriteEmitter2
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
            ColorMultiplierRange=(Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
            FadeOutStartTime=0.102500
            FadeInEndTime=0.050000
            MaxParticles=2
        
            SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
            SizeScale(2)=(RelativeTime=1.000000,RelativeSize=3.500000)
            StartSizeRange=(X=(Min=24.000000,Max=24.000000),Y=(Min=24.000000,Max=24.000000),Z=(Min=24.000000,Max=24.000000))
            InitialParticlesPerSecond=30.000000
            DrawStyle=PTDS_Brighten
            Texture=Texture'Effects_Tex.explosions.impact_2frame'
            TextureUSubdivisions=2
            TextureVSubdivisions=1
            LifetimeRange=(Min=0.200000,Max=0.200000)
            StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
        End Object
        Emitters(2)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_ExplosionEmitter.SpriteEmitter2'

        Begin Object Class=SpriteEmitter Name=SpriteEmitter3
            FadeOut=True
            FadeIn=True
            SpinParticles=True
            UseSizeScale=True
            UseRegularSizeScale=False
            UniformSize=True
            UseRandomSubdivision=True
            Acceleration=(Z=50.000000)
            ColorMultiplierRange=(Y=(Min=0.300000,Max=0.300000),Z=(Min=0.300000,Max=0.300000))
            FadeOutStartTime=0.520000
            FadeInEndTime=0.140000
            MaxParticles=8 
        
            StartLocationShape=PTLS_Sphere
            SpinsPerSecondRange=(X=(Max=0.075000))
            StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
            SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
            StartSizeRange=(X=(Min=28.000000,Max=40.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
            ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
            ScaleSizeByVelocityMax=0.000000
            Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
            TextureUSubdivisions=4
            TextureVSubdivisions=4
            SecondsBeforeInactive=30.000000
            LifetimeRange=(Min=1.000000,Max=1.000000)
            StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=25.000000,Max=45.000000))
        End Object
        Emitters(3)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_ExplosionEmitter.SpriteEmitter3'

        Begin Object Class=SpriteEmitter Name=SpriteEmitter4
            UseCollision=True
            UseColorScale=True
            FadeOut=True
            RespawnDeadParticles=False
            UniformSize=True
            AutomaticInitialSpawning=False
            Acceleration=(Z=-500.000000)
            ColorScale(0)=(Color=(B=67,G=176,R=250,A=255))
            ColorScale(1)=(RelativeTime=1.000000,Color=(B=100,G=100,R=100,A=200))
            FadeOutStartTime=0.800000
            MaxParticles=8
        
            StartSizeRange=(X=(Min=0.800000,Max=0.800000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
            InitialParticlesPerSecond=5000.000000
            Texture=Texture'kf_fx_trip_t.Misc.healingFX'
            LifetimeRange=(Min=2.000000,Max=2.000000)
            StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Max=500.000000))
        End Object
        Emitters(4)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_ExplosionEmitter.SpriteEmitter4'

        Begin Object Class=SpriteEmitter Name=SpriteEmitter5
            FadeOut=True
            FadeIn=True
            RespawnDeadParticles=False
            SpinParticles=True
            UseSizeScale=True
            UseRegularSizeScale=False
            UniformSize=True
            AutomaticInitialSpawning=False
            UseRandomSubdivision=True
            Acceleration=(Z=50.000000)
            ColorMultiplierRange=(Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
            FadeOutStartTime=0.200000
            FadeInEndTime=0.140000
            MaxParticles=3
        
            StartLocationRange=(Z=(Min=20.000000,Max=20.000000))
            SpinsPerSecondRange=(X=(Max=0.100000))
            StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
            SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.500000)
            StartSizeRange=(X=(Min=12.000000,Max=20.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
            ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
            ScaleSizeByVelocityMax=0.000000
            InitialParticlesPerSecond=5000.000000
            Texture=Texture'KillingFloorTextures.LondonCommon.fire3'
            TextureUSubdivisions=4
            TextureVSubdivisions=4
            SecondsBeforeInactive=30.000000
            LifetimeRange=(Min=0.750000,Max=0.750000)
            StartVelocityRange=(Z=(Min=50.000000,Max=50.000000))
        End Object
        Emitters(5)=SpriteEmitter'KFTurbo.P_Husk_Shotgun_ExplosionEmitter.SpriteEmitter5'

     LightType=LT_Steady
     LightHue=255
     LightSaturation=64
     LightBrightness=50.000000
     LightRadius=1.000000
     bNoDelete=False
     bDynamicLight=True
     AmbientSound=Sound'Amb_Destruction.Fire.Kessel_Fire_Small_Vehicle'
     LifeSpan=6.000000
     SoundVolume=255
     SoundRadius=100.000000
    }