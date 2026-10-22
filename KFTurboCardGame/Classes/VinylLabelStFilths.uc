//Killing Floor Turbo VinylLabelStFilths
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelStFilths extends CardGameVinylLabel;

defaultproperties
{
	LabelName="St. Filth's"
	LabelRarity=Uncommon

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="REPLACE"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'
}
