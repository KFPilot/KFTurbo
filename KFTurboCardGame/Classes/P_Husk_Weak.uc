//Killing Floor Turbo P_Husk_Weak
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
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
     MeleeDamage=7
     HuskFireProjClass=Class'KFTurboCardGame.P_Husk_Weak_Proj'
     OnlineHeadshotOffset=(X=18.000000,Z=40.000000)
     MenuName="Weak Husk"
}
