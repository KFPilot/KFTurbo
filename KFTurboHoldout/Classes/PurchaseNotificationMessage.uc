//Killing Floor Turbo PurchaseNotificationMessage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class PurchaseNotificationMessage extends TurboLocalMessage;

defaultproperties
{
    bUseFullFormatting = true
    bIsConsoleMessage = true
    bIsSpecial = false
    bFadeMessage = true
    Lifetime=10
    
    bRelevantToInGameChat=true
}