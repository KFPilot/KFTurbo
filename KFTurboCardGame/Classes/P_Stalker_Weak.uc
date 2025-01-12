class P_Stalker_Weak extends P_Stalker_STA;


simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 0.66f, RootBone);
}
defaultproperties
{
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
     OnlineHeadshotOffset=(X=16.000000,Z=27.000000)
     OnlineHeadshotScale=1.100000
     MenuName="Weak Stalker"
}