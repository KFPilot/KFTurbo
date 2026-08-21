//Killing Floor Turbo TurboVinylBasic
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVinylBasic extends TurboVinyl
	instanced;

var const VinylAugmentBasic.AugmentEntry AugmentList[3];

function ApplyAugmentList(TurboPlayerCardCustomInfo PlayerInfo)
{
    local VinylAugmentBasic Augment;
    Augment = VinylAugmentBasic(PlayerInfo.AuthAugmentInfo);
    Augment.AugmentList[0] = AugmentList[0];
    Augment.AugmentList[1] = AugmentList[1];
    Augment.AugmentList[2] = AugmentList[2];
    Augment.PostNetReceive();
}

defaultproperties
{
    AugmentInfoClass=class'VinylAugmentBasic'
}
