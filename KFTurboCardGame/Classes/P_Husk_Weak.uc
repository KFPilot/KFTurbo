class P_Husk_Weak extends P_Husk_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}

defaultproperties
{
     ColOffset=(Z=36.000000)
     ColRadius=24.000000
     ColHeight=10.000000    
     PrePivot=(Z=18.000000)
     CollisionRadius=22.000000
     CollisionHeight=26.000000
     HeadHealth=100.000000
     MeleeRange=23.000000
     HealthMax=300.000000
     Health=300
     HeadScale=1.300000
     HeadRadius=5.500000
}