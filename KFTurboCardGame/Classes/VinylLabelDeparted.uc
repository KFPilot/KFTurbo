//Killing Floor Turbo VinylLabelDeparted
//Common vinyls that provide buffs while the player is at low health.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelDeparted extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Departed"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Station Swansong"
		VinylDescription="Reduces damage taken by 10% while below 75% health."
		SkinNameList(1)="KFTurboCardGame.Label.DEPARTED_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentBasicDesperate'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Terrace Threnody"
		VinylDescription="Increases movement speed by 5% while below 75% health."
		SkinNameList(1)="KFTurboCardGame.Label.DEPARTED_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		AugmentInfoClass=class'VinylAugmentBasicDesperate'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Boxcar Ballad"
		VinylDescription="Increases reload rate by 10% while below 75% health."
		SkinNameList(1)="KFTurboCardGame.Label.DEPARTED_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicDesperate'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Helipad Hymn"
		VinylDescription="Increases syringe recharge by 20% while below 75% health."
		SkinNameList(1)="KFTurboCardGame.Label.DEPARTED_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.2f)
		AugmentInfoClass=class'VinylAugmentBasicDesperate'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Last Train Lament"
		VinylDescription="Increases melee fire rate by 15% while below 75% health."
		SkinNameList(1)="KFTurboCardGame.Label.DEPARTED_Default"
		AugmentList(0)=(Type=FireRateMelee,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentBasicDesperate'
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'
}
