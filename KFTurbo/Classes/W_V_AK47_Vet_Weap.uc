//Killing Floor Turbo W_V_AK47_Vet_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_AK47_Vet_Weap extends W_AK47_Weap;

var byte WeaponTier, PreviousWeaponTier;
var float NextVeterancyCheckTime;

simulated function WeaponTick(float DeltaTime)
{
     Super.WeaponTick(DeltaTime);

     if (NextVeterancyCheckTime < Level.TimeSeconds)
     {
          UpdateWeaponTier(); 
     }
}

simulated function UpdateWeaponTier()
{
     NextVeterancyCheckTime = Level.TimeSeconds + 1.f + (FRand() * 1.f);
     WeaponTier = class'VetWeaponHelper'.static.GetPlayerWeaponTier(Pawn(Owner), class'V_Commando');
     if (WeaponTier == PreviousWeaponTier)
     { 
          return;
     } 

     PreviousWeaponTier = WeaponTier;

     if (Role == ROLE_Authority && W_V_AK47_Vet_Attachment(ThirdPersonActor) != None)
     {
          W_V_AK47_Vet_Attachment(ThirdPersonActor).SetWeaponTier(WeaponTier);
     }
     
     UpdateSkin();
}

simulated function UpdateSkin()
{
     local array<int> SkinIndexList;
     class'VetWeaponHelper'.static.UpdateWeaponSkin(Self, WeaponTier, SkinIndexList);
}

defaultproperties
{
     ItemName="Neon AK47"
     
     SkinRefs(0)="KFTurbo.Vet.AK47_Vet_SHDR"
     PickupClass=Class'KFTurbo.W_V_AK47_Vet_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_AK47_Vet_Attachment'
}