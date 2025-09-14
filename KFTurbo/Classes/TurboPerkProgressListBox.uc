//Killing Floor Turbo TurboPerkProgressListBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPerkProgressListBox extends SRPerkProgressListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'TurboPerkProgressList');
	Super(KFPerkProgressListBox).InitComponent(MyController,MyOwner);
}