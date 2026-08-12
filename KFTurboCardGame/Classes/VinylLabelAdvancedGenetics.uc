//Killing Floor Turbo VinylLabelAdvancedGenetics
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelAdvancedGenetics extends CardGameVinylLabel;

function ActivateCommando(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
}

defaultproperties
{
	Begin Object Name=Commando Class=TurboVinyl
		VinylName="Advanced Genetics: Commando"
		VinylDescription="A mysterious record."
		SkinList(1)=Texture'KFTurboCardGame.Song.ADVGEN_Commando'
		OnActivateVinyl=ActivateCommando
	End Object
	VinylObjectList(0)=TurboVinyl'Commando'
}
