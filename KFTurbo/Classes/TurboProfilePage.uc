//Killing Floor Turbo TurboProfilePage
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboProfilePage extends SRProfilePage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	t_Footer.b_Save.StyleName = class'TurboGUIStyleButton'.default.KeyName;
    
	Super.InitComponent(MyController, MyOwner);
}

defaultproperties
{
    Begin Object Class=TurboTab_Profile Name=Panel
        WinTop=0.010000
        WinLeft=0.010000
        WinWidth=0.980000
        WinHeight=0.960000
    End Object
    ProfilePanel=TurboTab_Profile'KFTurbo.TurboProfilePage.Panel'
}
