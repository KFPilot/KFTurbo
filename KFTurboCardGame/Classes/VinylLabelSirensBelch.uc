//Killing Floor Turbo VinylLabelSirensBelch
//Common vinyls that provide buffs related to Bloat bile.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelSirensBelch extends CardGameVinylLabel;

defaultproperties
{
    LabelName="Siren's Belch"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="REPLACE"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.SIRENS_Default"
		AugmentList(0)=(Type=Headshot,Multiplier=1.05f)
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'
}
