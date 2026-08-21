//Killing Floor Turbo VinylLabelAdvancedGenetics
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelAdvancedGenetics extends CardGameVinylLabel;

function ActivateCommando(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
}

defaultproperties
{
    LabelName="Advanced Genetics"
    LabelRarity=Uncommon

    Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="REPLACE"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Headshot,Multiplier=1.05f)
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Commando Class=TurboVinyl
		VinylName="Advanced Genetics: Commando"
		VinylDescription="A mysterious record."
		SkinNameList(1)="KFTurboCardGame.Song.ADVGEN_Commando"
		OnActivateVinyl=ActivateCommando
	End Object
	VinylObjectList(1)=TurboVinyl'Commando'
}
