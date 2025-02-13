//Killing Floor Turbo TurboPerkSelectListBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPerkSelectListBox extends SRPerkSelectListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'TurboPerkSelectList');
	Super(KFPerkSelectListBox).InitComponent(MyController,MyOwner);
}

defaultproperties
{
}
