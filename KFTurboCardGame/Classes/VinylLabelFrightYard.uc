//Killing Floor Turbo VinylLabelFrightYard
//Common vinyls that provide flat ammo logistics buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelFrightYard extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Fright Yard"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Container Cantata"
		VinylDescription="Increases max ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.FRIGHT_Default"
		AugmentList(0)=(Type=MaxAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Gantry Groove"
		VinylDescription="Increases magazine ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.FRIGHT_Default"
		AugmentList(0)=(Type=MagazineAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Crane Cab Cakewalk"
		VinylDescription="Increases reload rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.FRIGHT_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Forklift Foxtrot"
		VinylDescription="Increases movement speed by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.FRIGHT_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Cargo Hold Chorale"
		VinylDescription="Increases max ammo and magazine ammo by 3%."
		SkinNameList(1)="KFTurboCardGame.Label.FRIGHT_Default"
		AugmentList(0)=(Type=MaxAmmo,Multiplier=1.03f)
		AugmentList(1)=(Type=MagazineAmmo,Multiplier=1.03f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'

	Begin Object Name=Support0 Class=TurboVinylBasic
		VinylName="Dry Dock Disco"
		VinylDescription="Increases weapon bullet penetration by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.FRIGHT_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(0)=TurboVinylBasic'Support0'
}
