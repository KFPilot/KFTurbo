//Killing Floor Turbo VinylLabelAdvancedGenetics
//Uncommon vinyls that provide odd, perk-specific, buffs with a matching drawback.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelAdvancedGenetics extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Advanced Genetics"
	LabelRarity=Uncommon

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Gene Therapy Gavotte"
		VinylDescription="Regenerates 2 health per second for 5 seconds after being healed by a teammate, but reduces max health by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=MaxHealth,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentRegenerationHealed'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Berserker0 Class=TurboVinylBasic
		VinylName="Adrenal Allemande"
		VinylDescription="Increases movement speed by 15% for 5 seconds after a melee kill, but reduces it by 5% otherwise."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.15f)
		BaseMultiplier=0.95f
		AugmentInfoClass=class'VinylAugmentFoundryMelee'
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(0)=TurboVinylBasic'Berserker0'

	Begin Object Name=Berserker1 Class=TurboVinylBasic
		VinylName="Thick Skin Tango"
		VinylDescription="Reduces damage taken by up to 15% with 5 zeds within 5 meters, but increases it by 10% with none nearby."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.85f)
		BaseMultiplier=1.1f
		AugmentInfoClass=class'VinylAugmentNearbyMonsters'
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(1)=TurboVinylBasic'Berserker1'

	Begin Object Name=Berserker2 Class=TurboVinylBasic
		VinylName="Scar Tissue Sarabande"
		VinylDescription="Regenerates 1 health per second after 5 seconds without taking damage, but increases damage taken by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentRegenerationUndamaged'
		OnActivateVinyl=ActivateBasic
	End Object
	BerserkerVinylList(2)=TurboVinylBasic'Berserker2'

	Begin Object Name=Commando0 Class=TurboVinylBasic
		VinylName="Last Round Lament"
		VinylDescription="Increases damage by up to 20% as the magazine empties, but reduces it by 10% when full."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.2f)
		BaseMultiplier=0.9f
		AugmentInfoClass=class'VinylAugmentLastRound'
		OnActivateVinyl=ActivateBasic
	End Object
	CommandoVinylList(0)=TurboVinylBasic'Commando0'

	Begin Object Name=Commando1 Class=TurboVinylBasic
		VinylName="Predator Gene Polka"
		VinylDescription="Increases damage dealt to Stalkers and Crawlers by 25%, but reduces damage dealt to other zeds by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.25f)
		BaseMultiplier=0.9f
		AugmentInfoClass=class'VinylAugmentMonsterDamageStealth'
		OnActivateVinyl=ActivateBasic
	End Object
	CommandoVinylList(1)=TurboVinylBasic'Commando1'

	Begin Object Name=Demolitions0 Class=TurboVinylBasic
		VinylName="Shrapnel Shuffle"
		VinylDescription="Reduces explosive damage taken by 30%, but reduces damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=DamageReceivedExplosive,Multiplier=0.7f)
		AugmentList(1)=(Type=Damage,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	DemolitionsVinylList(0)=TurboVinylBasic'Demolitions0'

	Begin Object Name=Demolitions1 Class=TurboVinylBasic
		VinylName="Chain Reaction Charleston"
		VinylDescription="Each zed killed increases damage by 5% to a maximum 20% but starts at a 5% reduction. Resets after 1 second of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.2f)
		BaseMultiplier=0.95f
		AugmentInfoClass=class'VinylAugmentFoundryChain'
		OnActivateVinyl=ActivateBasic
	End Object
	DemolitionsVinylList(1)=TurboVinylBasic'Demolitions1'

	Begin Object Name=FieldMedic0 Class=TurboVinylBasic
		VinylName="Symbiosis Serenade"
		VinylDescription="Healing a teammate also heals you for 20% of the amount, but reduces heal potency by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=HealPotency,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentSymbiosis'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(0)=TurboVinylBasic'FieldMedic0'

	Begin Object Name=FieldMedic1 Class=TurboVinylBasic
		VinylName="Antibody Aria"
		VinylDescription="Reduces damage taken by 10% for 5 seconds after healing a teammate, but increases it by 5% otherwise."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.9f)
		BaseMultiplier=1.05f
		AugmentInfoClass=class'VinylAugmentBasicHealer'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(1)=TurboVinylBasic'FieldMedic1'

	Begin Object Name=FieldMedic2 Class=TurboVinylBasic
		VinylName="Mitosis Minuet"
		VinylDescription="Increases syringe recharge by 30% while below 50% health, but reduces it by 15% otherwise."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=HealRecharge,Multiplier=1.3f)
		BaseMultiplier=0.85f
		AugmentInfoClass=class'VinylAugmentBasicCritical'
		OnActivateVinyl=ActivateBasic
	End Object
	FieldMedicVinylList(2)=TurboVinylBasic'FieldMedic2'

	Begin Object Name=Firebug0 Class=TurboVinylBasic
		VinylName="Pyrophoric Pavane"
		VinylDescription="Increases damage dealt to burning zeds by 15%, but reduces damage dealt to other zeds by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.15f)
		BaseMultiplier=0.9f
		AugmentInfoClass=class'VinylAugmentMonsterDamageBurning'
		OnActivateVinyl=ActivateBasic
	End Object
	FirebugVinylList(0)=TurboVinylBasic'Firebug0'

	Begin Object Name=Firebug1 Class=TurboVinylBasic
		VinylName="Spontaneous Combustion Swing"
		VinylDescription="Each zed killed with fire increases fire rate by 4%, from 5% reduced to a maximum of 15% increased. Resets after 5 seconds of not scoring a fire kill."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.15f)
		BaseMultiplier=0.95f
		AugmentInfoClass=class'VinylAugmentFoundryBurning'
		OnActivateVinyl=ActivateBasic
	End Object
	FirebugVinylList(1)=TurboVinylBasic'Firebug1'

	Begin Object Name=Sharpshooter0 Class=TurboVinylBasic
		VinylName="Steady Hands Sarabande"
		VinylDescription="Reduces spread by up to 30% over 3 seconds of standing still, but increases it by 15% while moving."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.7f)
		BaseMultiplier=1.15f
		AugmentInfoClass=class'VinylAugmentBasicStationaryRamp'
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(0)=TurboVinylBasic'Sharpshooter0'

	Begin Object Name=Sharpshooter1 Class=TurboVinylBasic
		VinylName="First Blood Fugue"
		VinylDescription="Increases damage dealt to zeds at full health by 15%, but reduces damage dealt to injured zeds by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.15f)
		BaseMultiplier=0.9f
		AugmentInfoClass=class'VinylAugmentMonsterDamageUnharmed'
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(1)=TurboVinylBasic'Sharpshooter1'

	Begin Object Name=Sharpshooter2 Class=TurboVinylBasic
		VinylName="Tunnel Vision Tarantella"
		VinylDescription="Increases headshot damage by up to 15% when zeds are far away, but reduces it by 10% when one is close."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.15f)
		BaseMultiplier=0.9f
		AugmentInfoClass=class'VinylAugmentNearestMonster'
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(2)=TurboVinylBasic'Sharpshooter2'

	Begin Object Name=Support0 Class=TurboVinylBasic
		VinylName="Point Blank Paso Doble"
		VinylDescription="Increases damage by up to 20% at point blank range, but reduces it by 10% at a distance."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.2f)
		BaseMultiplier=0.9f
		AugmentInfoClass=class'VinylAugmentPointBlank'
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(0)=TurboVinylBasic'Support0'

	Begin Object Name=Support1 Class=TurboVinylBasic
		VinylName="Specimen Samba"
		VinylDescription="Increases damage dealt to Scrakes and Fleshpounds by 12%, but reduces damage dealt to other zeds by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.12f)
		BaseMultiplier=0.9f
		AugmentInfoClass=class'VinylAugmentMonsterDamageLarge'
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(1)=TurboVinylBasic'Support1'

	Begin Object Name=Support2 Class=TurboVinylBasic
		VinylName="Crowd Control Cumbia"
		VinylDescription="Increases weapon bullet penetration by up to 25% with 5 zeds within 5 meters, but reduces it by 15% with none nearby."
		SkinNameList(1)="KFTurboCardGame.Label.ADVGEN_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.25f)
		BaseMultiplier=0.85f
		AugmentInfoClass=class'VinylAugmentNearbyMonsters'
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(2)=TurboVinylBasic'Support2'
}
