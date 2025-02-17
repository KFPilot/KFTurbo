//Killing Floor Turbo PurchaseAmmoNotificationMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PurchaseAmmoNotificationMessage extends PurchaseNotificationMessage;

var localized string PurchaseString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(Repl(Repl(default.PurchaseString, "%p", RelatedPRI_1.PlayerName), "%c", Switch$class'KFTab_BuyMenu'.default.MoneyCaption));
}

defaultproperties
{
    PurchaseString="%k%p%d has %kpurchased%d an %kammo restock%d for %k%c%d."
}