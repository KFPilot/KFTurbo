class TurboPlayerReadyBar extends KFPlayerReadyBar;

defaultproperties
{
	Begin Object Class=GUIImage Name=TurboPerkBG
		Image=Texture'KFTurboGUI.Perk.PerkBoxUnselected_D'
		ImageColor=(B=255,G=255,R=255,A=255)
		ImageStyle=ISTY_Stretched
		ImageRenderStyle=MSTY_Normal
		WinTop=0.f
		WinLeft=0.f
		WinWidth=0.f
		WinHeight=1.f
		RenderWeight=1.f
		bScaleToParent=true
		bBoundToParent=true
	End Object
	PerkBackground=GUIImage'TurboPerkBG'
	
	Begin Object Class=GUIImage Name=TurboPlayerBG
		Image=Texture'KFTurboGUI.Perk.PerkBackplateUnselected_D'
		ImageColor=(B=255,G=255,R=255,A=255)
		ImageStyle=ISTY_Stretched
		ImageRenderStyle=MSTY_Normal
		WinTop=0.025f
		WinLeft=-0.5f
		WinWidth=1.1f
		WinHeight=0.95f
		RenderWeight=0.1f
		bScaleToParent=true
		bBoundToParent=true
	End Object
	PlayerBackground=GUIImage'TurboPlayerBG'
}
