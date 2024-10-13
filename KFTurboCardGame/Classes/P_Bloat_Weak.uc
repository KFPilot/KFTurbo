class P_Bloat_Weak extends P_Bloat_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}

defaultproperties
{
     ColOffset=(Z=50.000000)
     ColRadius=20.000000
     ColHeight=16.000000

     CollisionRadius=20.000000
     CollisionHeight=35.000000
     
     MeleeRange=23.000000

     HealthMax=265.000000
     Health=265
     HeadHeight=2.500000
     HeadScale=1.500000
     HeadHealth=25.000000

}