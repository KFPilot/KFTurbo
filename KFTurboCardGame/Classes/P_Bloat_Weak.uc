class P_Bloat_Weak extends P_Bloat_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}

defaultproperties
{
     ColOffset=(Z=30.000000)
     ColRadius=24.000000
     ColHeight=20.000000
     PrePivot=(Z=-10.000000)
     CollisionRadius=24.000000
     CollisionHeight=34.000000
     MeleeRange=23.000000
     HealthMax=265.000000
     Health=265
     HeadScale=1.300000
     HeadRadius=6.000000
     HeadHealth=25.000000

}