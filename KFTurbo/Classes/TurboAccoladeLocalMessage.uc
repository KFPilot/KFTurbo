//Player perk level/achievement notification base class.
class TurboAccoladeLocalMessage extends LocalMessage;

//If true, the earner of the accolade will also display this local message.
var bool bDisplayForAccoladeEarner;

//ACCOLADES USE THIS.
static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return "";
}

defaultproperties
{
    bDisplayForAccoladeEarner=false
    bComplexString=true //We're skipping ANY drawing by setting this to true but not implementing RenderComplexMessage
    bIsConsoleMessage=false
    Lifetime=10
    
    DrawColor=(R=255,G=255,B=255,A=255)

    DrawPivot=DP_UpperRight
    StackMode=SM_Down

    FontSize=3

    PosX=0.95f
    PosY=0.5f
}