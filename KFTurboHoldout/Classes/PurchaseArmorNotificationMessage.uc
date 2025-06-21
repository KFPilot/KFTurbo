//Killing Floor Turbo PurchaseArmorNotificationMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PurchaseArmorNotificationMessage extends PurchaseWeaponNotificationMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(Repl(Repl(Repl(default.PurchaseString, "%p", RelatedPRI_1.PlayerName), "%w", class<BuyableVest>(OptionalObject).default.ItemName), "%c", Switch$class'KFTab_BuyMenu'.default.MoneyCaption));
}

defaultproperties
{
    PurchaseString="%k%p%d has %kpurchased %w%d for %k%c%d."
}