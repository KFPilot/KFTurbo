//Killing Floor Turbo PurchaseArmorMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PurchaseArmorMessage extends PurchaseWeaponMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return FormatString(Repl(Repl(Eval(Switch <= RelatedPRI_1.Score, default.PurchaseString, default.CannotPurchaseString), "%w", class<BuyableVest>(OptionalObject).default.ItemName), "%c", Switch$class'KFTab_BuyMenu'.default.MoneyCaption));
}

defaultproperties
{

}