//Killing Floor Turbo VinylLabelOffices
//Common vinyls that provide reload and magazine discipline.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelOffices extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Offices"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Cubicle Cha-Cha"
		VinylDescription="Increases reload rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.OFFICES_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Boardroom Boogie"
		VinylDescription="Increases magazine ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.OFFICES_Default"
		AugmentList(0)=(Type=MagazineAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Copy Room Calypso"
		VinylDescription="Increases fire rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.OFFICES_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Elevator Elegy"
		VinylDescription="Increases movement speed by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.OFFICES_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Break Room Bebop"
		VinylDescription="Increases syringe recharge by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.OFFICES_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'
}
