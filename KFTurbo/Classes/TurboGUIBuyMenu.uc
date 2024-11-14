class TurboGUIBuyMenu extends SRGUIBuyMenu;

function InitTabs()
{
	local SRKFTab_BuyMenu B;

	B = SRKFTab_BuyMenu(c_Tabs.AddTab(PanelCaption[0], string(class'TurboTab_BuyMenu'),, PanelHint[0]));
	c_Tabs.AddTab(PanelCaption[1], string(class'TurboTab_Perks'),, PanelHint[1]);

	SRBuyMenuFilter(BuyMenuFilter).SaleListBox = SRBuyMenuSaleList(B.SaleSelect.List);
}

event Opened(GUIComponent Sender)
{
	Super.Opened(Sender);

	NotifyPlayerOpenedTrader();
}

function NotifyPlayerOpenedTrader()
{
    if (TurboPlayerController(PlayerOwner()) != None)
	{
        TurboPlayerController(PlayerOwner()).ServerNotifyShoppingState(true);
    }
}

function InternalOnClose(optional bool bCanceled)
{
    Super.OnClose(bCanceled);

	NotifyPlayerClosedTrader();
}

function KFBuyMenuClosed(optional bool bCanceled)
{
	Super.OnClose(bCanceled);

	NotifyPlayerClosedTrader();
}

function NotifyPlayerClosedTrader()
{
    if (TurboPlayerController(PlayerOwner()) != None)
	{
        TurboPlayerController(PlayerOwner()).ServerNotifyShoppingState(false);
    }
}

defaultproperties
{
	Begin Object Class=TurboGUIQuickPerkSelect Name=TurboQuickSelect
		WinTop=0.011906
		WinLeft=0.008008
		WinWidth=0.316601
		WinHeight=0.082460
		OnDraw=TurboQuickSelect.MyOnDraw
	End Object
	QuickPerkSelect=TurboGUIQuickPerkSelect'TurboQuickSelect'
}
