//Killing Floor Turbo TurboGUINeonWeaponSkins
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUINeonWeaponSkins extends LargeWindow;

var automated GUILabel Label;
var automated GUISectionBackground Container;
var automated GUIButton Apply;

var array< class<TurboVeterancyTypes> > VeterancyClassList;
var array< moComboBox > VeterancyTierComboBoxList;
var localized string TierOptionList[9];

static function bool IsVeterancyTierPreferenceReady(TurboPlayerController PlayerController)
{
	local ClientPerkRepLink CPRL;
	local TurboRepLink TRL;

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

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    if (!IsVeterancyTierPreferenceReady(TurboPlayerController(PlayerOwner())))
    {
        return;
    }

    InitializeTierPreferenceSelectors(MyController, MyOwner);
}

function InitializeTierPreferenceSelectors(GUIController MyController, GUIComponent MyOwner)
{
    local TurboPlayerController PlayerController;
    local ClientPerkRepLink CPRL;
    local TurboRepLink TRL;
    local int Index, ComboIndex;
    local moComboBox ComboBox;

    PlayerController = TurboPlayerController(PlayerOwner());
    CPRL = PlayerController.GetClientPerkRepLink();
    TRL = PlayerController.GetTurboRepLink();

    VeterancyClassList.Length = CPRL.CachePerks.Length;
    VeterancyTierComboBoxList.Length = VeterancyClassList.Length;
    
    Container.ManageComponent(Label);
    Container.ManageComponent(AddComponent(string(class'GUIListSpacer')));

    for (Index = 0; Index < VeterancyClassList.Length; Index++)
    {
        VeterancyClassList[Index] = class<TurboVeterancyTypes>(CPRL.CachePerks[Index].PerkClass);
        
        ComboBox = moComboBox(AddComponent(string(class'TurboOptionComboBox')));
        VeterancyTierComboBoxList[Index] = ComboBox;

        ComboBox.Caption = VeterancyClassList[Index].default.VeterancyName;
        ComboBox.MyLabel.Caption = ComboBox.Caption;
        ComboBox.MyComboBox.MaxVisibleItems = 10;
        ComboBox.bBoundToParent = true;
        ComboBox.bScaleToParent = true;

        for (ComboIndex = 0; ComboIndex < ArrayCount(TierOptionList); ComboIndex++)
        {
            ComboBox.AddItem(Repl(TierOptionList[ComboIndex], "%c", MakeColorCode(class'TurboVeterancyTypes'.static.GetPerkTierColor(ComboIndex))));
        }

        ComboBox.SetIndex(TRL.GetVeterancyTierPreference(VeterancyClassList[Index]));
        Container.ManageComponent(ComboBox);
    }

    Container.ManageComponent(Apply);
}

function Opened(GUIComponent Sender)
{
    Super.Opened(Sender);

    UpdatePage();
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

function bool NoDraw(Canvas Canvas)
{
    return true;
}

function bool ApplySettings(GUIComponent Sender)
{
	local TurboInteraction TurboInteraction;
    local int Index;

    TurboInteraction = TurboPlayerController(PlayerOwner()).TurboInteraction;

    if (TurboInteraction == None)
    {
        Controller.CloseMenu();
        return false;
    }

    for (Index = 0; Index < VeterancyClassList.Length; Index++)
    {
        TurboInteraction.SetVeterancyTierPreference(VeterancyClassList[Index], VeterancyTierComboBoxList[Index].GetIndex(), true);
    }

    TurboInteraction.SaveConfig();
    Controller.CloseMenu();
    return true;
}

defaultproperties
{
    WindowName="Turbo Neon Weapon Settings"

    bResizeWidthAllowed=False
    bResizeHeightAllowed=False
    bMoveAllowed=false
    DefaultTop=0.2
    DefaultLeft=0.3
    DefaultWidth=0.4
    DefaultHeight=0.6
    bRequire640x480=False
    bAcceptsInput=False
    WinTop=0.2
    WinLeft=0.3
    WinWidth=0.4
    WinHeight=0.6

    TierOptionList(0)="%c0 (Red)"
    TierOptionList(1)="%c1 (Green)"
    TierOptionList(2)="%c2 (Blue)"
    TierOptionList(3)="%c3 (Pink)"
    TierOptionList(4)="%c4 (Purple)"
    TierOptionList(5)="%c5 (Orange)"
    TierOptionList(6)="%c6 (Gold)"
    TierOptionList(7)="%c7 (Platinum)"
    TierOptionList(8)="%c8 (Shining)"

    Begin Object Class=GUIHeader Name=NeonWeaponSkinsTitle
        bUseTextHeight=True
        WinHeight=0.1
        RenderWeight=0.1
        bBoundToParent=True
        bScaleToParent=True
        bAcceptsInput=True
        bNeverFocus=False
        ScalingType=SCALE_X
    End Object
    t_WindowTitle=GUIHeader'NeonWeaponSkinsTitle'

    Begin Object Class=GUISectionBackground Name=NeonWeaponSkinsContainer
        ImageColor=(R=0,G=0,B=0,A=0)
        WinTop=-0.075
        WinHeight=1.1f
        bBoundToParent=True
        bScaleToParent=True
        OnPreDraw=NeonWeaponSkinsContainer.InternalPreDraw
        OnDraw=NoDraw
    End Object
    Container=GUISectionBackground'NeonWeaponSkinsContainer'

    Begin Object Class=GUILabel Name=NeonWeaponSkinLabel
        StyleName="TurboLabel"
        Caption="Sets the tier limit used by neon weapons for each perk."
        TextAlign=TXTA_Center
    End Object
    Label=GUILabel'NeonWeaponSkinLabel'

    Begin Object Class=GUIButton Name=ApplyButton
        StyleName="TurboButton"
        WinHeight=0.2
        Caption="Apply"
        TabOrder=50
        OnClick=TurboGUINeonWeaponSkins.ApplySettings
        OnKeyEvent=ApplyButton.InternalOnKeyEvent
	    bNeverFocus=true
    End Object
    Apply=GUIButton'ApplyButton'
}
