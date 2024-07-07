class W_L2A3_Weap extends W_AK47_Weap;

var Vector ADSPlayerViewOffset;

simulated function ZoomIn(bool bAnimateTransition)
{
     if (bZoomingIn)
     {
          PlayerViewOffset = ADSPlayerViewOffset;
     }
     else
     {
          PlayerViewOffset = default.PlayerViewOffset;
     }
     
     Super.ZoomIn(bAnimateTransition);
}

defaultproperties
{
     ADSPlayerViewOffset=(X=5)

     ReloadRate=3.4
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000

     DisplayFOV=55.000000
	StandardDisplayFOV=60.0
     ZoomedDisplayFOV=65
	PlayerIronSightFOV=65

     PlayerViewOffset=(X=24.000000,Y=26.000000,Z=-12.000000)
     PlayerViewPivot=(Roll=-1000)

     SleeveNum=0
     MeshRef="KFTurbo.SterlingSMG_1st"
     SkinRefs(0)=""
     SkinRefs(1)="KFTurbo.L2A3Sterling.L2A3Sterling_cmb"
     
     Weight=6.000000

     MagCapacity=20
     // WeaponReloadAnim=""
     // bHasAimingMode=
     // TraderInfoTexture=
     // SelectSoundRef=""
     // HudImageRef=""
     // SelectedHudImageRef=""
     FireModeClass(0)=Class'KFTurbo.W_L2A3_Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     // Description=""
     InventoryGroup=4
     // GroupOffset=
     PickupClass=Class'KFTurbo.W_L2A3_Pickup'
     //AttachmentClass=Class'KFTurbo.W_L2A3_Attachment'
     ItemName="L2A3 Incendiary"
}