//Killing Floor Turbo VinylLabelKMShipping
//Uncommon vinyls that scale with how much carry weight is in use.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelKMShipping extends CardGameVinylLabel;

defaultproperties
{
	LabelName="K&M Shipping Inc."
	LabelRarity=Uncommon

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Hammer Lane Hustle"
		VinylDescription="Increases damage by up to 8% based on how much carry weight is in use."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.08f)
		AugmentInfoClass=class'VinylAugmentKMShipping'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Eighteen-Wheeler Waltz"
		VinylDescription="Reduces damage taken by up to 10% based on how much carry weight is in use."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentKMShipping'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Long Haul Lindy"
		VinylDescription="Increases fire rate by up to 10% based on how much carry weight is in use."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentKMShipping'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Backhaul Boogie"
		VinylDescription="Increases reload rate by up to 15% based on how much carry weight is in use."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentKMShipping'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Flatbed Foxtrot"
		VinylDescription="Increases carry weight by 2."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=CarryWeight,Multiplier=2.f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Deadhead Disco"
		VinylDescription="Increases melee fire rate by up to 20% based on how much carry weight is in use."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=FireRateMelee,Multiplier=1.2f)
		AugmentInfoClass=class'VinylAugmentKMShipping'
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'

	Begin Object Name=Demolitions0 Class=TurboVinylBasic
		VinylName="Convoy Calypso"
		VinylDescription="Increases movement speed by up to 5% and acceleration by up to 15% based on how much carry weight is in use."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		AugmentList(1)=(Type=MovementAccel,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentKMShipping'
		OnActivateVinyl=ActivateBasic
	End Object
	DemolitionsVinylList(0)=TurboVinylBasic'Demolitions0'

	Begin Object Name=Support0 Class=TurboVinylBasic
		VinylName="Weigh Station Shanty"
		VinylDescription="Increases weapon bullet penetration by up to 25% based on how much carry weight is in use."
		SkinNameList(1)="KFTurboCardGame.Label.KMSHIPPING_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.25f)
		AugmentInfoClass=class'VinylAugmentKMShipping'
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(0)=TurboVinylBasic'Support0'
}
