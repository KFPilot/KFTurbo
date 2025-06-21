//Killing Floor Turbo MerchantVoicePack
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class MerchantVoicePack extends KFVoicePack;

defaultproperties
{
	TraderSound(0)=SoundGroup'KFTurbo.Merchant.Radio_Moving'
	TraderSound(1)=SoundGroup'KFTurbo.Merchant.Radio_AlmostOpen'
	TraderSound(2)=SoundGroup'KFTurbo.Merchant.Radio_ShopsOpen'
	TraderSound(3)=SoundGroup'KFTurbo.Merchant.Radio_LastWave'
	TraderSound(4)=SoundGroup'KFTurbo.Merchant.Radio_ThirtySeconds'
	TraderSound(5)=SoundGroup'KFTurbo.Merchant.Radio_TenSeconds'
	TraderSound(6)=SoundGroup'KFTurbo.Merchant.Radio_Closed'
	TraderSound(7)=SoundGroup'KFTurbo.Merchant.Welcome'
	TraderSound(8)=SoundGroup'KFTurbo.Merchant.TooExpensive'
	TraderSound(9)=SoundGroup'KFTurbo.Merchant.TooHeavy'
	TraderSound(10)=SoundGroup'KFTurbo.Merchant.ThirtySeconds'
	TraderSound(11)=SoundGroup'KFTurbo.Merchant.TenSeconds'
	TraderString(0)="Watch the arrow - check where the shop is!"
	TraderString(1)="Make sure you are close to the shop when you finish them off"
	TraderString(2)="The shop is now open for business!"
	TraderString(3)="Shop's open, last chance to stock up before the Patriarch!"
	TraderString(4)="30 seconds before the shop shuts!"
	TraderString(5)="10 seconds left!"
	TraderString(6)="The shop is now CLOSED until you've cleared the next wave!"
	TraderString(7)="Welcome to the shop � sell what you've got, Buy Bigger Guns!"
	TraderString(8)="You can't afford that � pick something cheaper, or sell something first!"
	TraderString(9)="That is too heavy for you � pick something smaller, or sell something!"
	TraderString(10)="30 seconds before the shop shuts!"
	TraderString(11)="10 seconds left!"
	TraderRadioBeep=Sound'KFTurbo.Merchant.Walkie_Beep'
	
	ShoutVolume=2
	WhisperVolume=1
	ShoutRadius=409.600006
	WhisperRadius=25.600000
	unitWhisperDistance=512.000000
	unitShoutDistance=4096.000000
}
