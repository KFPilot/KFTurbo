//Killing Floor Turbo TurboVinyl
//Base class for purchasable vinyls. Defined as inline objects on CardGameVinylLabel subclasses.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVinyl extends Object
	instanced;

//Set during label initialization. Used so that the server has an easier time telling clients what vinyl this is.
var class<CardGameVinylLabel> LabelClass;
var int VinylIndex;

var localized string VinylName;
var localized string VinylDescription; //Should describe the vinyl's effect.
var int VinylPrice;

var StaticMesh VinylMesh; //Mesh used by the world actor and the UI drawn actor.
var array<Material> SkinList; //Skins applied to the mesh.

//Optional replicated-state actor spawned while a player possesses this vinyl. Abilities can find it
//through the possessing player's TurboPlayerCardCustomInfo.
var class<VinylAugmentReplicationInfo> AugmentInfoClass;

//Executed on the server when this vinyl is given to (bActivate) or taken from (!bActivate) a player.
delegate OnActivateVinyl(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate);

defaultproperties
{
	VinylName="Vinyl"
	VinylDescription="A mysterious record."
	VinylPrice=100

	VinylMesh=StaticMesh'KFTurboCardGame.Song.Vinyl'
}
