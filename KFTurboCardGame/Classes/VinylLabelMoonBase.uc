//Killing Floor Turbo VinylLabelMoonBase
//Common vinyls that provide mobility and precision buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelMoonBase extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Moon Base"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Low-G Lounge"
		VinylDescription="Increases movement speed by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.MOONBASE_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Airlock Aria"
		VinylDescription="Increases movement acceleration by 10%."
		SkinNameList(1)="KFTurboCardGame.Label.MOONBASE_Default"
		AugmentList(0)=(Type=MovementAccel,Multiplier=1.1f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Regolith Ragtime"
		VinylDescription="Reduces spread by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.MOONBASE_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Command Module Mambo"
		VinylDescription="Increases reload rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.MOONBASE_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Sharpshooter0 Class=TurboVinylBasic
		VinylName="Lunar Lab Lambada"
		VinylDescription="Increases headshot damage by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.MOONBASE_Default"
		AugmentList(0)=(Type=HeadshotDamage,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	SharpshooterVinylList(0)=TurboVinylBasic'Sharpshooter0'
}
