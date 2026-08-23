//Killing Floor Turbo VinylLabelBedlam
//Common vinyls that provide buffs in response to taking damage.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelBedlam extends CardGameVinylLabel;

defaultproperties
{
    LabelName="Bedlam"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Pool Party"
		VinylDescription="Increases fire rate by 10% for 5 seconds after taking damage."
		SkinNameList(1)="KFTurboCardGame.Label.BEDLAM_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicDamaged'
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Balcony Ball"
		VinylDescription="Increases reload rate by 10% for 5 seconds after taking damage."
		SkinNameList(1)="KFTurboCardGame.Label.BEDLAM_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicDamaged'
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Long Hall Days"
		VinylDescription="Increases movement speed by 5% for 5 seconds after taking damage."
		SkinNameList(1)="KFTurboCardGame.Label.BEDLAM_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		AugmentInfoClass=class'VinylAugmentBasicDamaged'
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Red Halls"
		VinylDescription="Increases syringe recharge by 20% for 5 seconds after taking damage."
		SkinNameList(1)="KFTurboCardGame.Label.BEDLAM_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.2f)
		AugmentInfoClass=class'VinylAugmentBasicDamaged'
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Courtyard Conga"
		VinylDescription="Increases melee fire rate by 15% for 5 seconds after taking damage."
		SkinNameList(1)="KFTurboCardGame.Label.BEDLAM_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentBasicDamaged'
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'
}
