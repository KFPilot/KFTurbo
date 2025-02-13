//Killing Floor Turbo W_V_Katana_VM_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_Katana_VM_Weap extends W_Katana_Weap;

defaultproperties
{
     ItemName="VM Katana"
     
     BloodyMaterialRef="KFTurbo.VMBoard.Katana_Bloody_VM_CMB"
     SkinRefs(0)="KFTurbo.VMBoard.Katana_VM_CMB"
     PickupClass=Class'KFTurbo.W_V_Katana_VM_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_Katana_VM_Attachment'
}
