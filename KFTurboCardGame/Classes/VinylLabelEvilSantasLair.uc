//Killing Floor Turbo VinylLabelEvilSantasLair
//Common vinyls that provide resupply flavored buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelEvilSantasLair extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Evil Santa's Lair"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Workshop Waltz"
		VinylDescription="Increases max ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.SANTA_Default"
		AugmentList(0)=(Type=MaxAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Toybox Toccata"
		VinylDescription="Increases magazine ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.SANTA_Default"
		AugmentList(0)=(Type=MagazineAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Sleigh Bay Swing"
		VinylDescription="Increases reload rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.SANTA_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Chimney Chant"
		VinylDescription="Reduces fire damage taken by 15%."
		SkinNameList(1)="KFTurboCardGame.Label.SANTA_Default"
		AugmentList(0)=(Type=DamageReceivedFire,Multiplier=0.85f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Grotto Gigue"
		VinylDescription="Reduces ammo costs at the trader by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.SANTA_Default"
		AugmentList(0)=(Type=TraderAmmoCost,Multiplier=0.9f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'
}
