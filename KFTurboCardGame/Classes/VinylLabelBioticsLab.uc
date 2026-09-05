//Killing Floor Turbo VinylLabelBioticsLab
//Common vinyls that provide a strong buff paired with a small drawback.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelBioticsLab extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Biotics Lab"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Specimen Swing"
		VinylDescription="Increases damage by 10% but reduces max health by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOTICS_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.1f)
		AugmentList(1)=(Type=MaxHealth,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Cloning Chamber Chaconne"
		VinylDescription="Increases reload rate by 10% but increases spread by 20%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOTICS_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentList(1)=(Type=SpreadRecoil,Multiplier=1.2f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Server Room Samba"
		VinylDescription="Increases fire rate by 10% but reduces movement speed by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOTICS_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentList(1)=(Type=MovementSpeed,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Ventilation Vaudeville"
		VinylDescription="Increases movement speed by 10% but reduces max health by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOTICS_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.1f)
		AugmentList(1)=(Type=MaxHealth,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Freezer Fanfare"
		VinylDescription="Increases heal potency by 10% but reduces syringe recharge by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOTICS_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.1f)
		AugmentList(1)=(Type=HealRecharge,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'
}
