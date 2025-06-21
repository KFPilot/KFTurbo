//Killing Floor Turbo PurchaseRoomMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PurchaseRoomMessage extends PurchaseMessage;

var localized string PurchaseString;
var localized string CannotPurchaseString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(Repl(Repl(Eval(Switch <= RelatedPRI_1.Score, default.PurchaseString, default.CannotPurchaseString), "%r", HoldoutRoomManager(OptionalObject).GetRoomName()), "%c", Switch$class'KFTab_BuyMenu'.default.MoneyCaption));
}

defaultproperties
{
    PurchaseString="%kPurchase%d the %k%r%d area for %k%c%d."
    CannotPurchaseString="%kPurchase%d the %k%r%d area for %nk%c%d."
}