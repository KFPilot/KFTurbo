//Killing Floor Turbo VinylLabelIceCave
//Common vinyls that scale with how much of the alive squad is nearby.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelIceCave extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Ice Cave"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Glacier Gavotte"
		VinylDescription="Reduces spread by up to 10% based on how much of the squad is nearby."
		SkinNameList(1)="KFTurboCardGame.Label.ICECAVE_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentIceCave'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Permafrost Prelude"
		VinylDescription="Reduces damage taken by up to 10% based on how much of the squad is nearby."
		SkinNameList(1)="KFTurboCardGame.Label.ICECAVE_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentIceCave'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Crevasse Chorale"
		VinylDescription="Increases headshot damage by up to 10% based on how much of the squad is nearby."
		SkinNameList(1)="KFTurboCardGame.Label.ICECAVE_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentIceCave'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Stalactite Stomp"
		VinylDescription="Increases fire rate by up to 10% based on how much of the squad is nearby."
		SkinNameList(1)="KFTurboCardGame.Label.ICECAVE_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentIceCave'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Sharpshooter0 Class=TurboVinylBasic
		VinylName="Icicle Interlude"
		VinylDescription="Increases weapon bullet penetration by up to 20% based on how much of the squad is nearby."
		SkinNameList(1)="KFTurboCardGame.Label.ICECAVE_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.2f)
		AugmentInfoClass=class'VinylAugmentIceCave'
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(0)=TurboVinylBasic'Sharpshooter0'
}
