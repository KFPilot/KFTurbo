//Killing Floor Turbo TurboCardInteraction
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardInteraction extends Engine.Interaction
	config(KFTurboCardGame);

//If true, when the scoreboard is not visible the cards on the side bar will not be visible.
var globalconfig bool bReduceCardVisibility;
var localized string ReduceCardVisibilityCaption, ReduceCardVisibilityHint;

var bool bShiftIsPressed;

static final function CardGamePlayerReplicationInfo FindCGPRI(PlayerController PlayerController)
{
	return class'CardGamePlayerReplicationInfo'.static.GetCardGameLRI(PlayerController.PlayerReplicationInfo);
}

simulated function InitializeInteraction()
{
	local TurboPlayerController PlayerController;
	local TurboOptionObject ExtraOptionConfig;
	local TurboCardOverlay TurboCardOverlay;

	ExtraOptionConfig = new(Self)class'TurboOptionObject';
	ExtraOptionConfig.GenerateOptions=GenerateCardOptions;

	PlayerController = TurboPlayerController(ViewportOwner.Actor);
	PlayerController.AddExtraOptionConfig(ExtraOptionConfig);

	TurboCardOverlay = class'TurboCardOverlay'.static.FindCardOverlay(ViewportOwner.Actor);
	if (bReduceCardVisibility && TurboCardOverlay != None)
	{
		TurboCardOverlay.bReduceCardVisibility = bReduceCardVisibility;
	}
}

simulated function GenerateCardOptions(TurboTab_TurboSettings SettingsTab, int TabOrder)
{
	local moCheckBox CheckBox;
	Checkbox = moCheckBox(SettingsTab.AddComponent(string(class'moCheckBox')));
	Checkbox.SetCaption(ReduceCardVisibilityCaption);
	Checkbox.SetHint(ReduceCardVisibilityHint);
	Checkbox.Checked(bReduceCardVisibility);
	Checkbox.OnCreateComponent=Checkbox.InternalOnCreateComponent;
	Checkbox.OnChange=OnReduceCardVisibilityOptionChanged;
	Checkbox.TabOrder = TabOrder;
    SettingsTab.MiddleSection.ManageComponent(Checkbox);
}

static final function bool SendVoteKeyPressEvent(PlayerController PlayerController, Interactions.EInputKey Key)
{
	local CardGamePlayerReplicationInfo CGPRI;

	CGPRI = FindCGPRI(PlayerController);

	if (CGPRI == None)
	{
		return false;
	}

	return CGPRI.ProcessVoteKeyPressEvent(Key);
}

simulated function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (Action == IST_Press)
	{
		if (Key == IK_MouseWheelUp || Key == IK_MouseWheelDown)
		{
			return class'TurboCardOverlay'.static.FindCardOverlay(ViewportOwner.Actor).ReceivedKeyEvent(Key, Action);
		}

		if (Key == IK_Shift)
		{
			class'TurboCardOverlay'.static.FindCardOverlay(ViewportOwner.Actor).ReceivedKeyEvent(Key, Action);
			bShiftIsPressed = true;
		}
		else if (bShiftIsPressed)
		{
			return SendVoteKeyPressEvent(ViewportOwner.Actor, Key);
		}
	}
	else if (Action == IST_Release)
	{
		if (Key == IK_Shift)
		{
			class'TurboCardOverlay'.static.FindCardOverlay(ViewportOwner.Actor).ReceivedKeyEvent(Key, Action);
			bShiftIsPressed = false;
		}
	}
	
	return false;
}

function OnReduceCardVisibilityOptionChanged(GUIComponent Sender)
{
	local TurboCardOverlay CardOverlay;

	if (bReduceCardVisibility == moCheckBox(Sender).IsChecked())
	{
		return;
	}

	bReduceCardVisibility = moCheckBox(Sender).IsChecked();
	CardOverlay = class'TurboCardOverlay'.static.FindCardOverlay(ViewportOwner.Actor);

	if (CardOverlay != None)
	{
		CardOverlay.bReduceCardVisibility = bReduceCardVisibility;
	}

	SaveConfig();
}

static final function bool ShouldReduceCardVisibility(TurboPlayerController PlayerController)
{
	local int Index;

	for (Index = 0; Index < PlayerController.Player.LocalInteractions.Length; Index++)
	{
		if (TurboCardInteraction(PlayerController.Player.LocalInteractions[Index]) != None)
		{
			return TurboCardInteraction(PlayerController.Player.LocalInteractions[Index]).bReduceCardVisibility;
		}
	}

	return false;
}


defaultproperties
{
	ReduceCardVisibilityCaption = "Reduce Card Visibility"
	ReduceCardVisibilityHint = "Cards on the side of the screen will not be visible unless the scoreboard is visible."
}