//Killing Floor Turbo PurchaseWeaponNotificationMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PurchaseWeaponNotificationMessage extends PurchaseNotificationMessage;

var localized string PurchaseString;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    local string WeaponName;
    WeaponName = class<KFWeaponPickup>(OptionalObject).default.ItemShortName;
    if (WeaponName == "")
    {
        WeaponName = class<KFWeaponPickup>(OptionalObject).default.ItemName;
    }

    return FormatString(Repl(Repl(Repl(default.PurchaseString, "%p", RelatedPRI_1.PlayerName), "%w", WeaponName), "%c", Switch$class'KFTab_BuyMenu'.default.MoneyCaption));
}

defaultproperties
{
    PurchaseString="%k%p%d has %kpurchased%d the %k%w%d for %k%c%d."
}