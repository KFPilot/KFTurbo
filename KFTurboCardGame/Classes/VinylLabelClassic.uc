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
    LabelRarity=Rare

	Begin Object Name=Sharpshooter Class=TurboVinyl
		VinylName="Classic: Sharpshooter"
		VinylDescription="A mysterious record."
		SkinNameList(1)="KFTurboCardGame.Song.CLASSIC_Sharpshooter"
		OnActivateVinyl=ActivateSharpshooter
	End Object
	VinylObjectList(0)=TurboVinyl'Sharpshooter'

	Begin Object Name=RackEmUp Class=TurboVinyl
		VinylName="Classic: Rack Em Up"
		VinylDescription="Headshots temporarily grant stacking headshot damage."
		AugmentInfoClass=class'VinylAugmentRackEmUp'
		OnActivateVinyl=ActivateRackEmUp
	End Object
	VinylObjectList(1)=TurboVinyl'RackEmUp'
}
