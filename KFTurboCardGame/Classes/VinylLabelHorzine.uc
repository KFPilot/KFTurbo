//Killing Floor Turbo VinylLabelHorzine
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelHorzine extends CardGameVinylLabel;

function ActivateFieldMedic(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
}

defaultproperties
{
    LabelRarity=Uncommon

	Begin Object Name=FieldMedic Class=TurboVinyl
		VinylName="Horzine: Field Medic"
		VinylDescription="A mysterious record."
		SkinList(1)=Texture'KFTurboCardGame.Song.HORZINE_FieldMedic'
		OnActivateVinyl=ActivateFieldMedic
	End Object
	VinylObjectList(0)=TurboVinyl'FieldMedic'
}
