//Killing Floor Turbo VinylLabelClassic
//Rare vinyls named after classic perk skills. Each is a bespoke, event-driven mechanic.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelClassic extends CardGameVinylLabel;

defaultproperties
{
    LabelName="Classic"
    LabelRarity=Rare


	Begin Object Name=RackEmUp Class=TurboVinyl
		VinylName="Rack Em Up"
		VinylDescription="Headshots increase headshot damage by 5% to a maximum of 50%. Resets after 10 seconds of not scoring a headshot."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentInfoClass=class'VinylAugmentRackEmUp'
	End Object
	VinylObjectList(0)=TurboVinyl'RackEmUp'

	Begin Object Name=Berserker0 Class=TurboVinyl
		VinylName="Vampire"
		VinylDescription="Killing a zed restores 3 health."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentInfoClass=class'VinylAugmentVampire'
	End Object
	BerserkerVinylList(0)=TurboVinyl'Berserker0'

	Begin Object Name=Commando0 Class=TurboVinylBasic
		VinylName="Tactical Reload"
		VinylDescription="Increases reload rate by 3% to a maximum of 30% for each zed killed. Resets after 10 seconds of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.3f)
		AugmentInfoClass=class'VinylAugmentTacticalReload'
		OnActivateVinyl=ActivateBasic
	End Object
	CommandoVinylList(0)=TurboVinylBasic'Commando0'

	Begin Object Name=Demolitions0 Class=TurboVinylBasic
		VinylName="Siren Resistance"
		VinylDescription="Reduces damage taken from Siren screams by 50% and increases max ammo by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentList(0)=(Type=DamageReceivedSiren,Multiplier=0.5f)
		AugmentList(1)=(Type=MaxAmmo,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	DemolitionsVinylList(0)=TurboVinylBasic'Demolitions0'

	Begin Object Name=Medic0 Class=TurboVinylBasic
		VinylName="Resilience"
		VinylDescription="Reduces damage taken by up to 25% based on the percent of missing health."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.75f)
		AugmentInfoClass=class'VinylAugmentResilience'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'Medic0'

	Begin Object Name=Firebug0 Class=TurboVinylBasic
		VinylName="Heat Wave"
		VinylDescription="Increases fire rate by 15% and movement speed by 10% for 5 seconds after taking damage."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.15f)
		AugmentList(1)=(Type=MovementSpeed,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicDamaged'
		OnActivateVinyl=ActivateBasic
	End Object
	FirebugVinylList(0)=TurboVinylBasic'Firebug0'

	Begin Object Name=Sharpshooter0 Class=TurboVinylBasic
		VinylName="Dead Eye"
		VinylDescription="Reduces spread by 25% and increases headshot damage by 10% while stationary."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Sharpshooter"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.75f)
		AugmentList(1)=(Type=HeadshotDamage,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicStationary'
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(0)=TurboVinylBasic'Sharpshooter0'

	Begin Object Name=Support0 Class=TurboVinylBasic
		VinylName="Hoarder"
		VinylDescription="Increases carry weight by 2, max ammo by 15%, and magazine ammo by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.CLASSIC_Default"
		AugmentList(0)=(Type=CarryWeight,Multiplier=2.f)
		AugmentList(1)=(Type=MaxAmmo,Multiplier=1.15f)
		AugmentList(2)=(Type=MagazineAmmo,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(0)=TurboVinylBasic'Support0'
}
