//Killing Floor Turbo VinylLabelStFilths
//Uncommon vinyls that provide health, healing and contagion resistance buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelStFilths extends CardGameVinylLabel;

defaultproperties
{
	LabelName="St. Filth's"
	LabelRarity=Uncommon

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Waiting Room Waltz"
		VinylDescription="Increases max health by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=MaxHealth,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Triage Tango"
		VinylDescription="Increases syringe recharge by 15% and heal potency by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.15f)
		AugmentList(1)=(Type=HealPotency,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Quarantine Quadrille"
		VinylDescription="Reduces damage taken from Bloat bile and Siren screams by 25%."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=DamageReceivedBloat,Multiplier=0.75f)
		AugmentList(1)=(Type=DamageReceivedSiren,Multiplier=0.75f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Night Shift Nocturne"
		VinylDescription="Reduces damage taken by 10% while below 50% health."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentBasicCritical'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Gurney Groove"
		VinylDescription="Increases movement speed by 10% for 5 seconds after being healed by a teammate."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicHealed'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Morgue Mambo"
		VinylDescription="Reduces damage taken by 10% and damage taken from Bloat bile by 15%."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.9f)
		AugmentList(1)=(Type=DamageReceivedBloat,Multiplier=0.85f)
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Operating Theatre Overture"
		VinylDescription="Increases heal potency by 20%."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.2f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Medic1 Class=TurboVinylBasic
		VinylName="Pharmacy Phunk"
		VinylDescription="Increases syringe recharge by 25% and fire rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.STFILTHS_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.25f)
		AugmentList(1)=(Type=FireRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(1)=TurboVinylBasic'Medic1'
}
