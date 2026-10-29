//Killing Floor Turbo VinylLabelResearchBunkerSix
//Uncommon vinyls that grow stronger with each wave held, reaching full strength after 5 waves.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelResearchBunkerSix extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Research Bunker 6"
	LabelRarity=Uncommon

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Clearance Level Cha-Cha"
		VinylDescription="Increases damage by 2% per wave this vinyl is held, to a maximum of 10%."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBunkerSix'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Centrifuge Cumbia"
		VinylDescription="Increases fire rate by 3% per wave this vinyl is held, to a maximum of 15%."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentBunkerSix'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Blast Door Bolero"
		VinylDescription="Increases max health by 3% per wave this vinyl is held, to a maximum of 15%."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=MaxHealth,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentBunkerSix'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Cold Storage Conga"
		VinylDescription="Increases reload rate by 3% per wave this vinyl is held, to a maximum of 15%."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentBunkerSix'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

/*
	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Redacted Rumba"
		VinylDescription="Rolls increased damage, fire rate or reduced damage taken when acquired. Grows by a fifth per wave held, to full strength after 5 waves."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.1f)
		AugmentList(1)=(Type=FireRate,Multiplier=1.15f)
		AugmentList(2)=(Type=DamageReceived,Multiplier=0.85f)
		AugmentInfoClass=class'VinylAugmentBunkerSixRoll'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'
*/

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Sublevel Six Shuffle"
		VinylDescription="Reduces damage taken by 3% per wave this vinyl is held, to a maximum of 15%."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.85f)
		AugmentInfoClass=class'VinylAugmentBunkerSix'
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Incubator Intermezzo"
		VinylDescription="Increases heal potency by 5% per wave this vinyl is held, to a maximum of 25%."
		SkinNameList(1)="KFTurboCardGame.Label.BUNKER6_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.25f)
		AugmentInfoClass=class'VinylAugmentBunkerSix'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'
}
