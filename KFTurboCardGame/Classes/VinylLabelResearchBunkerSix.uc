//Killing Floor Turbo VinylLabelResearchBunkerSix
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelResearchBunkerSix extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Research Bunker 6"
	LabelRarity=Uncommon

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="UPDATE ME"
		VinylDescription="Reduces damage taken by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Default0'
}
