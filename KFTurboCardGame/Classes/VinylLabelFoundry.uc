//Killing Floor Turbo VinylLabelFoundry
//Common vinyls that provide buffs in response to killing a zed.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelFoundry extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Foundry"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Crucible Crescendo"
		VinylDescription="Increases damage by 1% to a maximum of 5% for each zed killed. Resets after 5 seconds of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.FOUNDRY_Default"
		AugmentList(0)=(Type=Damage,Multiplier=1.05f)
		AugmentInfoClass=class'VinylAugmentFoundry'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Smelter Swing"
		VinylDescription="Increases fire rate by 2% to a maximum of 10% for each zed killed. Resets after 5 seconds of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.FOUNDRY_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentFoundry'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Rolling Mill Rhapsody"
		VinylDescription="Increases reload rate by 2% to a maximum of 10% for each zed killed. Resets after 5 seconds of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.FOUNDRY_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.1f)
		AugmentInfoClass=class'VinylAugmentFoundry'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Slagheap Shuffle"
		VinylDescription="Increases movement speed by 1% to a maximum of 5% for each zed killed. Resets after 5 seconds of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.FOUNDRY_Default"
		AugmentList(0)=(Type=MovementSpeed,Multiplier=1.05f)
		AugmentInfoClass=class'VinylAugmentFoundry'
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Support0 Class=TurboVinylBasic
		VinylName="Ingot Interlude"
		VinylDescription="Increases weapon bullet penetration by 3% to a maximum of 15% for each zed killed. Resets after 5 seconds of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.FOUNDRY_Default"
		AugmentList(0)=(Type=Penetration,Multiplier=1.15f)
		AugmentInfoClass=class'VinylAugmentFoundry'
		OnActivateVinyl=ActivateBasic
	End Object
	SupportVinylList(0)=TurboVinylBasic'Support0'

	Begin Object Name=Firebug0 Class=TurboVinylBasic
		VinylName="Furnace Fugue"
		VinylDescription="Reduces fire damage taken by 3% to a maximum of 15% for each zed killed. Resets after 5 seconds of not scoring a kill."
		SkinNameList(1)="KFTurboCardGame.Label.FOUNDRY_Default"
		AugmentList(0)=(Type=DamageReceivedFire,Multiplier=0.85f)
		AugmentInfoClass=class'VinylAugmentFoundry'
		OnActivateVinyl=ActivateBasic
	End Object
	FirebugVinylList(0)=TurboVinylBasic'Firebug0'
}
