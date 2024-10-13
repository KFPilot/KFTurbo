class P_Scrake_Weak extends P_Scrake_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}

defaultproperties
{
     ColOffset=(Z=35.000000)
     ColRadius=22.000000
     ColHeight=10.000000
     HeadHealth=325.000000
     MeleeRange=34.000000
     HealthMax=500.000000
     Health=500
     HeadHeight=2.050000
     HeadScale=1.300000
     HeadRadius=5.500000
     PrePivot=(Z=-13.000000)
     CollisionRadius=22.000000  
     CollisionHeight=40.000000

}