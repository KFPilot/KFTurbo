//Killing Floor Turbo TurboInteraction
//Contains user configuration and some special input handling for KFTurbo.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboInteraction extends Engine.Interaction
	dependson(TurboPlayerMarkReplicationInfo)
	dependson(TurboRepLink)
	config(KFTurbo);

var globalconfig TurboPlayerMarkReplicationInfo.EMarkColor MarkColor;

var bool bHasInitializedInteraction;
var bool bHasInitializedStyles;
var bool bHasInitializedPerkTierPreference;
var globalconfig array<TurboRepLink.VeterancyTierPreference> PerkTierPreferenceList;

var globalconfig bool bReplaceTraderWithMerchant;
var string MerchantMeshRef;
var Mesh MerchantMesh;
var string MerchantAnimRef;
var MeshAnimation MerchantAnim;
var string MerchantMaterialRef;
var Material MerchantMaterial;
var Material DefaultTraderMaterial;

var globalconfig bool bShiftOpensTrader;
var globalconfig bool bF3VotesYes;

var globalconfig bool bPipebombUsesSpecialGroup;

var globalconfig bool bUseBaseGameFontForChat;

var globalconfig bool bHasPerformedInitialFontLocalCheck;
var globalconfig string FontLocale;

enum EDetectedLocale
{
	Latin,
	Japanese,
	Cyrillic,
	Unknown
};

const JapaneseALowerBound = 0x3000;
const JapaneseAUpperBound = 0x30FF;
const JapaneseBLowerBound = 0x31F0;
const JapaneseBUpperBound = 0x31FF;

const CyrillicLowerBound = 0x0400;
const CyrillicUpperBound = 0x052F;

simulated function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (Action != IST_Press)
	{
		return false;
	}

	if (Key == IK_Shift && bShiftOpensTrader)
	{
		Trade();
	}
	else if (Key == IK_F3 && bF3VotesYes)
	{
		VoteYes();
	}

	return false;
}

simulated function OnInteractionCreated()
{
	//Update the ExtendedConsole's In-Game Chat class so it's not competing with us for the chat delegate binding.
	if (ViewportOwner != None && ExtendedConsole(ViewportOwner.Console) != None)
	{
		ExtendedConsole(ViewportOwner.Console).ChatMenuClass = string(class'KFTurbo.TurboInGameChat');
	}

	if (ViewportOwner != None)
	{
		RegisterStyles(GUIController(ViewportOwner.GUIController));
	}
}

simulated function InitializeTurboInteraction()
{
	if (bHasInitializedInteraction)
	{
		return;
	}

	bHasInitializedInteraction = true;
	InitializeVeterancyTierPreferences();
	UpdateMerchant();
	InitializePipebombUsesSpecialGroup();
	UpdateUseBaseGameFontForChat();
	InitializeFontLocale();

	RegisterStyles(GUIController(ViewportOwner.GUIController));
}

simulated function RegisterStyles(GUIController GUIController)
{
	if (bHasInitializedStyles || GUIController == None)
	{
		return;
	}

	bHasInitializedStyles = true;

	GUIController.RegisterStyle(class'TurboGUIStyleSectionLabel');
	GUIController.RegisterStyle(class'TurboGUIStyleLabel');
	GUIController.RegisterStyle(class'TurboGUIStyleButton');
}

simulated function NotifyLevelChange()
{
	if (ViewportOwner != None && ExtendedConsole(ViewportOwner.Console) != None)
	{
		ExtendedConsole(ViewportOwner.Console).ChatMenuClass = ExtendedConsole(ViewportOwner.Console).default.ChatMenuClass;
	}
}

exec simulated function Trade()
{
	if (ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None)
	{
		return;
	}

	if (!class'KFTurboGameType'.static.StaticIsHighDifficulty(ViewportOwner.Actor) && !class'KFTurboGameType'.static.StaticIsTestGameType(ViewportOwner.Actor))
	{
		return;
	}

	if (KFHumanPawn(ViewportOwner.Actor.Pawn) == None || ViewportOwner.Actor.Pawn.Health <= 0.f)
	{
		return;
	}

	if (KFGameReplicationInfo(ViewportOwner.Actor.Level.GRI) == None || KFGameReplicationInfo(ViewportOwner.Actor.Level.GRI).bWaveInProgress)
	{
		return;
	}

	ViewportOwner.GUIController.CloseMenu();
	KFPlayerController(ViewportOwner.Actor).ShowBuyMenu("WeaponLocker", KFHumanPawn(ViewportOwner.Actor.Pawn).MaxCarryWeight);
}

simulated function VoteYes()
{
	if (ViewportOwner == None)
	{
		return;
	}

	TurboPlayerController(ViewportOwner.Actor).Vote("YES");
}

exec simulated function SetMarkColor(TurboPlayerMarkReplicationInfo.EMarkColor Color)
{
	MarkColor = Color;
	SaveConfig();
}

exec simulated function MarkActor(optional TurboPlayerMarkReplicationInfo.EMarkColor Color)
{
	local Vector HitLocation, HitNormal;
	local Vector StartMarkTrace, X, Y, Z;
	local Vector EndMarkTrace;
	local Actor Actor;

	if (TurboPlayerController(ViewportOwner.Actor) == None)
	{
		return;
	}

	if (KFHumanPawn(ViewportOwner.Actor.Pawn) == None || ViewportOwner.Actor.Pawn.Health <= 0.f || ViewportOwner.Actor.Pawn.Weapon == None)
	{
		return;
	}

	if (KFGameReplicationInfo(ViewportOwner.Actor.Level.GRI) == None)
	{
		return;
	}
	
	if (Color == Invalid)
	{
		Color = MarkColor;
	}

	StartMarkTrace = ViewportOwner.Actor.Pawn.Location + ViewportOwner.Actor.Pawn.EyePosition();
	ViewportOwner.Actor.Pawn.Weapon.GetViewAxes(X, Y, Z);
	
	EndMarkTrace = StartMarkTrace + (X * 500.f);

	Actor = ViewportOwner.Actor.Pawn.Trace(HitLocation, HitNormal, EndMarkTrace, StartMarkTrace, true, vect(10, 10, 10));

	if (Actor != None)
	{
		TurboPlayerController(ViewportOwner.Actor).AttemptMarkActor(StartMarkTrace, HitLocation, Actor, None, -1, MarkColor);
		return;
	}
	
	EndMarkTrace += (X * 1000.f);
	Actor = ViewportOwner.Actor.Pawn.Trace(HitLocation, HitNormal, EndMarkTrace, StartMarkTrace, true, vect(5, 5, 5));

	if (Actor != None)
	{
		TurboPlayerController(ViewportOwner.Actor).AttemptMarkActor(StartMarkTrace, HitLocation, Actor, None, -1, MarkColor);
		return;
	}

	EndMarkTrace += (X * 1000.f);
	Actor = ViewportOwner.Actor.Pawn.Trace(HitLocation, HitNormal, EndMarkTrace, StartMarkTrace, true, vect(2, 2, 2));

	if (Actor != None)
	{
		TurboPlayerController(ViewportOwner.Actor).AttemptMarkActor(StartMarkTrace, HitLocation, Actor, None, -1, MarkColor);
		return;
	}
}

simulated function CheckForVoiceCommandMark(Name Type, int Index)
{
	local int VoiceCommandMarkData;
	local Vector HitLocation, HitNormal;
	local Vector StartMarkTrace, X, Y, Z;
	local Vector EndMarkTrace;
	local Actor TargetActor;

	if (Type == 'ALERT' && Index == 0)
	{
		MarkActor(Invalid);
		return;
	}

	VoiceCommandMarkData = class'TurboMarkerType_VoiceCommand'.static.GetGenerateMarkerDataFromVoiceCommand(Type, Index);
	
	if (VoiceCommandMarkData == -1)
	{
		return;
	}

	//Mark the pawn with this data.
	if (!class'TurboMarkerType_VoiceCommand'.static.WantsToMarkLookTarget(VoiceCommandMarkData))
	{
		TurboPlayerController(ViewportOwner.Actor).AttemptMarkActor(ViewportOwner.Actor.Pawn.Location, ViewportOwner.Actor.Pawn.Location, ViewportOwner.Actor.Pawn, class'TurboMarkerType_VoiceCommand', VoiceCommandMarkData, MarkColor);
		return;
	}

	if (ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None)
	{
		return;
	}

	StartMarkTrace = ViewportOwner.Actor.Pawn.Location + ViewportOwner.Actor.Pawn.EyePosition();
	ViewportOwner.Actor.Pawn.Weapon.GetViewAxes(X, Y, Z);
	
	EndMarkTrace = StartMarkTrace + (X * 500.f);
	TargetActor = ViewportOwner.Actor.Pawn.Trace(HitLocation, HitNormal, EndMarkTrace, StartMarkTrace, true, vect(10, 10, 10));

	if (TurboHumanPawn(TargetActor) != None)
	{
		TurboPlayerController(ViewportOwner.Actor).AttemptMarkActor(StartMarkTrace, HitLocation, TargetActor, class'TurboMarkerType_VoiceCommand', VoiceCommandMarkData, MarkColor);
	}
}

simulated function SetVeterancyTierPreference(class<TurboVeterancyTypes> PerkClass, int TierPreference, optional bool bSkipSaveConfig)
{
	local TurboRepLink TurboRepLink;

	TierPreference = Min(TierPreference, 7);
	switch(PerkClass)
	{
		case class'V_FieldMedic':
			PerkTierPreferenceList[0].TierPreference = TierPreference;
			break;
		case class'V_SupportSpec':
			PerkTierPreferenceList[1].TierPreference = TierPreference;
			break;
		case class'V_Sharpshooter':
			PerkTierPreferenceList[2].TierPreference = TierPreference;
			break;
		case class'V_Commando':
			PerkTierPreferenceList[3].TierPreference = TierPreference;
			break;
		case class'V_Berserker':
			PerkTierPreferenceList[4].TierPreference = TierPreference;
			break;
		case class'V_Firebug':
			PerkTierPreferenceList[5].TierPreference = TierPreference;
			break;
		case class'V_Demolitions':
			PerkTierPreferenceList[6].TierPreference = TierPreference;
			break;
		default:
			return;
	}

	TurboRepLink = TurboPlayerController(ViewportOwner.Actor).GetTurboRepLink();
	if (TurboRepLink == None)
	{
		return;
	}

	TurboRepLink.SetVeterancyTierPreference(PerkClass, TierPreference);

	if (!bSkipSaveConfig)
	{
		SaveConfig();
	}
}

simulated function bool InitializeVeterancyTierPreferences()
{
	local int Index;
	local TurboRepLink TurboRepLink;

	if (bHasInitializedPerkTierPreference)
	{
		return true;
	}

	TurboRepLink = TurboPlayerController(ViewportOwner.Actor).GetTurboRepLink();

	if (TurboRepLink == None)
	{
		return false;
	}

	//Somehow we nuked the list. Reset it.
	if (PerkTierPreferenceList.Length == 0)
	{
		PerkTierPreferenceList = default.PerkTierPreferenceList;
	}

	for (Index = 0; Index < PerkTierPreferenceList.Length; Index++)
	{
		TurboRepLink.SetVeterancyTierPreference(PerkTierPreferenceList[Index].PerkClass, PerkTierPreferenceList[Index].TierPreference);
	}

	bHasInitializedPerkTierPreference = true;
	return true;
}

simulated function SetUseMerchantReplacement(bool bReplaceTrader)
{
	bReplaceTraderWithMerchant = bReplaceTrader;
	SaveConfig();

	UpdateMerchant();
}

static final function bool UseMerchantReplacement(TurboPlayerController PlayerController)
{
	if (PlayerController != None && PlayerController.TurboInteraction != None)
	{
		return PlayerController.TurboInteraction.bReplaceTraderWithMerchant;
	}

	return false;
}

simulated function UpdateMerchant()
{
	local WeaponLocker Trader;

	if (ViewportOwner.Actor != None && TurboHUDKillingFloor(ViewportOwner.Actor.myHUD) != None)
	{
		TurboHUDKillingFloor(ViewportOwner.Actor.myHUD).UpdateTraderPortrait(bReplaceTraderWithMerchant);
	}
	
	if (ViewportOwner.Actor != None)
	{
		if (MerchantMesh == None)
		{
			MerchantMesh = Mesh(DynamicLoadObject(MerchantMeshRef, class'Mesh'));
		}

		if (MerchantAnim == None)
		{
			MerchantAnim = MeshAnimation(DynamicLoadObject(MerchantAnimRef, class'MeshAnimation'));
		}

		if (MerchantMaterial == None)
		{
			MerchantMaterial = Material(DynamicLoadObject(MerchantMaterialRef, class'Material'));
		}

		foreach ViewportOwner.Actor.AllActors(class'WeaponLocker', Trader)
		{
			if ((Trader.Mesh == Trader.default.Mesh && (Trader.Skins.Length == 0 || Trader.Skins[0] == DefaultTraderMaterial)) || Trader.Mesh == MerchantMesh)
			{
				if (bReplaceTraderWithMerchant)
				{
					Trader.LinkMesh(MerchantMesh, false);
					Trader.LinkSkelAnim(MerchantAnim);
					Trader.LoopAnim('Idle');
					Trader.Skins.Length = 1;
					Trader.Skins[0] = MerchantMaterial;
				}
				else
				{
					Trader.LinkMesh(Trader.default.Mesh, false);
					Trader.LinkSkelAnim(MeshAnimation'KF_Soldier_Trip.shopkeeper_anim');
					Trader.LoopAnim('Idle');
					Trader.Skins.Length = 1;
					Trader.Skins[0] = DefaultTraderMaterial;
				}
			}
		}
	}
}

simulated function SetShiftTradeEnabled(bool bNewShiftOpensTrader)
{
	bShiftOpensTrader = bNewShiftOpensTrader;
	SaveConfig();
}

static final function bool IsShiftTradeEnabled(TurboPlayerController PlayerController)
{
	if (PlayerController != None && PlayerController.TurboInteraction != None)
	{
		return PlayerController.TurboInteraction.bShiftOpensTrader;
	}

	return false;
}

simulated function SetF3VoteYesEnabled(bool bNewF3VotesYes)
{
	bF3VotesYes = bNewF3VotesYes;
	SaveConfig();
}

static final function bool IsF3VoteYesEnabled(TurboPlayerController PlayerController)
{
	if (PlayerController != None && PlayerController.TurboInteraction != None)
	{
		return PlayerController.TurboInteraction.bF3VotesYes;
	}

	return false;
}

simulated function SetPipebombUsesSpecialGroup(bool bNewPipebombUsesSpecialGroup)
{
	if (bNewPipebombUsesSpecialGroup == bPipebombUsesSpecialGroup)
	{
		return;
	}

	bPipebombUsesSpecialGroup = bNewPipebombUsesSpecialGroup;
	TurboPlayerController(ViewportOwner.Actor).SetPipebombUsesSpecialGroup(bPipebombUsesSpecialGroup);
	SaveConfig();
}

static final function bool ShouldPipebombUseSpecialGroup(TurboPlayerController PlayerController)
{
	if (PlayerController != None && PlayerController.TurboInteraction != None)
	{
		return PlayerController.TurboInteraction.bPipebombUsesSpecialGroup;
	}

	return false;
}

simulated function InitializePipebombUsesSpecialGroup()
{
	TurboPlayerController(ViewportOwner.Actor).SetPipebombUsesSpecialGroup(bPipebombUsesSpecialGroup);
}

simulated function SetUseBaseGameFontForChat(bool bNewUseBaseGameFontForChat)
{
	if (bNewUseBaseGameFontForChat == bUseBaseGameFontForChat)
	{
		return;
	}

	bUseBaseGameFontForChat = bNewUseBaseGameFontForChat;
	UpdateUseBaseGameFontForChat();
	SaveConfig();
}

static final function bool ShouldUseBaseGameFontForChat(TurboPlayerController PlayerController)
{
	if (PlayerController != None && PlayerController.TurboInteraction != None)
	{
		return PlayerController.TurboInteraction.bUseBaseGameFontForChat;
	}

	return false;
}

simulated function UpdateUseBaseGameFontForChat()
{
	if (ViewportOwner.Actor != None && TurboHUDKillingFloor(ViewportOwner.Actor.myHUD) != None)
	{
		TurboHUDKillingFloor(ViewportOwner.Actor.myHUD).bUseBaseGameFontForChat = bUseBaseGameFontForChat;
	}
}

simulated function SetFontLocale(string NewFontLocale)
{
	if (NewFontLocale == FontLocale)
	{
		return;
	}

	FontLocale = NewFontLocale;
	UpdateFontLocale();
	SaveConfig();
}

static final function string GetFontLocale(TurboPlayerController PlayerController)
{
	if (PlayerController != None && PlayerController.TurboInteraction != None)
	{
		return PlayerController.TurboInteraction.FontLocale;
	}

	return "ENG";
}

simulated function EDetectedLocale ResolveLocale(string String)
{
    local int Index, Code;

    for (Index = Len(String); Index >= 0; Index--)
    {
        Code = Asc(Mid(String, Index, 1));
        if ((Code >= JapaneseALowerBound && Code <= JapaneseAUpperBound)
			|| (Code >= JapaneseBLowerBound && Code <= JapaneseBUpperBound))
		{
            return Japanese;
		}
		else if (Code >= CyrillicLowerBound && Code <= CyrillicUpperBound)
		{
            return Cyrillic;
		}
    }

    return Latin;
}

simulated function InitializeFontLocale()
{
	if (!bHasPerformedInitialFontLocalCheck)
	{
		log("Performing initial locale check so the correct font locale is used. Test string is "$ class'HUDKillingFloor'.default.TraderString $".", 'KFTurbo');
		switch (ResolveLocale(class'HUDKillingFloor'.default.TraderString))
		{
			case Latin:
				FontLocale = "ENG";
				CheckForFontOverrides(); //For now any locale that is not JPN or CYR will return Latin... so just check here if someone has a custom font.
				break;
			case Japanese:
				FontLocale = "JPN";
				break;
			case Cyrillic:
				FontLocale = "CYR";
				break;
		}
		
		bHasPerformedInitialFontLocalCheck = true;
		SaveConfig();
	}

	UpdateFontLocale();
}

simulated function CheckForFontOverrides()
{
	if (class'HUDKillingFloor'.default.SmallFontArrayNames[1] ~= "ROFontsTwo.ROArial24DS"
		&& class'HUDKillingFloor'.default.SmallFontArrayNames[2] ~= "ROFontsTwo.ROArial22DS"
		&& class'HUDKillingFloor'.default.SmallFontArrayNames[3] ~= "ROFontsTwo.ROArial22DS"
		&& class'HUDKillingFloor'.default.SmallFontArrayNames[4] ~= "ROFontsTwo.ROArial18DS"
		&& class'HUDKillingFloor'.default.SmallFontArrayNames[5] ~= "ROFontsTwo.ROArial14DS"
		&& class'HUDKillingFloor'.default.SmallFontArrayNames[6] ~= "ROFontsTwo.ROArial12DS"
		&& class'HUDKillingFloor'.default.SmallFontArrayNames[7] ~= "ROFontsTwo.ROArial9DS"
		&& class'HUDKillingFloor'.default.SmallFontArrayNames[8] ~= "ROFontsTwo.ROArial7DS"
		&& class'HUDKillingFloor'.default.MenuFontArrayNames[0] ~= "ROFonts.ROBtsrmVr18"
		&& class'HUDKillingFloor'.default.MenuFontArrayNames[1] ~= "ROFonts.ROBtsrmVr14"
		&& class'HUDKillingFloor'.default.MenuFontArrayNames[2] ~= "ROFonts.ROBtsrmVr12"
		&& class'HUDKillingFloor'.default.MenuFontArrayNames[3] ~= "ROFonts.ROBtsrmVr9"
		&& class'HUDKillingFloor'.default.MenuFontArrayNames[4] ~= "ROFonts.ROBtsrmVr7"
		&& class'HUDKillingFloor'.default.WaitingFontArrayNames[0] ~= "KFFonts.KFBase02DS36"
		&& class'HUDKillingFloor'.default.WaitingFontArrayNames[1] ~= "KFFonts.KFBase02DS24"
		&& class'HUDKillingFloor'.default.FontArrayNames[0] ~= "ROFontsTwo.ROArial24DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[1] ~= "ROFontsTwo.ROArial24DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[2] ~= "ROFontsTwo.ROArial22DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[3] ~= "ROFontsTwo.ROArial18DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[4] ~= "ROFontsTwo.ROArial18DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[5] ~= "ROFontsTwo.ROArial14DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[6] ~= "ROFontsTwo.ROArial12DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[7] ~= "ROFontsTwo.ROArial9DS"
		&& class'HUDKillingFloor'.default.FontArrayNames[8] ~= "ROFontsTwo.ROArial7DS")
	{
		return;
	}

	ViewportOwner.Actor.ClientMessage("Custom font override detected! This is not currently supported by KFTurbo.");
}

simulated function UpdateFontLocale()
{
	if (ViewportOwner.Actor != None && TurboHUDKillingFloor(ViewportOwner.Actor.myHUD) != None)
	{
		TurboHUDKillingFloor(ViewportOwner.Actor.myHUD).SetFontLocale(FontLocale);
	}
}

defaultproperties
{
	bHasInitializedInteraction=false
	bHasInitializedPerkTierPreference=false
	PerkTierPreferenceList(0)=(PerkClass=class'V_FieldMedic',TierPreference=7)
	PerkTierPreferenceList(1)=(PerkClass=class'V_SupportSpec',TierPreference=7)
	PerkTierPreferenceList(2)=(PerkClass=class'V_Sharpshooter',TierPreference=7)
	PerkTierPreferenceList(3)=(PerkClass=class'V_Commando',TierPreference=7)
	PerkTierPreferenceList(4)=(PerkClass=class'V_Berserker',TierPreference=7)
	PerkTierPreferenceList(5)=(PerkClass=class'V_Firebug',TierPreference=7)
	PerkTierPreferenceList(6)=(PerkClass=class'V_Demolitions',TierPreference=7)

	bReplaceTraderWithMerchant=false
	MerchantMeshRef="KFTurbo.Merchant_Trip"
	MerchantAnimRef="KFTurbo.Merchant_anim"
	MerchantMaterialRef="KFTurbo.Merchant.Merchant_D"
	DefaultTraderMaterial=Texture'KF_Soldier_Trip_T.Uniforms.shopkeeper_diff'

	bShiftOpensTrader=true
	bF3VotesYes=true

	bPipebombUsesSpecialGroup=false

	bHasPerformedInitialFontLocalCheck=true
	FontLocale="ENG"
}