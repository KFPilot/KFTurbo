//Killing Floor Turbo W_V_MK23_Turbo_Attachment
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_MK23_Turbo_Attachment extends MK23Attachment;

function vector GetCorrectedHitNormal()
{
     local vector FireDirection;
     local vector HitLocation, HitNormal;
     FireDirection = Normal(mHitLocation - Instigator.Location);
     if (Trace(HitLocation, HitNormal, mHitLocation - FireDirection, mHitLocation + FireDirection, false) != None)
     {
          return HitNormal;
     }

     return mHitNormal;
}

simulated function PostNetReceive()
{
     Super.PostNetReceive();

	if (FiringMode == 0 && OldSpawnHitCount != SpawnHitCount && Instigator != None && Instigator.Role == ROLE_AutonomousProxy)
     {
          mHitNormal = GetCorrectedHitNormal();
          ThirdPersonEffects();
          FlashCount = 0;
     }
}

defaultproperties
{
     Skins(0)=Combiner'KFTurbo.Turbo.MK23_3RD_Turbo_CMB'
} 