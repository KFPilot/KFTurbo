//Killing Floor Turbo W_DualMK23_Attachment
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_DualMK23_Attachment extends DualMK23Attachment;

var	array<string> SkinRefs;

static function PreloadAssets(optional KFWeaponAttachment Spawned)
{
	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));

	if (Spawned != none)
	{
		Spawned.AmbientSound = default.AmbientSound;
	}
}

defaultproperties
{
	SkinRefs=()

	BrotherMesh=SkeletalMesh'KF_Weapons3rd4_Trip.MK23_3rd'
	Mesh=SkeletalMesh'KF_Weapons3rd4_Trip.MK23_3rd'
}
