//Killing Floor Turbo TurboHUDPlayerInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDPlayerInfo extends TurboHUDOverlay
    hidecategories(Advanced,Collision,Display,Events,Force,Karma,LightColor,Lighting,Movement,Object,Sound);

struct PlayerInfoData
{
	var TurboPlayerReplicationInfo TPRI;
	var TurboHumanPawn HumanPawn;
	var TurboHUDPlayerInfoEntry Entry;
};

//These are in GameReplicationInfo::PRIArray order.
var array<PlayerInfoData> PlayerInfoDataList;
//These will be in player view distance order.
var array<int> PlayerInfoDataDistanceOrderList;

var float NextPawnCollectionTime;
var int LastPlayerStateListLength;
var class<TurboHUDPlayerInfoEntry> PlayerInfoEntryClass;

var() color HealthBarColor;
var() color HealthLossBarColor;
var() color HealthHitBarColor;
var() color HealToHealthBarColor;

var() color ShieldBarColor;
var() color ShieldLossBarColor;

var() color BarBackplateColor;

var Texture PerkBackplate;

var Texture ChatIcon;
var Texture ShoppingIcon;
var Texture PoorSignalIcon;
var Texture NoSignalIcon;

var Texture MedicBackplate;
var Texture AlertIcon;
var Texture MedicIcon;

var int FontSizeOffset;

var InterpCurve MedicRequestOpacityCurve;
var array<InterpCurvePoint> MedicRequestOpacityPointList;
var InterpCurve MedicRequestMoveCurve;
var array<InterpCurvePoint> MedicRequestMovePointList;
var InterpCurve MedicRequestScaleCurve;
var array<InterpCurvePoint> MedicRequestScalePointList;

var bool bAllowSelfForDebug;

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	Super.Initialize(OwnerHUD);
	MedicRequestOpacityCurve.Points = MedicRequestOpacityPointList;
	MedicRequestMoveCurve.Points = MedicRequestMovePointList;
	MedicRequestScaleCurve.Points = MedicRequestScalePointList;
}

simulated function Destroyed()
{
	Super.Destroyed();
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (TurboHUD == None || Level.GRI == None || !Level.GRI.bMatchHasBegun)
	{
		return;
	}

	UpdatePlayerInfoList(DeltaTime);
}

final simulated function UpdatePlayerInfoList(float DeltaTime)
{
	if (ShouldRefreshPlayerInfoList(DeltaTime))
	{
		RefreshPlayerInfoList(DeltaTime);
		NextPawnCollectionTime = Level.TimeSeconds + 0.1f;
	}

	if (Level.TimeSeconds > NextPawnCollectionTime)
	{
		UpdatePlayerInfoPawns(DeltaTime);
		NextPawnCollectionTime = Level.TimeSeconds + 0.5f;
	}

	TickPlayerInfoList(DeltaTime);
}

//Returns true if we've detected some sort of diff in GameReplicationInfo::PRIArray.
//Can return true even if player list is technically the same due to the scoreboard sorting the PRIArray. 
simulated function bool ShouldRefreshPlayerInfoList(float DeltaTime)
{
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;
	local int Index, PlayerInfoIndex;
	local bool bFoundAll, bFoundNew;

	PRIArray = Level.GRI.PRIArray;

	//Always refresh if the length has changed.
	if (LastPlayerStateListLength != PRIArray.Length)
	{
		LastPlayerStateListLength = PRIArray.Length;
		return true;
	}

	PlayerInfoIndex = 0;
	bFoundNew = false;

	//This is a weird but quick way to check if our list has changed or not.
	//Assumes both GameReplicationInfo::PRIArray and PlayerInfoDataList are in the same order.
	for (Index = 0; Index < PRIArray.Length; Index++)
	{
		PRI = PRIArray[Index];

		if (PRI == None || PRI.bOnlySpectator || PRI.bIsSpectator || (!bAllowSelfForDebug && TurboHUD.PlayerOwner.PlayerReplicationInfo == PRI))
		{
			continue;
		}

		if (PlayerInfoDataList.Length <= PlayerInfoIndex)
		{
			bFoundNew = true;
			break;
		}

		if (PlayerInfoDataList[PlayerInfoIndex].TPRI == PRI)
		{
			PlayerInfoIndex++;
			continue;
		}
		
		bFoundNew = true;
		break;
	}

	bFoundAll = PlayerInfoDataList.Length == PlayerInfoIndex;

	return !bFoundAll || bFoundNew;
}

//Updates PlayerInfoDataList, removing no longer valid entries and adding newly found ones. 
//Returns true if we added a new entry to the PlayerInfoDataList.
simulated function bool RefreshPlayerInfoList(float DeltaTime)
{
	local array<PlayerReplicationInfo> PRIArray;
	local PlayerReplicationInfo PRI;
	local int Index, PlayerInfoIndex;
	local bool bFoundEntry, bAddedNewEntry;

	bAddedNewEntry = false;
	PRIArray = Level.GRI.PRIArray;

	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		PRI = PlayerInfoDataList[PlayerInfoIndex].TPRI;

		if (PRI == None || PRI.bOnlySpectator || PRI.bIsSpectator )
		{
			PlayerInfoDataList.Remove(PlayerInfoIndex, 1);
			continue;
		}
	}

	for (Index = 0; Index < PRIArray.Length; Index++)
	{
		PRI = PRIArray[Index];

		if (PRI == None || PRI.bOnlySpectator || PRI.bIsSpectator || (!bAllowSelfForDebug && TurboHUD.PlayerOwner.PlayerReplicationInfo == PRI))
		{
			continue;
		}
		
		bFoundEntry = false;
		for (PlayerInfoIndex = 0; PlayerInfoIndex < PlayerInfoDataList.Length; PlayerInfoIndex++)
		{
			if (PlayerInfoDataList[PlayerInfoIndex].TPRI == PRI)
			{
				bFoundEntry = true;
				break;
			}
		}

		if (bFoundEntry)
		{
			continue;
		}

		PlayerInfoDataList.Length = PlayerInfoDataList.Length + 1;
		PlayerInfoDataList[PlayerInfoDataList.Length - 1].TPRI = TurboPlayerReplicationInfo(PRI);
		PlayerInfoDataList[PlayerInfoDataList.Length - 1].Entry = new PlayerInfoEntryClass();
		bAddedNewEntry = true;
	}

	return bAddedNewEntry;
}

//Attempts to collect pawns around the player and relate them to entries in PlayerInfoDataList.
simulated function UpdatePlayerInfoPawns(float DeltaTime)
{
	local TurboHumanPawn Pawn;
	local PlayerReplicationInfo PRI;
	local int PlayerInfoIndex;

	foreach CollidingActors(Class'TurboHumanPawn', Pawn, TurboHUD.HealthBarCutoffDist, TurboHUD.PlayerOwner.CalcViewLocation)
	{
		if (Pawn.bDeleteMe || Pawn.Health <= 0)
		{
			continue;
		}

		PRI = Pawn.PlayerReplicationInfo;

		if (PRI == None || (!bAllowSelfForDebug && TurboHUD.PlayerOwner.PlayerReplicationInfo == PRI) || PRI.bOnlySpectator || PRI.bIsSpectator)
		{
			continue;
		}

		Pawn.bNoTeamBeacon = true;

		for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
		{
			if (PlayerInfoDataList[PlayerInfoIndex].HumanPawn != None || PlayerInfoDataList[PlayerInfoIndex].TPRI != PRI)
			{
				continue;
			}
			
			PlayerInfoDataList[PlayerInfoIndex].HumanPawn = Pawn;
			break;
		}
	}
}

//Ticks all PlayerInfoDataList entries. Also responsible for maintaining PlayerInfoDataDistanceOrderList for depth sorting.
simulated function TickPlayerInfoList(float DeltaTime)
{
	local int Index, TestIndex;
	local bool bInserted;

    for (Index = 0; Index < PlayerInfoDataList.Length; Index++)
	{
		if (PlayerInfoDataList[Index].HumanPawn != None)
		{
			PlayerInfoDataList[Index].Entry.DistanceSquared = VSizeSquared(TurboHUD.PlayerOwner.CalcViewLocation - PlayerInfoDataList[Index].HumanPawn.Location);
		}
		else
		{
			PlayerInfoDataList[Index].Entry.DistanceSquared = Square(TurboHUD.HealthBarCutoffDist);
		}
		
		if (PlayerInfoDataList[Index].TPRI != None)
		{
			PlayerInfoDataList[Index].Entry.ConnectionState = PlayerInfoDataList[Index].TPRI.GetConnectionState();
		}
		
		PlayerInfoDataList[Index].Entry.Tick(DeltaTime, PlayerInfoDataList[Index]);
	}
	
	//Rebuild depth-sorted index list.
	PlayerInfoDataDistanceOrderList.Length = 0;
    for (Index = 0; Index < PlayerInfoDataList.Length; Index++)
    {
		bInserted = false;
		for (TestIndex = 0; TestIndex < PlayerInfoDataDistanceOrderList.Length; TestIndex++)
		{	
			if (PlayerInfoDataList[Index].Entry.DistanceSquared > PlayerInfoDataList[PlayerInfoDataDistanceOrderList[TestIndex]].Entry.DistanceSquared)
			{
				PlayerInfoDataDistanceOrderList.Insert(TestIndex, 1);
				PlayerInfoDataDistanceOrderList[TestIndex] = Index;
				bInserted = true;
				break;
			}
		}

		if (!bInserted)
		{
			PlayerInfoDataDistanceOrderList.Length = PlayerInfoDataDistanceOrderList.Length + 1;
			PlayerInfoDataDistanceOrderList[PlayerInfoDataDistanceOrderList.Length - 1] = Index;
		}
    }
}

static final simulated function bool ShouldDrawPlayerInfo(vector CameraPosition, vector CameraDirection, PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.TPRI == None || PlayerInfo.HumanPawn == None || PlayerInfo.Entry == None)
	{
		return false;
	}
		
	if (PlayerInfo.HumanPawn.FastTrace(PlayerInfo.HumanPawn.Location, CameraPosition))
	{
		PlayerInfo.Entry.VisibilityFade = 1.f;
	}

	if (PlayerInfo.Entry.CurrentHealth <= 0)
	{
		return false;
	}

	if ((Normal(PlayerInfo.HumanPawn.Location - CameraPosition) Dot CameraDirection) < 0.f )
	{
		return false;
	}
	
	return true;
}

final simulated function bool IsHoldingMedicGun()
{
	return KFMedicGun(GetWeapon()) != None;
}

simulated function Render(Canvas C)
{
	local int Index, PlayerInfoIndex;
	local vector CamPos, ViewDir, ScreenPos;
	local rotator CamRot;
	local KFHumanPawn HumanPawn;

	if (TurboHUD == None || Level.GRI == None)
	{
		return;
	}

	Super.Render(C);

	// Grab our View Direction
	C.GetCameraLocation(CamPos,CamRot);
	ViewDir = vector(CamRot);

	//Sample indices from PlayerInfoDataDistanceOrderList instead of directly iterating so draws are depth-ordered.
	for (Index = PlayerInfoDataDistanceOrderList.Length - 1; Index >= 0; Index--)
	{
		PlayerInfoIndex = PlayerInfoDataDistanceOrderList[Index];
		HumanPawn = PlayerInfoDataList[PlayerInfoIndex].HumanPawn;

		if (HumanPawn == None)
		{
			continue;
		}

		if (!ShouldDrawPlayerInfo(CamPos, ViewDir, PlayerInfoDataList[PlayerInfoIndex]))
		{
			continue;
		}

		if (PlayerInfoDataList[PlayerInfoIndex].Entry.VisibilityFade <= 0.f)
		{
			continue;
		}

		if (HumanPawn.Health <= 0.f)
		{
			continue;
		}

		ScreenPos = C.WorldToScreen(HumanPawn.Location + (vect(0,0,1) * HumanPawn.CollisionHeight));
		
		if (ScreenPos.X >= 0 && ScreenPos.Y >= 0 && ScreenPos.X <= C.ClipX && ScreenPos.Y <= C.ClipY)
		{
			DrawPlayerInfo(C, PlayerInfoDataList[PlayerInfoIndex], ScreenPos.X, ScreenPos.Y);
		}
	}

	if (class'V_FieldMedic'.static.IsFieldMedic(TurboHUD.KFPRI) || IsHoldingMedicGun())
	{
		DrawMedicPlayerInfo(C);
	}
	
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
}

simulated function OnScreenSizeChange(Canvas C, Vector2D CurrentClipSize, Vector2D PreviousClipSize)
{
	FontSizeOffset = 0;

	if (CurrentClipSize.Y <= 1440)
	{
		FontSizeOffset++;
	}

	if (CurrentClipSize.Y <= 1080)
	{
		FontSizeOffset++;
	}

	if (CurrentClipSize.Y <= 820)
	{
		FontSizeOffset++;
	}
}

final simulated function DrawPlayerInfo(Canvas C, PlayerInfoData PlayerInfo, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL, TempX, TempY, TempSize, TempStartSize;
	local float Dist, OffsetX;
	local byte BeaconAlpha,Counter;
	local float OldZ;
	local Material TempMaterial, TempStarMaterial;
	local byte i, TempLevel;

	if (PlayerInfo.TPRI.bViewingMatineeCinematic)
	{
		return;
	}

	Dist = VSize(PlayerInfo.HumanPawn.Location - TurboHUD.PlayerOwner.CalcViewLocation);
	Dist -= TurboHUD.HealthBarFullVisDist;
	Dist = FClamp(Dist, 0, TurboHUD.HealthBarCutoffDist - TurboHUD.HealthBarFullVisDist);
	Dist = Dist / (TurboHUD.HealthBarCutoffDist - TurboHUD.HealthBarFullVisDist);
	BeaconAlpha = byte((1.f - Dist) * 255.f);
	BeaconAlpha = byte(255.f * FMin(PlayerInfo.Entry.VisibilityFade * 2.f, 1.f));

	if (BeaconAlpha == 0)
	{
		return;
	}

	OldZ = C.Z;
	C.Z = 1.0;
	C.Style = TurboHUD.ERenderStyle.STY_Alpha;

	OffsetX = TurboHUD.BarLength * 0.5f;

	C.Font = TurboHUD.GetConsoleFont(C);
	class'SRScoreBoard'.Static.TextSizeCountry(C, PlayerInfo.TPRI, XL, YL);
	TempX = ScreenLocX - (XL * 0.5);
	TempY = ScreenLocY - (YL * 1.f);
	TempX = int(TempX);
	TempY = int(TempY);
	ScreenLocY -= YL * 1.25f;

	ScreenLocX = int(ScreenLocX);
	ScreenLocY = int(ScreenLocY);

	if (class<SRVeterancyTypes>(PlayerInfo.TPRI.ClientVeteranSkill) != None && PlayerInfo.TPRI.ClientVeteranSkill.default.OnHUDIcon != None)
	{
		TempSize = 24.f * TurboHUD.VeterancyMatScaleFactor;

		TempX = ScreenLocX + (TurboHUD.BarLength * 0.5f);
		TempX = TempX + (TempSize * 0.25f);
		TempY = (ScreenLocY - (TempSize * 0.5f));
		
		C.SetPos(TempX - (TempSize * 0.125f), TempY - (TempSize * 0.125f));
		C.DrawColor = BarBackplateColor;
		C.DrawColor.A = int(float(BeaconAlpha) * 0.5f);
		C.DrawTile(PerkBackplate, TempSize * 1.25f, TempSize * 1.25f, 0, 0, PerkBackplate.MaterialUSize(), PerkBackplate.MaterialVSize());

		C.SetPos(TempX, TempY);
		TempLevel = class<SRVeterancyTypes>(PlayerInfo.TPRI.ClientVeteranSkill).Static.PreDrawPerk(C, PlayerInfo.TPRI.ClientVeteranSkillLevel, TempMaterial, TempStarMaterial);
		C.DrawColor.A = BeaconAlpha;
		C.DrawTile(TempMaterial, TempSize, TempSize, 0, 0, TempMaterial.MaterialUSize(), TempMaterial.MaterialVSize());

		TempStartSize = TempSize * 0.175f;

		TempX += (TempSize * 0.8f);
		TempY += (TempSize - (TempStartSize * 1.5f));

		for (i = 0; i < TempLevel; i++)
		{
			C.SetPos(TempX, TempY - (Counter * TempStartSize));
			C.DrawTile(TempStarMaterial, TempStartSize, TempStartSize, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			if (++Counter == 5)
			{
				Counter = 0;
				TempX+=TurboHUD.VetStarSize;
			}
		}
	}

	TempX = ScreenLocX - (XL * 0.5);
	TempY = ScreenLocY + (TurboHUD.BarHeight * 0.5f) - (YL * 0.125f);
	TempX = int(TempX);
	TempY = int(TempY);
	C.SetDrawColor(0, 0, 0);
	C.DrawColor.A = byte(0.75f * float(BeaconAlpha));
	class'SRScoreBoard'.Static.DrawCountryName(C, PlayerInfo.TPRI, TempX + 2.f, TempY + 2.f);
	C.SetDrawColor(255, 255, 255);
	C.DrawColor.A = BeaconAlpha;
	class'SRScoreBoard'.Static.DrawCountryName(C, PlayerInfo.TPRI, TempX, TempY);

	TempX = int(ScreenLocX - (TurboHUD.BarHeight * 2.5f));
	TempY = int(ScreenLocY - (TurboHUD.BarHeight * 0.75f));

	if (PlayerInfo.Entry.PreviousShield > 0.f || PlayerInfo.Entry.CurrentShield > 0.f)
	{
		TempY -= TurboHUD.BarHeight;
	}

	if (PlayerInfo.HumanPawn.bIsTyping)
	{
		TempY -= (TurboHUD.BarHeight * 5.f);
		C.SetPos(TempX, TempY);
		C.DrawRect(ChatIcon, TurboHUD.BarHeight * 5.f, TurboHUD.BarHeight * 5.f);
	}

	if (PlayerInfo.HumanPawn.IsShopping())
	{
		TempY -= (TurboHUD.BarHeight * 5.f);
		C.SetPos(TempX, TempY);
		C.DrawRect(ShoppingIcon, TurboHUD.BarHeight * 5.f, TurboHUD.BarHeight * 5.f);
	}

	if (PlayerInfo.Entry.ConnectionState != Normal)
	{
		TempY -= (TurboHUD.BarHeight * 2.5f);
		C.SetPos(TempX + TurboHUD.BarHeight * 1.25f, TempY);

		switch (PlayerInfo.Entry.ConnectionState)
		{
			case PoorConnection:
				C.DrawRect(PoorSignalIcon, TurboHUD.BarHeight * 2.5f, TurboHUD.BarHeight * 2.5f);
				break;
			case NoConnection:
				C.DrawRect(NoSignalIcon, TurboHUD.BarHeight * 2.5f, TurboHUD.BarHeight * 2.5f);
				break;
		}
	}

	// Health
	DrawHealthBar(C, ScreenLocX, ScreenLocY, BeaconAlpha, PlayerInfo.Entry);
		
	// Armor
	if (PlayerInfo.Entry.PreviousShield > 0.f || PlayerInfo.Entry.CurrentShield > 0.f)
	{
		DrawShieldBar(C, ScreenLocX, ScreenLocY, BeaconAlpha, PlayerInfo.Entry);
	}

	// Hit Effect
	if (PlayerInfo.Entry.LastHit.Ratio < 1.f)
	{
		DrawHitEffect(C, ScreenLocX, ScreenLocY, BeaconAlpha, PlayerInfo.Entry);
	}

	C.Z = OldZ;
}

final simulated function DrawHealthBar(Canvas C, float ScreenLocX, float ScreenLocY, byte BeaconAlpha, TurboHUDPlayerInfoEntry Entry)
{
	DrawBackplate(C, ScreenLocX, ScreenLocY, BeaconAlpha, 1.f);

	if (Entry.PreviousHealToHealth > 0.f && Entry.PreviousHealToHealth > Entry.CurrentHealth)
	{
		HealToHealthBarColor.A = byte(float(default.HealToHealthBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX + FMax((TurboHUD.BarLength * (Entry.CurrentHealth - 0.01f)), 0.f), ScreenLocY, FClamp((Entry.PreviousHealToHealth - Entry.CurrentHealth) + 0.01f, 0, 1), HealToHealthBarColor, 1.f);
	}

	if (Entry.PreviousHealth > Entry.CurrentHealth)
	{
		HealthLossBarColor.A = byte(float(default.HealthLossBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX + FMax((TurboHUD.BarLength * (Entry.CurrentHealth - 0.01f)), 0.f), ScreenLocY, FClamp((Entry.PreviousHealth - Entry.CurrentHealth) + 0.01f, 0, 1), HealthLossBarColor, 1.f);
	}

	if (Entry.CurrentHealth > 0.f )
	{
		HealthBarColor.A = byte(float(default.HealthBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX, ScreenLocY, FClamp(Entry.CurrentHealth, 0, 1), HealthBarColor, 1.f);
	}
}

final simulated function DrawShieldBar(Canvas C, float ScreenLocX, float ScreenLocY, byte BeaconAlpha, TurboHUDPlayerInfoEntry Entry)
{
	DrawBackplate(C, ScreenLocX, ScreenLocY - (TurboHUD.BarHeight + 2.f), BeaconAlpha, 0.5f);
	
	if (Entry.PreviousShield > Entry.CurrentShield)
	{
		ShieldLossBarColor.A = byte(float(default.ShieldLossBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX + FMax((TurboHUD.BarLength * (Entry.CurrentShield - 0.01f)), 0.f), ScreenLocY - (TurboHUD.BarHeight + 2.f), FClamp((Entry.PreviousShield - Entry.CurrentShield) + 0.01f, 0, 1), ShieldLossBarColor, 0.5f);
	}
	
	if (Entry.CurrentShield > 0.f)
	{
		ShieldBarColor.A = byte(float(default.ShieldBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX, ScreenLocY - (TurboHUD.BarHeight + 2.f), FClamp(Entry.CurrentShield, 0, 1), ShieldBarColor, 0.5f);
	}
}

final simulated function DrawHitEffect(Canvas C, float ScreenLocX, float ScreenLocY, byte BeaconAlpha, TurboHUDPlayerInfoEntry Entry)
{
	local float LastHitScale;
	local float LastHitAlpha;

	LastHitScale = 1.f - ((Entry.LastHit.Ratio - 1.f) ** 4.f);
	LastHitAlpha = 1.f - (((2.f * Entry.LastHit.Ratio) - 1.f) ** 4.f);
	LastHitAlpha *= (float(BeaconAlpha) / 255.f);
	LastHitAlpha *= (float(HealthHitBarColor.A) / 255.f);
	
	C.DrawColor = HealthHitBarColor;
	C.DrawColor.A = (LastHitAlpha * 255.f);
	C.SetPos((ScreenLocX - (0.5 * TurboHUD.BarLength)) + (TurboHUD.BarLength * FClamp(Entry.CurrentHealth, 0, 1)), (ScreenLocY - (TurboHUD.BarHeight * 0.5f)) - (0.25f * TurboHUD.BarHeight * (LastHitScale * 1.f)));
	C.DrawTileStretched(TurboHUD.WhiteMaterial, (TurboHUD.BarLength * Entry.LastHit.HitAmount * 1.1f) + ((TurboHUD.BarLength * 0.05f) / Entry.LastHit.FadeRate), TurboHUD.BarHeight * (1.f + (LastHitScale * 0.5f)));
}

final simulated function DrawBackplate(Canvas C, float XCentre, float YCentre, byte Alpha, float HeightScale)
{
	BarBackplateColor.A = int(float(default.BarBackplateColor.A) * (float(Alpha) / 255.f));
	C.DrawColor = BarBackplateColor;
	C.SetPos(XCentre - 0.5 * TurboHUD.BarLength, YCentre - (0.5 * TurboHUD.BarHeight * HeightScale));
	C.DrawTileStretched(TurboHUD.WhiteMaterial, TurboHUD.BarLength, TurboHUD.BarHeight * HeightScale);
}

final simulated function DrawBar(Canvas C, float XCentre, float YCentre, float BarPercentage, color Color, float HeightScale)
{
	C.DrawColor = Color;
	C.SetPos(XCentre - 0.5 * TurboHUD.BarLength, YCentre - (0.5 * TurboHUD.BarHeight * HeightScale));
	C.DrawTileStretched(TurboHUD.WhiteMaterial, TurboHUD.BarLength * BarPercentage, TurboHUD.BarHeight * HeightScale);
}

simulated function StartVoiceSupportNotification(PlayerReplicationInfo Sender)
{
	local int PlayerInfoIndex;
	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		if (PlayerInfoDataList[PlayerInfoIndex].TPRI == Sender)
		{
			PlayerInfoDataList[PlayerInfoIndex].Entry.VoiceSupportAnim = 1.f;
			break;
		}
	}
}

simulated function StartVoiceAlertNotification(PlayerReplicationInfo Sender)
{
	local int PlayerInfoIndex;
	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		if (PlayerInfoDataList[PlayerInfoIndex].TPRI == Sender)
		{
			PlayerInfoDataList[PlayerInfoIndex].Entry.VoiceAlertAnim = 1.f;
			break;
		}
	}
}

simulated function ReceivedVoiceMessage(PlayerReplicationInfo Sender, Name MessageType, byte MessageIndex, optional Pawn SoundSender, optional vector SenderLocation)
{
	if (MessageType == 'SUPPORT' && (MessageIndex == 0 || MessageIndex == 1))
	{
		StartVoiceSupportNotification(Sender);
	}
	else if (MessageType == 'ALERT' && (MessageIndex == 0 || MessageIndex == 1))
	{
		StartVoiceAlertNotification(Sender);
	}
}

simulated function DrawMedicPlayerInfo(Canvas C)
{
	local int PlayerInfoIndex;
	local float TextSizeX, TextSizeY, HealthTextSizeX;
	local float MinEntrySizeX, EntrySizeY, HealthOffsetX;
	local float TempX, TempY;
	local string PlayerName;
	local float AnimTime;
	local bool bIsMedicAlert;
	local Texture Icon;
	local byte AlertOpacity;
	local float AlertScale;
	local float HealthPercent;
	local TurboHUDPlayerInfoEntry PlayerInfoEntry;
	local string HealthString;
	
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.LoadFont(3 + FontSizeOffset);

	if (TurboHUD.bShowScoreBoard)
	{
		return;
	}

	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		if (PlayerInfoDataList[PlayerInfoIndex].TPRI == None)
		{
			continue;
		}

		C.TextSize(Left(PlayerInfoDataList[PlayerInfoIndex].TPRI.PlayerName, 12), TextSizeX, TextSizeY);
		MinEntrySizeX = FMax(TextSizeX, MinEntrySizeX);
		EntrySizeY = FMax(TextSizeY, EntrySizeY);
	}

	C.TextSize("000HP", HealthTextSizeX, TextSizeY);
	MinEntrySizeX += (float(C.SizeX) * 0.02f) + (HealthTextSizeX * 1.5);
	EntrySizeY += (float(C.SizeY) * 0.0035f);
	HealthOffsetX = HealthTextSizeX * 0.25f;
	
	TempX = C.ClipX;
	TempY = C.ClipY * (1.f - (class'TurboHUDPlayer'.default.CashBackplateSize.Y + (class'TurboHUDPlayer'.default.BackplateSpacing.Y * 2.f)));

	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		PlayerInfoEntry = PlayerInfoDataList[PlayerInfoIndex].Entry;

		if (PlayerInfoEntry == None || PlayerInfoEntry.CurrentHealth <= 0.f)
		{
			continue;
		}

		HealthPercent = PlayerInfoEntry.PreviousHealth;

		C.FontScaleX = 1.f;
		C.FontScaleY = 1.f;

		C.SetDrawColor(0, 0, 0, 120);
		C.SetPos((TempX + EntrySizeY) - MinEntrySizeX, TempY - EntrySizeY);
		C.DrawTileStretched(MedicBackplate, (MinEntrySizeX - EntrySizeY) + 4.f, EntrySizeY);

		PlayerName = Left(PlayerInfoDataList[PlayerInfoIndex].TPRI.PlayerName, 12);

		C.SetDrawColor(255, 255, 255, 255);
		C.TextSize(PlayerName, TextSizeX, TextSizeY);
		C.SetPos(TempX - (TextSizeX + 10.f), TempY - ((EntrySizeY * 0.5f) + (TextSizeY * 0.5f)));
		C.DrawTextClipped(PlayerName);
		
		HealthString = FillStringWithZeroes(Min(int(HealthPercent * PlayerInfoEntry.GetHealthMax(PlayerInfoDataList[PlayerInfoIndex])), 999), 3);
		C.SetPos((TempX - MinEntrySizeX) + EntrySizeY + HealthOffsetX, (TempY - (EntrySizeY * 0.5f)) - (TextSizeY * 0.5f));
		DrawTextMeticulous(C, HealthString $ class'TurboHUDScoreboard'.default.HealthyString, HealthTextSizeX);

		if (PlayerInfoEntry.VoiceSupportAnim > 0.f)
		{
			Icon = MedicIcon;
			C.SetDrawColor(255, 0, 0);
		}
		else
		{
			Icon = AlertIcon;
			C.SetDrawColor(255, 215, 0);
		}

		AnimTime = 1.f - FMax(PlayerInfoEntry.VoiceSupportAnim, PlayerInfoEntry.VoiceAlertAnim);
		if (AnimTime < 1.f)	
		{
			AlertOpacity = Round(InterpCurveEval(MedicRequestOpacityCurve, AnimTime) * 225.f);
			C.DrawColor.A = AlertOpacity;

			AlertScale = InterpCurveEval(MedicRequestScaleCurve, AnimTime);
			C.SetPos(((TempX - MinEntrySizeX) + EntrySizeY + (InterpCurveEval(MedicRequestMoveCurve, AnimTime) * -8.f)) - (EntrySizeY * AlertScale), TempY - (EntrySizeY * Lerp(0.5f, 1.f, AlertScale)));
			C.DrawRect(Icon, EntrySizeY * AlertScale, EntrySizeY * AlertScale);
		}

		TempY -= EntrySizeY + 2.f;
	}
}

defaultproperties
{
	PlayerInfoEntryClass=class'TurboHUDPlayerInfoEntry'

	PerkBackplate=Texture'KFTurbo.HUD.PerkBackplate_D'

	HealthBarColor=(R=232,G=41,B=41,A=255)
	HealthLossBarColor=(R=222,G=171,B=47,A=255)
	HealthHitBarColor=(R=222,G=171,B=47,A=215)
	HealToHealthBarColor=(R=44,G=255,B=24,A=120)

	ShieldBarColor=(R=27,G=181,B=213,A=255)
	ShieldLossBarColor=(R=50,G=140,B=180,A=200)

	BarBackplateColor=(R=16,G=16,B=16,A=255)

	ChatIcon=Texture'KFTurbo.HUD.ChatIcon_a00'
	ShoppingIcon=Texture'KFTurbo.HUD.ShopIcon_a01'
	PoorSignalIcon=Texture'KFTurbo.HUD.LowSignal_a01'
	NoSignalIcon=Texture'KFTurbo.HUD.NoSignal_a01'

	MedicBackplate=Texture'KFTurbo.HUD.ContainerSquare_D'
	AlertIcon=Texture'KFTurbo.HUD.Alert_D'
	MedicIcon=Texture'KFTurbo.HUD.Medic_D'

	MedicRequestOpacityPointList(0)=(InVal=0.0,OutVal=0)
	MedicRequestOpacityPointList(1)=(InVal=0.05,OutVal=1)
	MedicRequestOpacityPointList(2)=(InVal=0.1,OutVal=0)
	MedicRequestOpacityPointList(3)=(InVal=0.15,OutVal=1)
	MedicRequestOpacityPointList(4)=(InVal=0.2,OutVal=0)
	MedicRequestOpacityPointList(5)=(InVal=0.25,OutVal=1)
	MedicRequestOpacityPointList(6)=(InVal=0.3,OutVal=0)
	MedicRequestOpacityPointList(7)=(InVal=0.35,OutVal=1)
	MedicRequestOpacityPointList(8)=(InVal=0.9,OutVal=1)
	MedicRequestOpacityPointList(9)=(InVal=1.0,OutVal=0)

	MedicRequestMovePointList(0)=(InVal=0.0,OutVal=0.5)
	MedicRequestMovePointList(1)=(InVal=0.025,OutVal=0)
	MedicRequestMovePointList(2)=(InVal=1.0,OutVal=0)

	MedicRequestScalePointList(0)=(InVal=0.0,OutVal=1.4)
	MedicRequestScalePointList(1)=(InVal=0.1,OutVal=1)
	MedicRequestScalePointList(2)=(InVal=1.0,OutVal=1)

	bAllowSelfForDebug=false
}