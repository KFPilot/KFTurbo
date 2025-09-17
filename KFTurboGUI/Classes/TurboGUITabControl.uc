class TurboGUITabControl extends GUITabControl;

function GUITabPanel AddTab(string InCaption, string PanelClass, optional GUITabPanel ExistingPanel, optional string InHint, optional bool bForceActive)
{
    local GUITabPanel NewTabPanel;
    NewTabPanel = Super.AddTab(InCaption, PanelClass, ExistingPanel, InHint, bForceActive);

    if (NewTabPanel == None)
    {
        return None;
    }

    TabStack[TabStack.Length - 1].Style = Controller.GetStyle(class'TurboGUIStyleButton'.default.KeyName, NewTabPanel.FontScale);
    return NewTabPanel;
}

defaultproperties
{

}