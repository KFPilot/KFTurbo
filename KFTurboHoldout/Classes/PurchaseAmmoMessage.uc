//Killing Floor Turbo PurchaseAmmoMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PurchaseAmmoMessage extends PurchaseMessage;

var localized string PurchaseString;
var localized string CannotPurchaseString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(Repl(Eval(Switch <= RelatedPRI_1.Score, default.PurchaseString, default.CannotPurchaseString), "%c", Switch$class'KFTab_BuyMenu'.default.MoneyCaption));
}

defaultproperties
{
    PurchaseString="%dRestock %kammo%d for %k%c%d."
    CannotPurchaseString="%dRestock %kammo%d for %nk%c%d."
}