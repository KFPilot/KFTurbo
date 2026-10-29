//Killing Floor Turbo VinylLabelHorzine
//Uncommon vinyls that provide basic, perk-specific, buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelHorzine extends CardGameVinylLabel;

defaultproperties
{
    LabelName="Horzine"
    LabelRarity=Uncommon

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Hazard Pay Hustle"
		VinylDescription="Increases melee fire rate by 10% and reduces damage taken by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=FireRateMelee,Multiplier=1.1f)
		AugmentList(1)=(Type=DamageReceived,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'

	Begin Object Name=Commando0 Class=TurboVinylBasic
		VinylName="Onboarding Overture"
		VinylDescription="Increases fire rate, reload rate and magazine ammo by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentList(1)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentList(2)=(Type=MagazineAmmo,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	CommandoVinylList(0)=TurboVinylBasic'Commando0'

	Begin Object Name=Demolitions0 Class=TurboVinylBasic
		VinylName="Severance Samba"
		VinylDescription="Reduces grenade costs at the trader by 15% and increases max ammo by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=TraderGrenadeCost,Multiplier=0.85f)
		AugmentList(1)=(Type=MaxAmmo,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	DemolitionsVinylList(0)=TurboVinylBasic'Demolitions0'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Liability Lullaby"
		VinylDescription="Increases heal potency and syringe recharge by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=1.1f)
		AugmentList(1)=(Type=HealRecharge,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Medic1 Class=TurboVinylBasic
		VinylName="Shareholder Shuffle"
		VinylDescription="Increases max health by 10% and movement speed by 3%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=MaxHealth,Multiplier=1.1f)
		AugmentList(1)=(Type=MovementSpeed,Multiplier=1.03f)
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(1)=TurboVinylBasic'Medic1'

	Begin Object Name=Firebug0 Class=TurboVinylBasic
		VinylName="Quarterly Quickstep"
		VinylDescription="Increases max ammo by 20%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=MaxAmmo,Multiplier=1.2f)
		OnActivateVinyl=ActivateBasic
	End Object
	FirebugVinylList(0)=TurboVinylBasic'Firebug0'

	Begin Object Name=Sharpshooter0 Class=TurboVinylBasic
		VinylName="Compliance Cha-Cha"
		VinylDescription="Increases headshot damage by 8% and reduces spread by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.08f)
		AugmentList(1)=(Type=SpreadRecoil,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(0)=TurboVinylBasic'Sharpshooter0'

	Begin Object Name=Support0 Class=TurboVinylBasic
		VinylName="Payroll Polka"
		VinylDescription="Increases weapon bullet penetration by 15% and carry weight by 1."
		SkinNameList(1)="KFTurboCardGame.Label.HORZINE_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.15f)
		AugmentList(1)=(Type=CarryWeight,Multiplier=1.f)
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(0)=TurboVinylBasic'Support0'
}
