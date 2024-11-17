class P_Stalker_Weak extends P_Stalker_STA;


simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}
defaultproperties
{
     HeadRadius=5.500000
     HeadScale=0.900000
     ColRadius=18.000000
     ColHeight=3.300000
     ColOffset=(Z=30.000000)
     CollisionRadius=18.000000
     CollisionHeight=29.000000
     MeleeRange=23.000000
     HealthMax=50.000000
     Health=50.000000
     HeadHealth=25.000000
     MeleeDamage=5
}