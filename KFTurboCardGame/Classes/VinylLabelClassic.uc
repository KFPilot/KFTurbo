//Killing Floor Turbo VinylLabelClassic
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelClassic extends CardGameVinylLabel;

function ActivateSharpshooter(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
}

function ActivateRackEmUp(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
}

defaultproperties
{
    LabelName="Classic"
    LabelRarity=Rare

	Begin Object Name=Sharpshooter Class=TurboVinyl
		VinylName="Sharpshooter"
		VinylDescription="A mysterious record."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Sharpshooter"
		OnActivateVinyl=ActivateSharpshooter
	End Object
	VinylObjectList(0)=TurboVinyl'Sharpshooter'

	Begin Object Name=RackEmUp Class=TurboVinyl
		VinylName="Rack Em Up"
		VinylDescription="Headshots temporarily grant stacking headshot damage."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentInfoClass=class'VinylAugmentRackEmUp'
	End Object
	VinylObjectList(1)=TurboVinyl'RackEmUp'
}
