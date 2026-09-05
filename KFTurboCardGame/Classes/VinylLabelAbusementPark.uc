//Killing Floor Turbo VinylLabelAbusementPark
//Common vinyls that roll a random buff from their pool at the start of every wave.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelAbusementPark extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Abusement Park"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Carousel Calliope"
		VinylDescription="Each wave, rolls increased damage, reload rate or movement speed."
		SkinNameList(1)="KFTurboCardGame.Label.ABUSEMENT_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.05f)
		AugmentList(1)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentList(2)=(Type=MovementSpeed,Multiplier=1.05f)
		AugmentInfoClass=class'VinylAugmentAbusementPark'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Tilt-a-Whirl Twist"
		VinylDescription="Each wave, rolls increased fire rate, reload rate or magazine ammo."
		SkinNameList(1)="KFTurboCardGame.Label.ABUSEMENT_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentList(1)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentList(2)=(Type=MagazineAmmo,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentAbusementPark'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Midway March"
		VinylDescription="Each wave, rolls reduced damage taken, increased max health or fire resistance."
		SkinNameList(1)="KFTurboCardGame.Label.ABUSEMENT_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.95f)
		AugmentList(1)=(Type=MaxHealth,Multiplier=1.05f)
		AugmentList(2)=(Type=DamageReceivedFire,Multiplier=0.85f)
		AugmentInfoClass=class'VinylAugmentAbusementPark'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Ferris Wheel Fanfare"
		VinylDescription="Each wave, rolls increased movement speed, acceleration or magazine ammo."
		SkinNameList(1)="KFTurboCardGame.Label.ABUSEMENT_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.1f)
		AugmentList(1)=(Type=MovementAccel,Multiplier=1.1f)
		AugmentList(2)=(Type=MagazineAmmo,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentAbusementPark'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Big Top Bop"
		VinylDescription="Each wave, rolls two of increased fire rate, reload rate or movement speed."
		SkinNameList(1)="KFTurboCardGame.Label.ABUSEMENT_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.05f)
		AugmentList(1)=(Type=ReloadRate,Multiplier=1.05f)
		AugmentList(2)=(Type=MovementSpeed,Multiplier=1.05f)
		AugmentInfoClass=class'VinylAugmentAbusementParkDouble'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'
}
