//Killing Floor Turbo TurboTab_BuyMenu
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_BuyMenu extends SRKFTab_BuyMenu;

function ShowPanel(bool bShow)
{
    local int Index, PistolIndex;
	local class<KFWeapon> BuyableWeaponClass;

    Super(UT2K4TabPanel).ShowPanel(bShow);

    bClosed = false;
	PistolIndex = InvSelect.List.MyBuyables.Length;

    for (Index = 0; Index < InvSelect.List.MyBuyables.Length; Index++)
    {
		if (InvSelect.List.MyBuyables[Index] == None)
		{
			continue;
		}

		BuyableWeaponClass = InvSelect.List.MyBuyables[Index].ItemWeaponClass;

        if (class<Single>(BuyableWeaponClass) != None || class<Dualies>(BuyableWeaponClass) != None)
        {
			PistolIndex = Index;
			break;
        }
    }

	if (PistolIndex < InvSelect.List.MyBuyables.Length)
	{
		TheBuyable = InvSelect.List.MyBuyables[PistolIndex];
		InvSelect.List.Index = PistolIndex;
	}

    if ( KFPlayerController(PlayerOwner()) != none )
    {
        KFPlayerController(PlayerOwner()).bDoTraderUpdate = true;
    }

    LastBuyable = TheBuyable;

    InvSelect.SetPosition(InvBG.WinLeft + 7.0 / float(Controller.ResX),
                          InvBG.WinTop + 55.0 / float(Controller.ResY),
                          InvBG.WinWidth - 15.0 / float(Controller.ResX),
                          InvBG.WinHeight - 45.0 / float(Controller.ResY),
                          true);

    SaleSelect.SetPosition(SaleBG.WinLeft + 7.0 / float(Controller.ResX),
                           SaleBG.WinTop + 55.0 / float(Controller.ResY),
                           SaleBG.WinWidth - 15.0 / float(Controller.ResX),
                           SaleBG.WinHeight - 63.0 / float(Controller.ResY),
                           true);
}

function bool InvDblClick(GUIComponent Sender)
{
	local GUIBuyable DoubleClickedBuyable;
	if (InvSelect.List.MouseOverXIndex != 0)
	{
		return false;
	}

	SaleSelect.List.Index = -1;

	DoubleClickedBuyable = InvSelect.GetSelectedBuyable();
	if (DoubleClickedBuyable != None)
	{
		TheBuyable = DoubleClickedBuyable;
	}

	GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;

	if (TheBuyable == None || !TheBuyable.bSellable)
	{
		return false;
	}

	DoSell();
	TheBuyable = None;
	OnAnychange();
	return true;
}

function DoBuy()
{
	if (KFPawn(PlayerOwner().Pawn) != none)
	{
		if (TurboGUIBuyable(TheBuyable) != None)
		{
			KFPawn(PlayerOwner().Pawn).ServerBuyWeapon(TurboGUIBuyable(TheBuyable).GetWeapon(), TheBuyable.ItemWeight);
		}
		else
		{
			KFPawn(PlayerOwner().Pawn).ServerBuyWeapon(TheBuyable.ItemWeaponClass, TheBuyable.ItemWeight);
		}

		MakeSomeBuyNoise();

		SaleSelect.List.SetIndex(-1);
		SaleSelect.List.BuyableToDisplay = None;
		TheBuyable = None;
		LastBuyable = None;

		UpdateBuySellButtons();
	}
}

function DoFillOneAmmo(GUIBuyable Buyable)
{
    if (Buyable != None && Buyable.ItemAmmoClass != None && KFPawn(PlayerOwner().Pawn) != None )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(Buyable.ItemAmmoClass, false);
        GetUpdatedBuyable(true);
    }
}

function DoBuyClip(GUIBuyable Buyable)
{
    if (Buyable != None && Buyable.ItemAmmoClass != None && KFPawn(PlayerOwner().Pawn) != none )
    {
        KFPawn(PlayerOwner().Pawn).ServerBuyAmmo(Buyable.ItemAmmoClass, true);
        GetUpdatedBuyable(true);
    }
}

function DoFillAllAmmo()
{
	UpdateTraderSounds();
	Super.DoFillAllAmmo();
}

function DoBuyKevlar()
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

    if (KFPRI.ClientVeteranSkill != None && KFPRI.ClientVeteranSkill.static.GetCostScaling(KFPRI, class'Vest') < 0.f)
    {
        return;
    }

	Super.DoBuyKevlar();
}

function OnAnychange()
{
	LastBuyable = TheBuyable;

	ItemInfo.Display(TheBuyable);
	SetInfoText();
	UpdatePanel();
	UpdateBuySellButtons();
}

function UpdatePanel()
{
	local float Price;

	Price = 0.0;

	if (TheBuyable != none && !TheBuyable.bSaleList && TheBuyable.bSellable)
	{
		SaleValueLabel.Caption = SaleValueCaption $ TheBuyable.ItemSellValue;

		SaleValueLabel.bVisible = true;
		SaleValueLabelBG.bVisible = true;
	}
	else
	{
		SaleValueLabel.bVisible = false;
		SaleValueLabelBG.bVisible = false;
	}

	if (TheBuyable == none || !TheBuyable.bSaleList)
	{
		GUIBuyMenu(OwnerPage()).WeightBar.NewBoxes = 0;
	}

	ItemInfo.Display(TheBuyable);
	UpdateAutoFillAmmo();
	SetInfoText();

	// Money update
	if (PlayerOwner() != none)
	{
		MoneyLabel.Caption = MoneyCaption $ int(PlayerOwner().PlayerReplicationInfo.Score);
	}
}

function SetInfoText()
{
	local string TempString;

	if ((TheBuyable == None || TheBuyable.ItemWeaponClass == None) && !bDidBuyableUpdate)
	{
		InfoScrollText.SetContent(InfoText[0]);
		bDidBuyableUpdate = true;
		return;
	}

	if (TheBuyable != None && TheBuyable.ItemWeaponClass != None && OldPickupClass != TheBuyable.ItemPickupClass)
	{
		// Unowned Weapon DLC
		if(TheBuyable.bSaleList && TheBuyable.ItemAmmoCurrent > 0)
		{
			if (TheBuyable.ItemAmmoCurrent == 1)
			{
				InfoScrollText.SetContent(Repl(InfoText[4], "%1", GetDLCName(TheBuyable.ItemWeaponClass.Default.AppID)));
			}
			else if (TheBuyable.ItemAmmoCurrent == 2)
			{
				InfoScrollText.SetContent(Repl(ArchivementGetInfo, "%1", Class'SRSteamStatsGet'.Default.Achievements[TheBuyable.ItemWeaponClass.Default.UnlockedByAchievement].DisplayName));
			}
			else
			{
				InfoScrollText.SetContent(Mid(TheBuyable.ItemCategorie, InStr(TheBuyable.ItemCategorie, ":") + 1));
			}
		}
		// Too expensive
		else if (TheBuyable.ItemCost > PlayerOwner().PlayerReplicationInfo.Score && TheBuyable.bSaleList)
		{
			InfoScrollText.SetContent(InfoText[2]);
		}
		// Too heavy
		else if (TheBuyable.ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight && TheBuyable.bSaleList)
		{
			TempString = Repl(Infotext[1], "%1", int(TheBuyable.ItemWeight));
			TempString = Repl(TempString, "%2", int(KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight - KFHumanPawn(PlayerOwner().Pawn).CurrentWeight));
			InfoScrollText.SetContent(TempString);
		}
		// default
		else
		{
			if (TurboGUIBuyable(TheBuyable) != None)
			{
				InfoScrollText.SetContent(class<KFWeapon>(TurboGUIBuyable(TheBuyable).GetPickup().default.InventoryType).default.Description);
			}
			else
			{
				InfoScrollText.SetContent(TheBuyable.ItemWeaponClass.default.Description);
			}
		}

		bDidBuyableUpdate = false;
		OldPickupClass = TheBuyable.ItemPickupClass;
	}
}

function SaleItemClicked(TurboGUIBuyable SelectedSaleItem)
{
	TheBuyable = SelectedSaleItem;
	OnAnychange();
}

function InvItemClicked(GUIBuyable SelectedInvItem)
{
	TheBuyable = SelectedInvItem;
	OnAnychange();
}

function UpdateTraderSounds()
{
	if (class'TurboInteraction'.static.UseMerchantReplacement(TurboPlayerController(PlayerOwner())))
	{
		TraderSoundTooExpensive = class'MerchantVoicePack'.default.TraderSound[8];
	}
	else
	{
		TraderSoundTooExpensive = default.TraderSoundTooExpensive;
	}
}

defaultproperties
{
     Begin Object Class=TurboBuyMenuInvListBox Name=InventoryBox
         OnCreateComponent=InventoryBox.InternalOnCreateComponent
		 OnInvItemClicked=InvItemClicked
         WinTop=0.070841
         WinLeft=0.000108
         WinWidth=0.328204
         WinHeight=0.521856
     End Object
     InvSelect=TurboBuyMenuInvListBox'KFTurbo.TurboTab_BuyMenu.InventoryBox'

     Begin Object Class=TurboGUIBuyWeaponInfoPanel Name=KFPItemInfoPanel
         WinTop=0.193730
         WinLeft=0.332571
         WinWidth=0.333947
         WinHeight=0.489407
     End Object
     ItemInfo=TurboGUIBuyWeaponInfoPanel'KFTurbo.TurboTab_BuyMenu.KFPItemInfoPanel'

     Begin Object Class=TurboBuyMenuSaleListBox Name=SaleBox
         OnCreateComponent=SaleBox.InternalOnCreateComponent
		 OnSaleItemClicked=SaleItemClicked
         WinTop=0.064312
         WinLeft=0.672632
         WinWidth=0.325857
         WinHeight=0.674039
     End Object
     SaleSelect=TurboBuyMenuSaleListBox'KFTurbo.TurboTab_BuyMenu.SaleBox'

}
