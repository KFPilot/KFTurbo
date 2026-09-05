//Killing Floor Turbo VinylLabelSteamland
//Common vinyls that provide gadget flavored utility buffs.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class VinylLabelSteamland extends CardGameVinylLabel;

defaultproperties
{
	LabelName="Lockheart's Steamland"
	LabelRarity=Common

	Begin Object Name=Default0 Class=TurboVinylBasic
		VinylName="Carousel Canticle"
		VinylDescription="Increases magazine ammo by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.STEAMLAND_Default"
		AugmentList(0)=(Type=MagazineAmmo,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(0)=TurboVinylBasic'Default0'

	Begin Object Name=Default1 Class=TurboVinylBasic
		VinylName="Piston Parade"
		VinylDescription="Increases fire rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.STEAMLAND_Default"
		AugmentList(0)=(Type=FireRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(1)=TurboVinylBasic'Default1'

	Begin Object Name=Default2 Class=TurboVinylBasic
		VinylName="Boiler Walk Boogie-Woogie"
		VinylDescription="Increases reload rate by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.STEAMLAND_Default"
		AugmentList(0)=(Type=ReloadRate,Multiplier=1.05f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(2)=TurboVinylBasic'Default2'

	Begin Object Name=Default3 Class=TurboVinylBasic
		VinylName="Clockwork Courante"
		VinylDescription="Reduces spread by 5%."
		SkinNameList(1)="KFTurboCardGame.Label.STEAMLAND_Default"
		AugmentList(0)=(Type=SpreadRecoil,Multiplier=0.95f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(3)=TurboVinylBasic'Default3'

	Begin Object Name=Default4 Class=TurboVinylBasic
		VinylName="Airship Anthem"
		VinylDescription="Increases carry weight by 5."
		SkinNameList(1)="KFTurboCardGame.Label.STEAMLAND_Default"
		AugmentList(0)=(Type=CarryWeight,Multiplier=1.f)
		OnActivateVinyl=ActivateBasic
	End Object
	VinylObjectList(4)=TurboVinylBasic'Default4'
}
