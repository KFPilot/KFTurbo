//Killing Floor Turbo VinylLabelSirensBelch
//Common vinyls that provide buffs to help resist damage. Only has Berserker vinyls.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelSirensBelch extends CardGameVinylLabel;

defaultproperties
{
    LabelName="Siren's Belch"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Reception Ragtime"
		VinylDescription="Reduces damage taken by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.SIRENS_Default"
		AugmentList(0)=(Type=DamageResistance,Multiplier=1.05f)
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Reception Ragtime"
		VinylDescription="Reduces damage taken from Bloat bile by 15%."
		SkinNameList(1)="KFTurboCardGame.Label.SIRENS_Default"
		AugmentList(0)=(Type=DamageResistanceBloat,Multiplier=1.15f)
	End Object
	BerserkerVinylList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Distillery Dirge"
		VinylDescription="Reduces damage taken from Siren screams by 15%."
		SkinNameList(1)="KFTurboCardGame.Label.SIRENS_Default"
		AugmentList(0)=(Type=DamageResistanceSiren,Multiplier=1.15f)
	End Object
	BerserkerVinylList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Distillery Dirge"
		VinylDescription="Reduces fire damage taken by 15%."
		SkinNameList(1)="KFTurboCardGame.Label.SIRENS_Default"
		AugmentList(0)=(Type=DamageResistanceFire,Multiplier=1.15f)
	End Object
	BerserkerVinylList(3)=TurboVinylBasic'Default3'
}
