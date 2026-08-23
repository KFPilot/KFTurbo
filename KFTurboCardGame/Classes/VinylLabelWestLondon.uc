//Killing Floor Turbo VinylLabelWestLondon
//Common vinyls that provide single flat buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelWestLondon extends CardGameVinylLabel;

function ActivateBasic(TurboPlayerCardCustomInfo PlayerInfo, TurboVinyl Vinyl, bool bActivate)
{
    TurboVinylBasic(Vinyl).ApplyAugmentList(PlayerInfo);
}

defaultproperties
{
    LabelName="West London"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Long Lane Lo-fi"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.WEST_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Police Station Polka"
		VinylDescription="Increases max ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.WEST_Default"
		AugmentList(0)=(Type=MaxAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Basement Ballad"
		VinylDescription="Increases reload rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.WEST_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Church Carol"
		VinylDescription="Increases magazine ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.WEST_Default"
		AugmentList(0)=(Type=MagazineAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Support0 Class=TurboVinylBasic
		VinylName="Tunnel Tango"
		VinylDescription="Increases weapon bullet penetration by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.WEST_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(0)=TurboVinylBasic'Support0'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Alley Acoustics"
		VinylDescription="Increases heal potency by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.WEST_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Medic1 Class=TurboVinylBasic
		VinylName="Bus Boogie"
		VinylDescription="Increases heal recharge rate by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.WEST_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(1)=TurboVinylBasic'Medic1'
}
