//Killing Floor Turbo VinylLabelVagrant
//Common vinyls that scale with how much of the player's carry weight is free.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelVagrant extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Vagrant"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Millpond Minuet"
		VinylDescription="Increases movement speed by up to 10% based on how much carry weight is free."
		SkinNameList(1)="KFTurboCardGame.Label.VAGRANT_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentVagrant'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Hedgerow Hornpipe"
		VinylDescription="Increases reload rate by up to 10% based on how much carry weight is free."
		SkinNameList(1)="KFTurboCardGame.Label.VAGRANT_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentVagrant'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Footbridge Foxtrot"
		VinylDescription="Reduces spread by up to 10% based on how much carry weight is free."
		SkinNameList(1)="KFTurboCardGame.Label.VAGRANT_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentVagrant'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Orchard Overture"
		VinylDescription="Increases movement acceleration by up to 15% based on how much carry weight is free."
		SkinNameList(1)="KFTurboCardGame.Label.VAGRANT_Default"
		AugmentList(0)=(Type=MovementAccel,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentVagrant'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Well Water Waltz"
		VinylDescription="Increases syringe recharge by up to 20% based on how much carry weight is free."
		SkinNameList(1)="KFTurboCardGame.Label.VAGRANT_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.2f)
		AugmentInfoClass=class'VinylAugmentVagrant'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Cottage Cakewalk"
		VinylDescription="Increases melee fire rate by up to 15% based on how much carry weight is free."
		SkinNameList(1)="KFTurboCardGame.Label.VAGRANT_Default"
		AugmentList(0)=(Type=FireRateMelee,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentVagrant'
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'
}
