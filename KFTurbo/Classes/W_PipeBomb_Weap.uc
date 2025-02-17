//Killing Floor Turbo W_PipeBomb_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_PipeBomb_Weap extends PipeBombExplosive;

simulated final function TurboPlayerController ResolvePlayerController()
{
     if (Role == ROLE_Authority)
     {
          if (Instigator != None)
          {
               return TurboPlayerController(Instigator.Controller);
          }

          return None;
     }
     
     return TurboPlayerController(Level.GetLocalPlayerController());
}

simulated function PreBeginPlay()
{
     Super.PreBeginPlay();

     UpdateInventoryGroup(ResolvePlayerController() != None && ResolvePlayerController().ShouldPipebombUseSpecialGroup());
}

simulated function UpdateInventoryGroup(bool bUseSpecialGroup)
{
     if (bUseSpecialGroup)
     {
          InventoryGroup = 5;
          GroupOffset = 0;
          Priority = 0;
     }
     else
     {
          InventoryGroup = default.InventoryGroup;
          GroupOffset = default.GroupOffset;
          Priority = default.Priority;
     }
}

function AddReloadedAmmo()
{
	Super.AddReloadedAmmo();
	if (Role == ROLE_Authority) { class'WeaponHelper'.static.OnWeaponReload(Self); }
}

defaultproperties
{
     FireModeClass(0)=Class'KFTurbo.W_PipeBomb_Fire'
     PickupClass=Class'KFTurbo.W_PipeBomb_Pickup'
}
