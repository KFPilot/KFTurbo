//Killing Floor Turbo TurboMapVoteInteraction
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMapVoteInteraction extends Interaction;

function NotifyLevelChange()
{
	local int i;
	GUIController(ViewportOwner.GUIController).MapVotingMenu = "KFGUI.KFMapVotingPage";
	GUIController(ViewportOwner.GUIController).ResetFocus();
	GUIController(ViewportOwner.GUIController).FocusedControl = None;

	for (i = (ViewportOwner.LocalInteractions.Length - 1); i>=0; --i)
    {
		if (ViewportOwner.LocalInteractions[i] == Self)
        {
			ViewportOwner.LocalInteractions.Remove(i, 1);
        }
    }
}

static final function AddVotingReplacement(PlayerController PC)
{
	local int i;
	local TurboMapVoteInteraction C;

	for (i = (PC.Player.LocalInteractions.Length-1); i >= 0; --i)
    {
		if (PC.Player.LocalInteractions[i].Class == default.Class)
        {
			return;
        }
    }

	C = new(None) class'TurboMapVoteInteraction';
	C.ViewportOwner = PC.Player;
	C.Master = PC.Player.InteractionMaster;
	i = PC.Player.LocalInteractions.Length;
	PC.Player.LocalInteractions.Length = i + 1;
	PC.Player.LocalInteractions[i] = C;
	C.Initialize();
	GUIController(PC.Player.GUIController).MapVotingMenu = string(class'TurboMapVotingPage');
}

defaultproperties
{
}
