//Killing Floor Turbo TurboVoteFloatLocalMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboVoteFloatLocalMessage extends TurboVoteLocalMessage
    dependson(TurboGameVoteBase);

static final function int EncodeFloat(float Value)
{
    Value *= 1000.f;
    return int(Value) << 8;
}

static final function float DecodeFloat(int Data)
{
    return float(Data >> 8) / 1000.f;
}

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return Repl(Super.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject), "%f", DecodeFloat(Switch));
}

defaultproperties
{

}