class P_Siren_Weak extends P_Siren_STA;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}

defaultproperties
{
     HeadRadius=5.500000
     HeadScale=0.9000000
     ScreamRadius=500
     ScreamForce=-100000
     ColRadius=16.000000
     PrePivot=(Z=-1.000000)
     ColHeight=4.000000
     ColOffset=(Z=33.000000)
     CollisionRadius=16.500000
     CollisionHeight=31.000000
     MeleeRange=34.000000
     HeadHealth=100.000000
     HealthMax=150.000000
     Health=150
     MeleeDamage=6
     ScreamDamage=4
}