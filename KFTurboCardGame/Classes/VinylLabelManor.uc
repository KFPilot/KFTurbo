//Killing Floor Turbo VinylLabelManor
//Common vinyls that provide precision buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelManor extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Manor"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Ballroom Bolero"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.MANOR_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Grand Hall Gavotte"
		VinylDescription="Reduces spread by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.MANOR_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Library Lied"
		VinylDescription="Increases headshot damage by 5% and reduces spread by 3%."
		SkinNameList(1)="KFTurboCardGame.Label.MANOR_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.05f)
		AugmentList(1)=(Type=SpreadRecoil,Multiplier=0.97f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Wine Cellar Waltz"
		VinylDescription="Increases heal potency by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.MANOR_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Sharpshooter0 Class=TurboVinylBasic
		VinylName="Study Sarabande"
		VinylDescription="Increases weapon bullet penetration by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.MANOR_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(0)=TurboVinylBasic'Sharpshooter0'
}
