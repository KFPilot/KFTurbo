//Killing Floor Turbo TurboVinyl
//Base class for purchasable vinyls. Defined as inline objects on CardGameVinylLabel subclasses.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVinyl extends Object
	instanced;

//Set during label initialization. Used so that the server has an easier time telling clients what vinyl this is.
var class<CardGameVinylLabel> LabelClass;
var byte PerkIndex; //Which of the label's lists this vinyl lives in - 255 is the general purpose list.
var int VinylIndex; //Index within that list.

var const localized string VinylName;
var const localized string VinylDescription; //Should describe the vinyl's effect.
var const int VinylPrice;

var const StaticMesh VinylMesh; //Mesh used by the world actor and the UI drawn actor.
//String references to the skins applied to the mesh. Kept as strings so vinyls never hold onto the
//textures - only the Skins array of the actor currently displaying this vinyl references them.
var const array<string> SkinNameList;

//Optional replicated-state actor spawned while a player possesses this vinyl. Abilities can find it
//through the possessing player's TurboPlayerCardCustomInfo.
var const class<VinylAugmentReplicationInfo> AugmentInfoClass;

//Executed on the server when this vinyl is given to (bActivate) or taken from (!bActivate) a player.
delegate OnActivateVinyl(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate);

defaultproperties
{
	PerkIndex=255

	VinylName="Vinyl"
	VinylDescription="A mysterious record."
	VinylPrice=100

	VinylMesh=StaticMesh'KFTurboCardGame.Song.Vinyl'
}
