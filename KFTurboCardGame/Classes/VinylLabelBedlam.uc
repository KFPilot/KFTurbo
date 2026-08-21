//Killing Floor Turbo VinylLabelBedlam
//Common vinyls that provide buffs in response to damage.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelBedlam extends CardGameVinylLabel;

defaultproperties
{
    LabelName="Bedlam"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="REPLACE"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.BEDLAM_Default"
		AugmentList(0)=(Type=Headshot,Multiplier=1.05f)
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'
}
