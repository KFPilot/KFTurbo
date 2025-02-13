//Killing Floor Turbo TurboTab_TurboSettings
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_TurboSettings extends SRTab_Base;

var automated GUISectionBackground LeftSection, RightSection, MiddleSection;
var automated GUIButton DesiredRankButton;
var automated moCheckbox MerchantReplacementCheckBox;
var automated moCheckbox ShiftToTradeCheckBox;
var automated moCheckbox F3ToVoteYesCheckBox;
var automated moCheckbox PipebombGroupCheckBox;
var automated moCheckbox UseBaseGameChatFontBox;
var automated moComboBox FontLocaleComboBox;
var Color PerkLabelTextColor;
var localized string TierOptionList[9];

var bool bHasInitialized;
var array< class<TurboVeterancyTypes> > VeterancyClassList;
var array< GUIComboBox > VeterancyTierComboBoxList;

var string LocaleOptionList[3]; //3 for now (ENG/JPN/CYR). KOR will be added eventually but need to figure out the character set.

function ShowPanel(bool bShow)
{
	Super.ShowPanel(bShow);

	if (!bShow)
	{
        return;
	}

    if (!bHasInitialized)
    {
        if (!IsVeterancyTierPreferenceReady())
        {
            DesiredRankButton.DisableMe();
            return;
        }
        
        DesiredRankButton.EnableMe();
        InitializePage();
        bHasInitialized = true;
        return;
    }

    UpdatePage();
}

function bool IsVeterancyTierPreferenceReady()
{
    local TurboPlayerController PlayerController;
	local ClientPerkRepLink CPRL;
	local TurboRepLink TRL;

    PlayerController = TurboPlayerController(PlayerOwner());

    if (PlayerController.TurboInteraction == None || !PlayerController.TurboInteraction.bHasInitializedPerkTierPreference)
    {
        return false;
    }

    CPRL = PlayerController.GetClientPerkRepLink();

    if (CPRL == None || !CPRL.bRepCompleted)
    {
        return false;
    }

    TRL = PlayerController.GetTurboRepLink();

    if (TRL == None)
    {
        return false;
    }
    
    return true;
}

function InitializePage()
{
    local TurboPlayerController PlayerController;
    local ClientPerkRepLink CPRL;
    local TurboRepLink TRL;
    local int Index, ComboIndex;
    local float GUITop;
    local GUILabel Label;
    local GUIComboBox ComboBox;

    PlayerController = TurboPlayerController(PlayerOwner());
    CPRL = PlayerController.GetClientPerkRepLink();
    TRL = PlayerController.GetTurboRepLink();

    VeterancyClassList.Length = CPRL.CachePerks.Length;
    VeterancyTierComboBoxList.Length = VeterancyClassList.Length;
    GUITop = LeftSection.WinTop + 0.03f;

    for (Index = 0; Index < VeterancyClassList.Length; Index++)
    {
        VeterancyClassList[Index] = class<TurboVeterancyTypes>(CPRL.CachePerks[Index].PerkClass);
        Label = GUILabel(AddComponent(string(class'GUILabel')));
        Label.Caption = VeterancyClassList[Index].default.VeterancyName;
        Label.bBoundToParent = true;
        Label.bScaleToParent = true;
        Label.TextColor = PerkLabelTextColor;
        Label.WinTop = GUITop;
        Label.WinLeft = 0.04f;
        Label.WinHeight = 0.04f;
        Label.WinWidth = 0.16f;
        GUITop += 0.04f;

        ComboBox = GUIComboBox(AddComponent(string(class'GUIComboBox')));
        VeterancyTierComboBoxList[Index] = ComboBox;
        ComboBox.bBoundToParent = true;
        ComboBox.bScaleToParent = true;
        ComboBox.WinTop = GUITop;
        ComboBox.WinLeft = 0.04f;
        ComboBox.WinHeight = 0.04f;
        ComboBox.WinWidth = 0.16f;
        GUITop += 0.06f;

        for (ComboIndex = 0; ComboIndex < ArrayCount(TierOptionList); ComboIndex++)
        {
            ComboBox.AddItem(TierOptionList[ComboIndex]);
        }

        ComboBox.SetIndex(TRL.GetVeterancyTierPreference(VeterancyClassList[Index]));
    }

    RightSection.ManageComponent(MerchantReplacementCheckBox);
    MerchantReplacementCheckBox.Checked(class'TurboInteraction'.static.UseMerchantReplacement(PlayerController));
    RightSection.ManageComponent(ShiftToTradeCheckBox);
    ShiftToTradeCheckBox.Checked(class'TurboInteraction'.static.IsShiftTradeEnabled(PlayerController));
    RightSection.ManageComponent(F3ToVoteYesCheckBox);
    F3ToVoteYesCheckBox.Checked(class'TurboInteraction'.static.IsF3VoteYesEnabled(PlayerController));
    RightSection.ManageComponent(PipebombGroupCheckBox);
    PipebombGroupCheckBox.Checked(class'TurboInteraction'.static.ShouldPipebombUseSpecialGroup(PlayerController));
    RightSection.ManageComponent(UseBaseGameChatFontBox);
    UseBaseGameChatFontBox.Checked(class'TurboInteraction'.static.ShouldUseBaseGameFontForChat(PlayerController));
    
    FontLocaleComboBox.bIgnoreChange = true;
    RightSection.ManageComponent(FontLocaleComboBox);
    FontLocaleComboBox.AddItem(LocaleOptionList[0]);
    FontLocaleComboBox.AddItem(LocaleOptionList[1]);
    FontLocaleComboBox.AddItem(LocaleOptionList[2]);
    FontLocaleComboBox.SetIndex(GetFontLocaleIndex(class'TurboInteraction'.static.GetFontLocale(PlayerController)));
    FontLocaleComboBox.bIgnoreChange = false;
    
    if (PlayerController.HasExtraOptions())
    {
        MiddleSection.bNoCaption = false;
        MiddleSection.bVisible = true;

        PlayerController.GenerateExtraOptions(Self, FontLocaleComboBox.TabOrder + 1);
    }
}

function UpdatePage()
{
    local TurboRepLink TRL;
    local int Index;

    TRL = TurboPlayerController(PlayerOwner()).GetTurboRepLink();
    for (Index = 0; Index < VeterancyClassList.Length; Index++)
    {
        VeterancyTierComboBoxList[Index].SetIndex(TRL.GetVeterancyTierPreference(VeterancyClassList[Index]));
    }
}

function bool ApplyDesiredRank(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;
    local int Index;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None)
    {
        return true;
    }

    for (Index = 0; Index < VeterancyClassList.Length; Index++)
    {
        TurboInteraction.SetVeterancyTierPreference(VeterancyClassList[Index], VeterancyTierComboBoxList[Index].GetIndex());
    }

    return true;
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

defaultproperties
{
    bHasInitialized = false

    PerkLabelTextColor=(R=255,G=255,B=255,A=255)

    TierOptionList(0)="0 (Red)"
    TierOptionList(1)="1 (Green)"
    TierOptionList(2)="2 (Blue)"
    TierOptionList(3)="3 (Pink)"
    TierOptionList(4)="4 (Purple)"
    TierOptionList(5)="5 (Orange)"
    TierOptionList(6)="6 (Gold)"
    TierOptionList(7)="7 (Platinum)"
    TierOptionList(8)="8 (Shining)"

    LocaleOptionList(0)="ENG"
    LocaleOptionList(1)="JPN"
    LocaleOptionList(2)="CYR"

    Begin Object Class=GUISectionBackground Name=BGLeftSection
        bFillClient=True
        Caption="Neon Weapon Tier Limit"
        WinTop=0.0125
        WinLeft=0.02
        WinWidth=0.3
        WinHeight=0.825
        OnPreDraw=BGLeftSection.InternalPreDraw
    End Object
    LeftSection=GUISectionBackground'BGLeftSection'

    Begin Object Class=GUISectionBackground Name=BGMiddleSection
        bFillClient=True
        bNoCaption=true
        bVisible=false
        Caption="Custom Game Settings"
        WinTop=0.0125
        WinLeft=0.35
        WinWidth=0.3
        WinHeight=0.825
        OnPreDraw=BGMiddleSection.InternalPreDraw
    End Object
    MiddleSection=GUISectionBackground'BGMiddleSection'

    Begin Object Class=GUISectionBackground Name=BGRightSection
        bFillClient=True
        Caption="Turbo Settings"
        WinTop=0.0125
        WinLeft=0.68
        WinWidth=0.3
        WinHeight=0.825
        OnPreDraw=BGRightSection.InternalPreDraw
    End Object
    RightSection=GUISectionBackground'BGRightSection'

    Begin Object Class=GUIButton Name=ApplyDesiredRankButton
        Caption="Apply"
        TabOrder=50
        WinTop=0.740000
        WinLeft=0.04
        WinWidth=0.100000
        WinHeight=0.050000
        OnClick=ApplyDesiredRank
        OnKeyEvent=ApplyDesiredRankButton.InternalOnKeyEvent
    End Object
    DesiredRankButton=GUIButton'ApplyDesiredRankButton'

    Begin Object Class=moCheckBox Name=MerchantReplacement
        Caption="Use Merchant"
        OnCreateComponent=MerchantReplacement.InternalOnCreateComponent
        Hint="Replaces default Trader with Merchant."
        TabOrder=51
        OnChange=TurboTab_TurboSettings.OnMerchantReplacementChanged
    End Object
    MerchantReplacementCheckBox=moCheckBox'MerchantReplacement'

    Begin Object Class=moCheckBox Name=ShiftTradeMenu
        Caption="Press Shift To Trade"
        OnCreateComponent=ShiftTradeMenu.InternalOnCreateComponent
        Hint="Open trader menu in KFTurbo+ and Test Mode by pressing Shift key."
        TabOrder=52
        OnChange=TurboTab_TurboSettings.OnShiftToTradeChanged
    End Object
    ShiftToTradeCheckBox=moCheckBox'ShiftTradeMenu'

    Begin Object Class=moCheckBox Name=F3ToVoteYes
        Caption="Press F3 To Vote Yes"
        OnCreateComponent=F3ToVoteYes.InternalOnCreateComponent
        Hint="Pressing F3 will vote yes."
        TabOrder=53
        OnChange=TurboTab_TurboSettings.OnF3ToVoteYesChanged
    End Object
    F3ToVoteYesCheckBox=moCheckBox'F3ToVoteYes'

    Begin Object Class=moCheckBox Name=PipebombGroupChange
        Caption="Move Pipebomb Special Group"
        OnCreateComponent=PipebombGroupChange.InternalOnCreateComponent
        Hint="Moves the Pipebomb to inventory group 5."
        TabOrder=54
        OnChange=TurboTab_TurboSettings.OnPipebombGroupChange
    End Object
    PipebombGroupCheckBox=moCheckBox'PipebombGroupChange'

    Begin Object Class=moCheckBox Name=UseBaseGameChatFont
        Caption="Use Base Game Font For Chat"
        OnCreateComponent=UseBaseGameChatFont.InternalOnCreateComponent
        Hint="Chat text will use the base game's font to help with readability in non-english locales."
        TabOrder=55
        OnChange=TurboTab_TurboSettings.OnUseBaseGameChatFontChange
    End Object
    UseBaseGameChatFontBox=moCheckBox'UseBaseGameChatFont'

    Begin Object Class=moComboBox Name=FontLocale
        Caption="Font Locale"
        OnCreateComponent=FontLocale.InternalOnCreateComponent
        Hint="Selects which locale font pack to use for UI."
        TabOrder=56
        OnChange=TurboTab_TurboSettings.OnFontLocaleChange
    End Object
    FontLocaleComboBox=moComboBox'FontLocale'
}
