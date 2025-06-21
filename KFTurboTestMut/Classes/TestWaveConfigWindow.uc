class TestWaveConfigWindow extends FloatingWindow;

var automated GUISectionBackground Container;
var automated moComboBox WaveNumber, PlayerCount, PlayerHealth;
var automated GUIButton Apply;

var TestLaneWaveManager Manager;

function Update(TestLaneWaveManager NewManager)
{
    Manager = NewManager;
    WaveNumber.SetIndex(Manager.WaveNumber);
    PlayerCount.SetIndex(Manager.PlayerCount - 1);
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int Index;
	Super.Initcomponent(MyController, MyOwner);

    for (Index = 1; Index <= 7; Index++)
    {
        WaveNumber.AddItem(string(Index));
    }
    for (Index = 1; Index <= 6; Index++)
    {
        PlayerCount.AddItem(string(Index));
        PlayerHealth.AddItem(string(Index));
    }

    Container.ManageComponent(WaveNumber);
    Container.ManageComponent(PlayerCount);
    Container.ManageComponent(PlayerHealth);
    Container.ManageComponent(Apply);
}

function bool ApplySettings(GUIComponent Sender)
{
    local KFTTPlayerController TestPlayerController;
    TestPlayerController = KFTTPlayerController(PlayerOwner());

    if (TestPlayerController != None)
    {
        TestPlayerController.ServerApplyWaveControlSettings(Manager, WaveNumber.GetIndex(), PlayerCount.GetIndex() + 1, PlayerHealth.GetIndex() + 1);
    }

    return true;
}

function bool NoDraw(Canvas Canvas)
{
    return true;
}

defaultproperties
{
    WindowName="Turbo+ Wave Simulator Settings"
    bResizeWidthAllowed=False
    bResizeHeightAllowed=False
    bMoveAllowed=false
    DefaultTop=0.35
    DefaultLeft=0.35
    DefaultWidth=0.3
    DefaultHeight=0.3
    bRequire640x480=True
    bPersistent=True
    bAllowedAsLast=True
    WinTop=0.35
    WinLeft=0.35
    WinWidth=0.3
    WinHeight=0.3

    Begin Object Class=GUIHeader Name=WaveConfigTitleBar
        bUseTextHeight=True
        WinHeight=0.1
        RenderWeight=0.1
        bBoundToParent=True
        bScaleToParent=True
        bAcceptsInput=True
        bNeverFocus=False
        ScalingType=SCALE_X
        OnMousePressed=TestWaveConfigWindow.FloatingMousePressed
        OnMouseRelease=TestWaveConfigWindow.FloatingMouseRelease
    End Object
    t_WindowTitle=GUIHeader'WaveConfigTitleBar'

    Begin Object Class=GUISectionBackground Name=WaveConfigContainer
        ImageColor=(R=0,G=0,B=0,A=0)
        WinTop=0.05
        WinHeight=0.950000
        bBoundToParent=True
        bScaleToParent=True
        OnPreDraw=WaveConfigContainer.InternalPreDraw
        OnDraw=NoDraw
    End Object
    Container=GUISectionBackground'WaveConfigContainer'

    Begin Object Class=moComboBox Name=WaveNumberComboBox
        bReadOnly=True
        Caption="Wave Number"
        OnCreateComponent=WaveNumberComboBox.InternalOnCreateComponent
        Hint="Select the wave number from Turbo+ you'd like to simulate."
        TabOrder=1
    End Object
    WaveNumber=moComboBox'WaveNumberComboBox'

    Begin Object Class=moComboBox Name=PlayerCountComboBox
        bReadOnly=True
        Caption="Player Count"
        OnCreateComponent=PlayerCountComboBox.InternalOnCreateComponent
        Hint="Select the player count you'd like to simulate."
        TabOrder=2
    End Object
    PlayerCount=moComboBox'PlayerCountComboBox'

    Begin Object Class=moComboBox Name=PlayerHealthComboBox
        bReadOnly=True
        Caption="Player Health"
        OnCreateComponent=PlayerHealthComboBox.InternalOnCreateComponent
        Hint="Select the player health you'd like to simulate."
        TabOrder=3
    End Object
    PlayerHealth=moComboBox'PlayerHealthComboBox'

    Begin Object Class=GUIButton Name=ApplyButton
        WinHeight=0.2
        Caption="Apply"
        TabOrder=4
        OnClick=TestWaveConfigWindow.ApplySettings
        OnKeyEvent=ApplyButton.InternalOnKeyEvent
    End Object
    Apply=GUIButton'ApplyButton'
}
