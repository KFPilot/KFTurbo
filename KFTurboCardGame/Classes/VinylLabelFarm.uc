//Killing Floor Turbo VinylLabelFarm
//Common vinyls that provide trader discounts and cheap resupply.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelFarm extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Farm"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Barnyard Bluegrass"
		VinylDescription="Reduces weapon costs at the trader by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.FARM_Default"
		AugmentList(0)=(Type=TraderWeaponCost,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Hayloft Hoedown"
		VinylDescription="Reduces ammo costs at the trader by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.FARM_Default"
		AugmentList(0)=(Type=TraderAmmoCost,Multiplier=0.9f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Silo Square Dance"
		VinylDescription="Increases max ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.FARM_Default"
		AugmentList(0)=(Type=MaxAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Cornfield Country"
		VinylDescription="Reduces armor costs at the trader by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.FARM_Default"
		AugmentList(0)=(Type=TraderArmorCost,Multiplier=0.9f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Tractor Shed Twang"
		VinylDescription="Reduces grenade costs at the trader by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.FARM_Default"
		AugmentList(0)=(Type=TraderGrenadeCost,Multiplier=0.9f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'
}
