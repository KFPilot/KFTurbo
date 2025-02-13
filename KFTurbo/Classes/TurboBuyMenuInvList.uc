//Killing Floor Turbo TurboBuyMenuInvList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboBuyMenuInvList extends SRKFBuyMenuInvList;

delegate OnInvItemClicked(GUIBuyable SelectedInvItem);

final function GUIBuyable AllocateTurboEntry( ClientPerkRepLink L )
{
	local GUIBuyable G;

	if( L.AllocatedObjects.Length==0 )
		return new Class'GUIBuyable';
	G = L.AllocatedObjects[0];
	L.ResetItem(G);
	
	if (TurboGUIBuyable(G) != None)
	{
		TurboGUIBuyable(G).VariantList.Length = 0;
		TurboGUIBuyable(G).VariantSelection = -1;
	}

	L.AllocatedObjects.Remove(0,1);
	return G;
}

function UpdateMyBuyables()
{
	local GUIBuyable MyBuyable, KnifeBuyable, FragBuyable;
	local array<GUIBuyable> SecTypes;
	local Inventory CurInv;
	local float CurAmmo, MaxAmmo;
	local class<KFWeaponPickup> MyPickup,MyPrimaryPickup, AdjustedPickup;
	local int DualDivider,i;
	local class<KFVeterancyTypes> KFV;
	local ClientPerkRepLink CPRL;
	local KFPlayerReplicationInfo PRI;

	PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
	CPRL = TurboPlayerController(PlayerOwner()).GetClientPerkRepLink();
	
	if( CPRL==None || PRI==None )
		return; // Hmmmm?

	// Let's start with our current inventory
	if ( PlayerOwner().Pawn.Inventory == none )
	{
		//log("Inventory is none!");
		return;
	}

	DualDivider = 1;
	AutoFillCost = 0.00000;

	// Clear the MyBuyables array
	CopyAllBuyables();
	MyBuyables.Length = 0;

	KFV = PRI.ClientVeteranSkill;
	if( KFV==None )
		KFV = Class'KFVeterancyTypes';

	// Fill the Buyables
	for ( CurInv = PlayerOwner().Pawn.Inventory; CurInv != none; CurInv = CurInv.Inventory )
	{
		if ( KFWeapon(CurInv)==None || CurInv.IsA('Welder') || CurInv.IsA('Syringe') || CurInv.IsA('Dummy_JoggingWeapon') )
			continue;

		if ( CurInv.IsA('DualDeagle') || CurInv.IsA('Dual44Magnum') || CurInv.IsA('DualMK23Pistol') || KFWeapon(CurInv).DemoReplacement!=None )
			DualDivider = 2;
		else DualDivider = 1;

		MyPickup = class<KFWeaponPickup>(CurInv.default.PickupClass);
		AdjustedPickup = class'TurboHumanPawn'.static.GetCorrectedWeaponPickup(MyPickup);

		KFWeapon(CurInv).GetAmmoCount(MaxAmmo, CurAmmo);

		if ( KFWeapon(CurInv).bHasSecondaryAmmo )
		{
			MyPrimaryPickup = MyPickup.default.PrimaryWeaponPickup;
		}
		else
		{
			MyPrimaryPickup = MyPickup;
		} 

		MyBuyable = AllocateTurboEntry(CPRL);

		MyBuyable.ItemName 		= MyPickup.default.ItemShortName;
		MyBuyable.ItemDescription 	= KFWeapon(CurInv).default.Description;
		MyBuyable.ItemCategorie		= "Melee"; // More dummy.
		MyBuyable.ItemImage		= KFWeapon(CurInv).default.TraderInfoTexture;
		MyBuyable.ItemWeaponClass	= KFWeapon(CurInv).class;
		MyBuyable.ItemAmmoClass		= KFWeapon(CurInv).default.FireModeClass[0].default.AmmoClass;
		MyBuyable.ItemPickupClass	= MyPrimaryPickup;
		MyBuyable.ItemCost		= (float(MyPickup.default.Cost) * KFV.static.GetCostScaling(PRI, AdjustedPickup)) / DualDivider;
		MyBuyable.ItemAmmoCost		= MyPrimaryPickup.default.AmmoCost * KFV.static.GetAmmoCostScaling(PRI, AdjustedPickup)
										  * KFV.static.GetMagCapacityMod(PRI, KFWeapon(CurInv));
										  
		if( class<W_Huskgun_Pickup>(MyPickup) != None )
		{
			MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPrimaryPickup.default.AmmoCost)) / float(MyPrimaryPickup.default.BuyClipSize))) * KFV.static.GetAmmoCostScaling(PRI, MyPrimaryPickup);
		}
		else
		{
			MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPrimaryPickup.default.AmmoCost)) / float(KFWeapon(CurInv).default.MagCapacity))) * KFV.static.GetAmmoCostScaling(PRI, MyPrimaryPickup);
		}

		MyBuyable.ItemWeight		= KFWeapon(CurInv).Weight;
		MyBuyable.ItemPower		= MyPickup.default.PowerValue;
		MyBuyable.ItemRange		= MyPickup.default.RangeValue;
		MyBuyable.ItemSpeed		= MyPickup.default.SpeedValue;
		MyBuyable.ItemAmmoCurrent	= CurAmmo;
		MyBuyable.ItemAmmoMax		= MaxAmmo;
		MyBuyable.bMelee			= (KFMeleeGun(CurInv)!=none || MyBuyable.ItemAmmoClass==None);
		MyBuyable.bSaleList		= false;
		MyBuyable.ItemPerkIndex		= MyPickup.default.CorrespondingPerkIndex;

		if ( KFWeapon(CurInv) != none && KFWeapon(CurInv).SellValue != -1 )
			MyBuyable.ItemSellValue = KFWeapon(CurInv).SellValue;
		else MyBuyable.ItemSellValue = MyBuyable.ItemCost * 0.75;

		if ( !MyBuyable.bMelee && int(MaxAmmo)>int(CurAmmo) )
			AutoFillCost += MyBuyable.ItemFillAmmoCost;

		if ( CurInv.IsA('Knife') )
		{
			MyBuyable.bSellable	= false;
			KnifeBuyable = MyBuyable;
		}
		else if ( CurInv.IsA('Frag') )
		{
			MyBuyable.bSellable	= false;
			FragBuyable = MyBuyable;
		}
		else
		{
			MyBuyable.bSellable	= !KFWeapon(CurInv).default.bKFNeverThrow;
			MyBuyables.Insert(0,1);
			MyBuyables[0] = MyBuyable;
		}

		if ( !KFWeapon(CurInv).bHasSecondaryAmmo )
			continue;

		// Add secondary ammo.
		KFWeapon(CurInv).GetSecondaryAmmoCount(MaxAmmo, CurAmmo);

		MyBuyable = AllocateTurboEntry(CPRL);

		MyBuyable.ItemName 		= MyPickup.default.SecondaryAmmoShortName;
		MyBuyable.ItemDescription 	= KFWeapon(CurInv).default.Description;
		MyBuyable.ItemCategorie		= "Melee";
		MyBuyable.ItemImage		= KFWeapon(CurInv).default.TraderInfoTexture;
		MyBuyable.ItemWeaponClass	= KFWeapon(CurInv).class;
		MyBuyable.ItemAmmoClass		= KFWeapon(CurInv).default.FireModeClass[1].default.AmmoClass;
		MyBuyable.ItemPickupClass	= MyPickup;
		MyBuyable.ItemCost		= (float(MyPickup.default.Cost) * KFV.static.GetCostScaling(PRI, AdjustedPickup)) / DualDivider;
		MyBuyable.ItemAmmoCost		= MyPickup.default.AmmoCost * KFV.static.GetAmmoCostScaling(PRI, AdjustedPickup) * KFV.static.GetMagCapacityMod(PRI, KFWeapon(CurInv));
		MyBuyable.ItemFillAmmoCost	= (int(((MaxAmmo - CurAmmo) * float(MyPickup.default.AmmoCost)) /* Secondary Mags always have a Mag Capacity of 1? / float(KFWeapon(CurInv).default.MagCapacity)*/)) * KFV.static.GetAmmoCostScaling(PRI, MyPickup);
		MyBuyable.ItemWeight		= KFWeapon(CurInv).Weight;
		MyBuyable.ItemPower		= MyPickup.default.PowerValue;
		MyBuyable.ItemRange		= MyPickup.default.RangeValue;
		MyBuyable.ItemSpeed		= MyPickup.default.SpeedValue;
		MyBuyable.ItemAmmoCurrent	= CurAmmo;
		MyBuyable.ItemAmmoMax		= MaxAmmo;
		MyBuyable.bMelee		= (KFMeleeGun(CurInv) != none);
		MyBuyable.bSaleList		= false;
		MyBuyable.ItemPerkIndex		= MyPickup.default.CorrespondingPerkIndex;
		MyBuyable.bSellable		= !KFWeapon(CurInv).default.bKFNeverThrow;

		if ( KFWeapon(CurInv) != none && KFWeapon(CurInv).SellValue != -1 )
			MyBuyable.ItemSellValue = KFWeapon(CurInv).SellValue;
		else MyBuyable.ItemSellValue = MyBuyable.ItemCost * 0.75;

		if ( !MyBuyable.bMelee && int(MaxAmmo) > int(CurAmmo))
			AutoFillCost += MyBuyable.ItemFillAmmoCost;

		SecTypes[SecTypes.Length] = MyBuyable;
	}

	MyBuyable = AllocateTurboEntry(CPRL);

	MyBuyable.ItemName 		= class'BuyableVest'.default.ItemName;
	MyBuyable.ItemDescription 	= class'BuyableVest'.default.ItemDescription;
	MyBuyable.ItemCost		= int(class'BuyableVest'.default.ItemCost * KFV.static.GetCostScaling(PRI, class'Vest'));

	if (MyBuyable.ItemCost > 0.f)
	{
		MyBuyable.ItemCategorie		= "";
		MyBuyable.ItemImage			= class'BuyableVest'.default.ItemImage;
		MyBuyable.ItemAmmoCurrent	= PlayerOwner().Pawn.ShieldStrength;
		MyBuyable.ItemAmmoMax		= 100;
		MyBuyable.ItemAmmoCost		= MyBuyable.ItemCost / 100;
		MyBuyable.ItemFillAmmoCost	= int((100.0 - MyBuyable.ItemAmmoCurrent) * MyBuyable.ItemAmmoCost);
		MyBuyable.bIsVest			= true;
		MyBuyable.bMelee			= false;
		MyBuyable.bSaleList			= false;
		MyBuyable.bSellable			= false;
		MyBuyable.ItemPerkIndex		= class'BuyableVest'.default.CorrespondingPerkIndex;
	}
	else 
	{
		MyBuyable.ItemCategorie		= "";
		MyBuyable.ItemImage			= class'BuyableVest'.default.ItemImage;
		MyBuyable.ItemAmmoCurrent	= PlayerOwner().Pawn.ShieldStrength;
		MyBuyable.ItemAmmoMax		= 0;
		MyBuyable.ItemAmmoCost		= 0;
		MyBuyable.ItemFillAmmoCost	= 0;
		MyBuyable.bIsVest			= true;
		MyBuyable.bMelee			= false;
		MyBuyable.bSaleList			= false;
		MyBuyable.bSellable			= false;
		MyBuyable.ItemPerkIndex		= class'BuyableVest'.default.CorrespondingPerkIndex;		
	}

	if( MyBuyables.Length<=(7-SecTypes.Length) )
	{
		MyBuyables.Length = 11;
		for( i=(SecTypes.Length-1); i>=0; --i )
			MyBuyables[7-i] = SecTypes[i];
		MyBuyables[8] = KnifeBuyable;
		MyBuyables[9] = FragBuyable;
		MyBuyables[10] = MyBuyable;
	}
	else
	{
		MyBuyables[MyBuyables.Length] = none;
		for( i=(SecTypes.Length-1); i>=0; --i )
			MyBuyables[MyBuyables.Length] = SecTypes[i];
		MyBuyables[MyBuyables.Length] = KnifeBuyable;
		MyBuyables[MyBuyables.Length] = FragBuyable;
		MyBuyables[MyBuyables.Length] = MyBuyable;
	}

	//Now Update the list
	UpdateList();
}

function bool InternalOnClick(GUIComponent Sender)
{
	local int NewIndex;
	local float RelativeMouseX;
	local GUIBuyable ClickedBuyable;

	if (!IsInClientBounds())
	{
		return false;
	}

	NewIndex = CalculateIndex();
	ClickedBuyable = MyBuyables[NewIndex];

	if (ClickedBuyable == None)
	{
		SetIndex(-1);
		return false;
	}

	//  Figure out which Item we're clicking on
	NewIndex = CalculateIndex();
	RelativeMouseX = Controller.MouseX - ClientBounds[0];
	if ( RelativeMouseX < ActualWidth() * ItemBGWidthScale )
	{
		SetIndex(NewIndex);
		MouseOverXIndex = 0;
		return true;
	}

	RelativeMouseX -= ActualWidth() * (ItemBGWidthScale + AmmoBGWidthScale);

	if ( RelativeMouseX > 0 )
	{
		if ( ClickedBuyable.bIsVest )
		{
			if ( (PlayerOwner().Pawn.ShieldStrength > 0 && PlayerOwner().PlayerReplicationInfo.Score >= ClickedBuyable.ItemAmmoCost) || PlayerOwner().PlayerReplicationInfo.Score >= ClickedBuyable.ItemCost )
			{
				OnBuyVestClick();
			}
		}
		else if ( RelativeMouseX < ActualWidth() * (1.0 - ItemBGWidthScale - AmmoBGWidthScale) * ClipButtonWidthScale )
		{
			// Buy Clip
			OnBuyClipClick(ClickedBuyable);
		}
		else
		{
			// Fill Ammo
			OnFillAmmoClick(ClickedBuyable);
		}
	}

	return false;
}

function IndexChanged(GUIComponent Sender)
{
	Super.IndexChanged(Sender);

	if (Index >= 0 && Index < MyBuyables.Length)
	{
		OnInvItemClicked(MyBuyables[Index]);
	}
	else
	{
		OnInvItemClicked(None);
	}
}

defaultproperties
{
}
