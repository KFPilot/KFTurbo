class P_Clot_Weak extends P_Clot_STA;


simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}
defaultproperties
{
     HeadRadius=5.500000
     HeadHeight=1.320000
     HeadScale=0.900000
     ColRadius=16.000000
     ColHeight=3.300000
     ColOffset=(Z=30.000000)
     PrePivot=(Z=4.000000)
     CollisionRadius=16.500000
     CollisionHeight=29.000000
     MeleeRange=15.000000
     HealthMax=65.000000
     Health=65.000000
     HeadHealth=25.000000
}