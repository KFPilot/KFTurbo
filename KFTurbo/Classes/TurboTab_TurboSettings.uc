//Killing Floor Turbo TurboTab_TurboSettings
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_TurboSettings extends SRTab_Base;

var automated GUISectionBackground LeftSection, RightSection, MiddleSection;
var automated moCheckbox MerchantReplacementCheckBox;
var automated moCheckbox ShiftToTradeCheckBox;
var automated moCheckbox F3ToVoteYesCheckBox;
var automated moCheckbox PipebombGroupCheckBox;
var automated moCheckbox UseBaseGameChatFontBox;
var automated moComboBox FontLocaleComboBox;
var automated moButton NeonWeaponConfigureButton;

var string LocaleOptionList[3]; //3 for now (ENG/JPN/CYR). KOR will be added eventually but need to figure out the character set.

//Returns the container responsible for holding custom options.
function GUISectionBackground GetCustomOptionContainer()
{
    return RightSection;
}

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if (!bShow)
	{
        return;
	}

    UpdatePage();
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local TurboPlayerController PlayerController;
    Super.InitComponent(MyController, MyOwner);
    PlayerController = TurboPlayerController(PlayerOwner());

    LeftSection.ManageComponent(MerchantReplacementCheckBox);
    MerchantReplacementCheckBox.Checked(class'TurboInteraction'.static.UseMerchantReplacement(PlayerController));
    LeftSection.ManageComponent(ShiftToTradeCheckBox);
    ShiftToTradeCheckBox.Checked(class'TurboInteraction'.static.IsShiftTradeEnabled(PlayerController));
    LeftSection.ManageComponent(F3ToVoteYesCheckBox);
    F3ToVoteYesCheckBox.Checked(class'TurboInteraction'.static.IsF3VoteYesEnabled(PlayerController));
    LeftSection.ManageComponent(PipebombGroupCheckBox);
    PipebombGroupCheckBox.Checked(class'TurboInteraction'.static.ShouldPipebombUseSpecialGroup(PlayerController));
    LeftSection.ManageComponent(UseBaseGameChatFontBox);
    UseBaseGameChatFontBox.Checked(class'TurboInteraction'.static.ShouldUseBaseGameFontForChat(PlayerController));
    
    FontLocaleComboBox.bIgnoreChange = true;
    LeftSection.ManageComponent(FontLocaleComboBox);
    FontLocaleComboBox.AddItem(LocaleOptionList[0]);
    FontLocaleComboBox.AddItem(LocaleOptionList[1]);
    FontLocaleComboBox.AddItem(LocaleOptionList[2]);
    FontLocaleComboBox.SetIndex(GetFontLocaleIndex(class'TurboInteraction'.static.GetFontLocale(PlayerController)));
    FontLocaleComboBox.bIgnoreChange = false;

    MiddleSection.ManageComponent(NeonWeaponConfigureButton);
    
    if (PlayerController.HasExtraOptions())
    {
        GetCustomOptionContainer().bNoCaption = false;
        GetCustomOptionContainer().SetVisibility(true);

        PlayerController.GenerateExtraOptions(Self, NeonWeaponConfigureButton.TabOrder + 1);
    }
}

function UpdatePage()
{
    local TurboPlayerController PlayerController;
    PlayerController = TurboPlayerController(PlayerOwner());
    MerchantReplacementCheckBox.Checked(class'TurboInteraction'.static.UseMerchantReplacement(PlayerController));
    ShiftToTradeCheckBox.Checked(class'TurboInteraction'.static.IsShiftTradeEnabled(PlayerController));
    F3ToVoteYesCheckBox.Checked(class'TurboInteraction'.static.IsF3VoteYesEnabled(PlayerController));
    PipebombGroupCheckBox.Checked(class'TurboInteraction'.static.ShouldPipebombUseSpecialGroup(PlayerController));
    UseBaseGameChatFontBox.Checked(class'TurboInteraction'.static.ShouldUseBaseGameFontForChat(PlayerController));
    FontLocaleComboBox.SetIndex(GetFontLocaleIndex(class'TurboInteraction'.static.GetFontLocale(PlayerController)));

    if (class'TurboGUINeonWeaponSkins'.static.IsVeterancyTierPreferenceReady(PlayerController))
    {
        NeonWeaponConfigureButton.MyButton.EnableMe();
    }
    else
    {
        NeonWeaponConfigureButton.MyButton.DisableMe();
    }
}

function OnMerchantReplacementChanged(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None)
    {
        return;
    }

    TurboInteraction.SetUseMerchantReplacement(MerchantReplacementCheckBox.IsChecked());
}

function OnShiftToTradeChanged(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None)
    {
        return;
    }

    TurboInteraction.SetShiftTradeEnabled(ShiftToTradeCheckBox.IsChecked());
}

function OnF3ToVoteYesChanged(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None)
    {
        return;
    }

    TurboInteraction.SetF3VoteYesEnabled(F3ToVoteYesCheckBox.IsChecked());
}

function OnPipebombGroupChange(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None || TurboInteraction.bPipebombUsesSpecialGroup == PipebombGroupCheckBox.IsChecked())
    {
        return;
    }

    TurboInteraction.SetPipebombUsesSpecialGroup(PipebombGroupCheckBox.IsChecked());
}

function OnUseBaseGameChatFontChange(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None || TurboInteraction.bUseBaseGameFontForChat == UseBaseGameChatFontBox.IsChecked())
    {
        return;
    }

    TurboInteraction.SetUseBaseGameFontForChat(UseBaseGameChatFontBox.IsChecked());
}

function OnFontLocaleChange(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None || TurboInteraction.FontLocale == LocaleOptionList[FontLocaleComboBox.GetIndex()])
    {
        return;
    }

    TurboInteraction.SetFontLocale(LocaleOptionList[FontLocaleComboBox.GetIndex()]);
}

function int GetFontLocaleIndex(string Locale)
{
    switch(Locale)
    {
        case "ENG":
            return 0;
        case "JPN":
            return 1;
        case "CYR":
            return 2;
    }

    return 0;
}

function OnConfigureNeonWeaponSkinsClicked(GUIComponent Sender)
{
	if (Controller.FindMenuByClass(Class'TurboGUINeonWeaponSkins') == None)
	{
		Controller.OpenMenu(string(Class'TurboGUINeonWeaponSkins'));
	}
}

defaultproperties
{
    LocaleOptionList(0)="ENG"
    LocaleOptionList(1)="JPN"
    LocaleOptionList(2)="CYR"

    Begin Object Class=TurboGUISectionBackground Name=BGLeftSection
        bFillClient=True
        bNoCaption=True
        Caption="Turbo Settings"
        WinTop=0.0125
        WinLeft=0.02
        WinWidth=0.32
        WinHeight=0.825
        OnPreDraw=BGLeftSection.InternalPreDraw
    End Object
    LeftSection=GUISectionBackground'BGLeftSection'

    Begin Object Class=TurboGUISectionBackground Name=BGMiddleSection
        bFillClient=True
        bNoCaption=True
        bVisible=True
        Caption="Turbo Settings"
        WinTop=0.0125
        WinLeft=0.34
        WinWidth=0.32
        WinHeight=0.825
        OnPreDraw=BGMiddleSection.InternalPreDraw
    End Object
    MiddleSection=GUISectionBackground'BGMiddleSection'

    Begin Object Class=TurboGUISectionBackground Name=BGRightSection
        bFillClient=True
        bNoCaption=True
        bVisible=False
        Caption="Custom Game Settings"
        WinTop=0.0125
        WinLeft=0.66
        WinWidth=0.32
        WinHeight=0.825
        OnPreDraw=BGRightSection.InternalPreDraw
    End Object
    RightSection=GUISectionBackground'BGRightSection'

    Begin Object Class=TurboOptionCheckBox Name=MerchantReplacement
        Caption="Use Merchant"
        OnCreateComponent=MerchantReplacement.InternalOnCreateComponent
        Hint="Replaces default Trader with Merchant."
        TabOrder=1
        OnChange=TurboTab_TurboSettings.OnMerchantReplacementChanged
    End Object
    MerchantReplacementCheckBox=moCheckbox'MerchantReplacement'

    Begin Object Class=TurboOptionCheckBox Name=ShiftTradeMenu
        Caption="Press Shift To Trade"
        OnCreateComponent=ShiftTradeMenu.InternalOnCreateComponent
        Hint="Open trader menu in KFTurbo+ and Test Mode by pressing Shift key."
        TabOrder=2
        OnChange=TurboTab_TurboSettings.OnShiftToTradeChanged
    End Object
    ShiftToTradeCheckBox=moCheckbox'ShiftTradeMenu'

    Begin Object Class=TurboOptionCheckBox Name=F3ToVoteYes
        Caption="Press F3 To Vote Yes"
        OnCreateComponent=F3ToVoteYes.InternalOnCreateComponent
        Hint="Pressing F3 will vote yes."
        TabOrder=3
        OnChange=TurboTab_TurboSettings.OnF3ToVoteYesChanged
    End Object
    F3ToVoteYesCheckBox=moCheckbox'F3ToVoteYes'

    Begin Object Class=TurboOptionCheckBox Name=PipebombGroupChange
        Caption="Move Pipebomb Special Group"
        OnCreateComponent=PipebombGroupChange.InternalOnCreateComponent
        Hint="Moves the Pipebomb to inventory group 5."
        TabOrder=4
        OnChange=TurboTab_TurboSettings.OnPipebombGroupChange
    End Object
    PipebombGroupCheckBox=moCheckbox'PipebombGroupChange'

    Begin Object Class=TurboOptionCheckBox Name=UseBaseGameChatFont
        Caption="Use Base Font For Chat"
        OnCreateComponent=UseBaseGameChatFont.InternalOnCreateComponent
        Hint="Chat text will use the base game's font to help with readability in non-english locales."
        TabOrder=5
        OnChange=TurboTab_TurboSettings.OnUseBaseGameChatFontChange
    End Object
    UseBaseGameChatFontBox=moCheckbox'UseBaseGameChatFont'

    Begin Object Class=TurboOptionComboBox Name=FontLocale
        Caption="Font Locale"
        OnCreateComponent=FontLocale.InternalOnCreateComponent
        Hint="Selects which locale font pack to use for UI."
        TabOrder=6
        OnChange=TurboTab_TurboSettings.OnFontLocaleChange
    End Object
    FontLocaleComboBox=moComboBox'FontLocale'

    Begin Object Class=TurboOptionButton Name=NeonWeaponSkinsButton
        Caption="Neon Weapons"
        ButtonCaption="Configure"
        TabOrder=11
        ComponentWidth=0.4
        OnChange=OnConfigureNeonWeaponSkinsClicked
    End Object
    NeonWeaponConfigureButton=moButton'NeonWeaponSkinsButton'
}
