//Killing Floor Turbo VinylLabelWaterworks
//Common vinyls that provide buffs while the player has avoided taking damage.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelWaterworks extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Waterworks"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Reservoir Reel"
		VinylDescription="Reduces spread by 5% while full health."
		SkinNameList(1)="KFTurboCardGame.Label.WATERWORKS_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.95f)
		AugmentInfoClass=class'VinylAugmentBasicPristine'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Sluice Gate Shanty"
		VinylDescription="Increases reload rate by 10% while full health."
		SkinNameList(1)="KFTurboCardGame.Label.WATERWORKS_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicPristine'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Filter Bed Fandango"
		VinylDescription="Increases headshot damage by 10% while full health."
		SkinNameList(1)="KFTurboCardGame.Label.WATERWORKS_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicPristine'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Aqueduct Aria"
		VinylDescription="Increases movement speed by 5% while full health."
		SkinNameList(1)="KFTurboCardGame.Label.WATERWORKS_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		AugmentInfoClass=class'VinylAugmentBasicPristine'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Cistern Serenade"
		VinylDescription="Increases syringe recharge by 20% while full health."
		SkinNameList(1)="KFTurboCardGame.Label.WATERWORKS_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.2f)
		AugmentInfoClass=class'VinylAugmentBasicPristine'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Medic1 Class=TurboVinylBasic
		VinylName="Settling Tank Sonata"
		VinylDescription="Increases heal potency by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.WATERWORKS_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(1)=TurboVinylBasic'Medic1'
}
