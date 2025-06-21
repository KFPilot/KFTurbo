//Killing Floor Turbo P_Bloat_Fathead
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Bloat_Fathead extends P_Bloat_SUM;

simulated function PostBeginPlay()
{
     Super.PostBeginPlay();

     SetBoneScale(10, 1.5f, 'CHR_Head');
     SetBoneScale(11, 1.25f, 'CHR_Neck');
     SetBoneScale(12, 1.5f, 'CHR_Stomach');
}

function RangedAttack(Actor A)
{
     if ( bShotAnim )
     {
          return;
     }

     if ( Physics == PHYS_Swimming )
     {
          SetAnimAction('Claw');
          bShotAnim = true;
          return;
     }

     if ( (KFDoorMover(A) != none || VSize(A.Location-Location) <= 250) && !bDecapitated && !bHarpoonStunned )
     {
          bShotAnim = true;

          SetAnimAction('ZombieBarf');
          Controller.bPreparingMove = true;
          Acceleration = vect(0,0,0);

          // Randomly send out a message about Bloat Vomit burning(15% chance)
          if ( FRand() < 0.50 && KFHumanPawn(A) != none && PlayerController(KFHumanPawn(A).Controller) != none )
          {
               PlayerController(KFHumanPawn(A).Controller).Speech('AUTO', 7, "");
          }
     }
}

defaultproperties
{
     MenuName="Fat Head"

     HeadHeight=2.000000
     HeadScale=2.500000
     ColOffset=(Z=60.000000)
     ColRadius=27.000000
     ColHeight=30.000000
     
     HealthMax=1500.000000
     Health=1500.000000
     HeadHealth=1500.000000

     GroundSpeed=60.000000
     WaterSpeed=80.000000
}