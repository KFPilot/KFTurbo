//Killing Floor Turbo W_FlareRevolver_Fire_Alt
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_FlareRevolver_Fire_Alt extends W_FlareRevolver_Fire;


simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;
	local vector AdjustedVelocity;
	local float AdjustedSpeed;

     if( Instigator != none )
     {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

     if( KFPC == none || KFPwn == none )
    	     return;

	if( !KFPC.bFreeCamera )
	{
    	     if( Weapon.GetFireMode(1).bIsFiring )
          {
               NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
               NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

               if( Rand( 2 ) == 1 )
               NewRecoilRotation.Yaw *= -1;

               if( Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
                    Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
               {
                    AdjustedVelocity = Weapon.Owner.Velocity;
                    // Ignore Z velocity in low grav so we don't get massive recoil
                    AdjustedVelocity.Z = 0;
                    AdjustedSpeed = VSize(AdjustedVelocity);
                    //log("AdjustedSpeed = "$AdjustedSpeed$" scale = "$(AdjustedSpeed* RecoilVelocityScale * 0.5));

                    // Reduce the falling recoil in low grav
                    NewRecoilRotation.Pitch += (AdjustedSpeed* 3 * 0.5);
                    NewRecoilRotation.Yaw += (AdjustedSpeed* 3 * 0.5);
               }
               else
               {
                         //log("Velocity = "$VSize(Weapon.Owner.Velocity)$" scale = "$(VSize(Weapon.Owner.Velocity)* RecoilVelocityScale));
                    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
                    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
               }

               NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
               NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
               NewRecoilRotation *= Rec;

               KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
          }
 	}
}


defaultproperties
{
     FireRate=0.700000
     ProjectileClass=Class'KFTurboRandomizer.W_FlareRevolver_Nade'
}