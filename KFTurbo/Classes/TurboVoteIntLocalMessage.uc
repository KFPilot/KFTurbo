//Killing Floor Turbo TurboVoteIntLocalMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVoteIntLocalMessage extends TurboVoteFloatLocalMessage
    dependson(TurboGameVoteBase);

static final function int EncodeInt(int Value)
{
    return Value << 8;
}

static final function int DecodeInt(int Data)
{
    return Data >> 8;
}

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return Repl(Super.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject), "%i", DecodeInt(Switch));
}

defaultproperties
{

}