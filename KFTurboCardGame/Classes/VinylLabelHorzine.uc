//Killing Floor Turbo VinylLabelHorzine
//Uncommon vinyls that provide basic, perk-specific, buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelHorzine extends CardGameVinylLabel;

function ActivateFieldMedic(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
}

defaultproperties
{
    LabelName="Horzine"
    LabelRarity=Uncommon

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="REPLACE"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=Headshot,Multiplier=1.05f)
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=FieldMedic Class=TurboVinyl
		VinylName="Field Medic"
		VinylDescription="A mysterious record."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_FieldMedic"
		OnActivateVinyl=ActivateFieldMedic
	End Object
	VinylObjectList(1)=TurboVinyl'FieldMedic'
}
