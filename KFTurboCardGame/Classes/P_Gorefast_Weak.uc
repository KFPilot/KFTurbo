class P_Gorefast_Weak extends P_Gorefast_STA;


simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}
defaultproperties
{
     HeadRadius=5.500000
     HeadHeight=1.650000
     HeadScale=0.900000
     ColRadius=16.000000
     ColHeight=6.600000
     ColOffset=(Z=40.000000)
     PrePivot=(Z=0.000000)
     CollisionRadius=16.500000
     CollisionHeight=35.000000
     MeleeRange=23.000000
     HealthMax=125.000000
     Health=125.000000
     HeadHealth=25.000000
}