//Killing Floor Turbo KFTurboPlusMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class KFTurboPlusMessage extends TurboLocalMessage;

enum ETurboPlusMessage
{
    TraderHint
};

var localized string HowToTradeHint;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    switch(ETurboPlusMessage(Switch))
    {
        case TraderHint:
            return FormatString(default.HowToTradeHint);
    }

    return "";
}

static function bool IgnoreLocalMessage(TurboPlayerController PlayerController, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    if (PlayerController == None && PlayerController.TurboInteraction == None)
    {
        return false;
    }

    if (Switch == ETurboPlusMessage.TraderHint)
    {
        return !class'TurboInteraction'.static.IsShiftTradeEnabled(PlayerController);
    }

    return true; //Undefined switch.
}

defaultproperties
{
    HowToTradeHint="%kPress SHIFT%d to open the %ktrader menu%d anywhere. The %kconsole command TRADE%d can also be used."

    Lifetime=15
    bIsSpecial=false
    bIsConsoleMessage=true
}
