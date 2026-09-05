//Killing Floor Turbo VinylLabelHellride
//Common vinyls that provide buffs while moving, plus fire resistance.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelHellride extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Hellride"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Ghost Train Gallop"
		VinylDescription="Increases movement speed by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.HELLRIDE_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Minecart Mazurka"
		VinylDescription="Increases fire rate by 10% while moving."
		SkinNameList(1)="KFTurboCardGame.Label.HELLRIDE_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicMoving'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Coaster Cancan"
		VinylDescription="Increases reload rate by 10% while moving."
		SkinNameList(1)="KFTurboCardGame.Label.HELLRIDE_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentBasicMoving'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Brimstone Boogie"
		VinylDescription="Reduces fire damage taken by 15%."
		SkinNameList(1)="KFTurboCardGame.Label.HELLRIDE_Default"
		AugmentList(0)=(Type=DamageReceivedFire,Multiplier=0.85f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Lava Lake Lullaby"
		VinylDescription="Reduces damage taken by 10% while moving."
		SkinNameList(1)="KFTurboCardGame.Label.HELLRIDE_Default"
		AugmentList(0)=(Type=DamageReceived,Multiplier=0.9f)
		AugmentInfoClass=class'VinylAugmentBasicMoving'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'
}
