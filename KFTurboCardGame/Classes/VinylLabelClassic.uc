//Killing Floor Turbo VinylLabelClassic
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelClassic extends CardGameVinylLabel;

function ActivateSharpshooter(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
}

defaultproperties
{
	Begin Object Name=Sharpshooter Class=TurboVinyl
		VinylName="Classic: Sharpshooter"
		VinylDescription="A mysterious record."
		SkinList(1)=Texture'KFTurboCardGame.Song.CLASSIC_Sharpshooter'
		OnActivateVinyl=ActivateSharpshooter
	End Object
	VinylObjectList(0)=TurboVinyl'Sharpshooter'
}
