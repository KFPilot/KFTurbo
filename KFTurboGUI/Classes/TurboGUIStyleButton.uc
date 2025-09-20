//Killing Floor Turbo TurboGUIStyleButton
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIStyleButton extends TurboGUIStyle;

defaultproperties
{
	KeyName="TurboButton"
	Images(0)=Texture'KFTurboGUI.Menu.Button_D'
	Images(1)=Texture'KFTurboGUI.Menu.Button_D'
	Images(2)=Texture'KFTurboGUI.Menu.Button_D'
	Images(3)=Texture'KFTurboGUI.Menu.Button_D'
	Images(4)=Texture'KFTurboGUI.Menu.Button_D'

	ImgStyle(0)=ISTY_Stretched
	ImgStyle(1)=ISTY_Stretched
	ImgStyle(2)=ISTY_Stretched
	ImgStyle(3)=ISTY_Stretched
	ImgStyle(4)=ISTY_Stretched

	FontColors(0)=(R=225,G=225,B=225,A=255)
	FontColors(1)=(R=255,G=255,B=255,A=255)
	FontColors(2)=(R=255,G=255,B=255,A=255)
	FontColors(3)=(R=185,G=185,B=185,A=255)
	FontColors(4)=(R=80,G=80,B=80,A=255)

	//(Blurry, Watched, Focused, Pressed, Disabled)	
	ImgColors(0)=(R=40,G=40,B=40,A=255)
	ImgColors(1)=(R=65,G=65,B=65,A=255)
	ImgColors(2)=(R=65,G=65,B=65,A=255)
	ImgColors(3)=(R=30,G=30,B=30,A=255)
	ImgColors(4)=(R=20,G=20,B=20,A=255)
}