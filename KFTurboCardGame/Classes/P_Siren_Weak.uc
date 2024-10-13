class P_Siren_Weak extends P_Siren_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}

defaultproperties
{
     ScreamRadius=500
     ScreamForce=-100000
     ColRadius=16.000000
     ColHeight=3.300000
     ColOffset=(Z=30.000000)
     CollisionRadius=16.500000
     CollisionHeight=29.000000
     MeleeRange=34.000000
     HeadHealth=100.000000
     HealthMax=150.000000
     Health=150
}