//Killing Floor Turbo W_V_DualMK23_Turbo_Weap
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_V_DualMK23_Turbo_Weap extends W_DualMK23_Weap;

defaultproperties
{
     SkinRefs(0)="KFTurboWeaponSkins.Turbo.MK23_Turbo_SHDR"
     
     ItemName="Dual Turbo MK23s"
     DemoReplacement=Class'KFTurbo.W_V_MK23_Turbo_Weap'
     PickupClass=Class'KFTurbo.W_V_DualMK23_Turbo_Pickup'
     AttachmentClass=Class'KFTurbo.W_V_DualMK23_Turbo_Attachment'
}
