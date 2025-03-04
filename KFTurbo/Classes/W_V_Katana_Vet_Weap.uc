//Killing Floor Turbo W_V_Katana_Vet_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Katana_Vet_Weap extends W_Katana_Weap;

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
     WeaponTier = class'VetWeaponHelper'.static.GetPlayerWeaponTier(Pawn(Owner), class'V_Berserker');
     if (WeaponTier == PreviousWeaponTier)
     { 
          return;
     } 

     PreviousWeaponTier = WeaponTier;

     if (Role == ROLE_Authority)
     {
          if (W_V_Katana_Vet_Attachment(ThirdPersonActor) != None)
          {
               W_V_Katana_Vet_Attachment(ThirdPersonActor).SetWeaponTier(WeaponTier);
          }
     }
     
     UpdateSkin();
}

simulated function UpdateSkin()
{
     local array<int> SkinIndexList;
     class'VetWeaponHelper'.static.UpdateWeaponSkin(Self, WeaponTier, SkinIndexList);

     if (Level.NetMode != NM_DedicatedServer && Shader(BloodyMaterial) != None)
     {
          Shader(BloodyMaterial).SelfIllumination = class'VetWeaponHelper'.default.VeterancyColorTextureList[WeaponTier];
     }
}

defaultproperties
{
     ItemName="Neon Katana"
     
     SkinRefs(0)="KFTurbo.Vet.Katana_Vet_SHDR"
     BloodyMaterialRef="KFTurbo.Vet.Katana_Vet_Bloody_SHDR"

     PickupClass=Class'KFTurbo.W_V_Katana_Vet_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_Katana_Vet_Attachment'
}
