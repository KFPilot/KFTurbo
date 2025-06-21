//Killing Floor Turbo TurboTab_Perks
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_Perks extends SRKFTab_Perks;

function bool OnSaveButtonClicked(GUIComponent Sender)
{
	local TurboPlayerController TurboPlayerController;

	TurboPlayerController = TurboPlayerController(PlayerOwner());

	if (lb_PerkSelect.GetIndex() >= 0 && TurboPlayerController != None && TurboPlayerController.GetClientPerkRepLink() != None)
	{
		TurboPlayerController.SelectVeterancy(TurboPlayerController.GetClientPerkRepLink().CachePerks[lb_PerkSelect.GetIndex()].PerkClass);
	}
	
	return true;
}

defaultproperties
{
     Begin Object Class=TurboPerkSelectListBox Name=PerkSelectList
         OnCreateComponent=PerkSelectList.InternalOnCreateComponent
         WinTop=0.091627
         WinLeft=0.029240
         WinWidth=0.437166
         WinHeight=0.742836
     End Object
     lb_PerkSelect=TurboPerkSelectListBox'KFTurbo.TurboTab_Perks.PerkSelectList'

}
