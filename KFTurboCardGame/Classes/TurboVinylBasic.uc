//Killing Floor Turbo TurboVinylBasic
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVinylBasic extends TurboVinyl
	instanced;

var const VinylAugmentBasic.AugmentEntry AugmentList[3];
var const VinylAugmentBasic.AugmentEntry InvalidAugment;

function ApplyAugmentList(TurboPlayerCardCustomInfo PlayerInfo)
{
    local VinylAugmentBasic Augment;
    Augment = VinylAugmentBasic(PlayerInfo.AuthAugmentInfo);

    if (Augment == None)
    {
        return;
    }

    Augment.AugmentList[0] = AugmentList[0];
    Augment.AugmentList[1] = AugmentList[1];
    Augment.AugmentList[2] = AugmentList[2];
    Augment.PostNetReceive();
    Augment.ForceNetUpdate();
}

function ResetAugmentList(TurboPlayerCardCustomInfo PlayerInfo)
{
    local VinylAugmentBasic Augment;
    Augment = VinylAugmentBasic(PlayerInfo.AuthAugmentInfo);

    if (Augment == None)
    {
        return;
    }

    Augment.AugmentList[0] = InvalidAugment;
    Augment.AugmentList[1] = InvalidAugment;
    Augment.AugmentList[2] = InvalidAugment;
    Augment.PostNetReceive();
    Augment.ForceNetUpdate();
}

defaultproperties
{
    AugmentInfoClass=class'VinylAugmentBasic'
    InvalidAugment=(Type=Invalid,Multiplier=1.f)
}
