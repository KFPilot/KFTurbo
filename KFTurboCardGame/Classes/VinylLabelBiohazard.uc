//Killing Floor Turbo VinylLabelBiohazard
//Common vinyls that provide pairs of flat buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelBiohazard extends CardGameVinylLabel;

defaultproperties
{
    LabelName="Biohazard"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Couch Room Cabaret"
		VinylDescription="Increases fire rate and reload rate by 3%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOHAZARD_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.03f)
		AugmentList(1)=(Type=ReloadRate,Multiplier=1.03f)
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="\"U\" Room Rapsody"
		VinylDescription="Increases magazine ammo and max ammo by 3%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOHAZARD_Default"
		AugmentList(0)=(Type=MagazineAmmo,Multiplier=1.03f)
		AugmentList(1)=(Type=MaxAmmo,Multiplier=1.03f)
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Spawn Stairs Salsa"
		VinylDescription="Increases headshot damage by 3% and reduces spread by 3%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOHAZARD_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=1.03f)
		AugmentList(1)=(Type=HeadshotDamage,Multiplier=1.03f)
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Pump Room Polka"
		VinylDescription="Increases heal potency and heal recharge rate by 6%."
		SkinNameList(1)="KFTurboCardGame.Label.BIOHAZARD_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.06f)
		AugmentList(1)=(Type=HealRecharge,Multiplier=1.06f)
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'
}
