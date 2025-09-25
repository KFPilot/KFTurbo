//Killing Floor Turbo TurboOptionComboBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboOptionComboBox extends moComboBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
}

defaultproperties
{
    LabelStyleName="TurboLabel"
    StandardHeight=0.04
    bNeverFocus=true
}