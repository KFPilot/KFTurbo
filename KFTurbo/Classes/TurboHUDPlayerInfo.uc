//Killing Floor Turbo TurboHUDPlayerInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDPlayerInfo extends TurboHUDOverlay
    hidecategories(Advanced,Collision,Display,Events,Force,Karma,LightColor,Lighting,Movement,Object,Sound);

struct PlayerInfoHitData
{
	var float HitAmount;
	var float Ratio;
	var float FadeRate;
};

struct PlayerInfoData
{
	var TurboPlayerReplicationInfo TPRI;
	var TurboHumanPawn HumanPawn;
	var float DistanceSquared;
	var TurboPlayerReplicationInfo.EConnectionState ConnectionState;
	
	var float CurrentHealth;
	var float LastCheckedHealth;
	var float PreviousHealth;
	
	var float CurrentHealToHealth;
	var float PreviousHealToHealth;

	var float CurrentShield;
	var float PreviousShield;

	var PlayerInfoHitData LastHit;
	var bool bInitialized;
	var float VisibilityFade;

	var float VoiceSupportAnim;
	var float VoiceAlertAnim;
};

var array<PlayerInfoData> PlayerInfoDataList;
var float PlayerCollectionTime;

var() float HealthInterpRate;
var() float ShieldInterpRate;

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
var Texture MedicCap;

var InterpCurve MedicRequestOpacityCurve;
var array<InterpCurvePoint> MedicRequestOpacityPointList;
var InterpCurve MedicRequestMoveCurve;
var array<InterpCurvePoint> MedicRequestMovePointList;
var InterpCurve MedicRequestScaleCurve;
var array<InterpCurvePoint> MedicRequestScalePointList;

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	Super.Initialize(OwnerHUD);
	MedicRequestOpacityCurve.Points = MedicRequestOpacityPointList;
	MedicRequestMoveCurve.Points = MedicRequestMovePointList;
	MedicRequestScaleCurve.Points = MedicRequestScalePointList;
}

static final simulated function float GetHealthMax(PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		return PlayerInfo.HumanPawn.HealthMax;
	}

	if (PlayerInfo.TPRI != None)
	{
		return PlayerInfo.TPRI.HealthMax;
	}

	return 100.f;
}

static final simulated function float GetHealth(PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		return FClamp(float(PlayerInfo.HumanPawn.Health) / PlayerInfo.HumanPawn.HealthMax, 0.f, 1.f);
	}

	if (PlayerInfo.TPRI != None)
	{
		if (PlayerInfo.TPRI.PlayerHealth <= 0.f)
		{
			return 0.f;
		}

		return FClamp(float(PlayerInfo.TPRI.PlayerHealth) / float(PlayerInfo.TPRI.HealthMax), 0.f, 1.f);
	}

	return 0.f;
}

static final simulated function float GetHealthHealingTo(PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		if (PlayerInfo.HumanPawn.HealthHealingTo == -1)
		{
			return 0.f;
		}

		return FClamp(float(PlayerInfo.HumanPawn.HealthHealingTo) / PlayerInfo.HumanPawn.HealthMax, 0.f, 1.f);
	}

	return 0.f;
}

static final simulated function float GetShield(PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.HumanPawn != None)
	{
		return PlayerInfo.HumanPawn.ShieldStrength / 100.f;
	}

	return float(PlayerInfo.TPRI.ShieldStrength) / 100.f;
}

simulated final function TickPlayerInfo(float DeltaTime, out PlayerInfoData PlayerInfo)
{
	local float Value;
	Value = GetHealth(PlayerInfo);
	PlayerInfo.CurrentHealth = Value;
	Value = GetShield(PlayerInfo);
	PlayerInfo.CurrentShield = Value;
	Value = GetHealthHealingTo(PlayerInfo);
	PlayerInfo.CurrentHealToHealth = Value;

	PlayerInfo.VisibilityFade = FMax(PlayerInfo.VisibilityFade - DeltaTime, 0.f);

	if (!PlayerInfo.bInitialized)
	{
		PlayerInfo.LastCheckedHealth = PlayerInfo.CurrentHealth;
		PlayerInfo.PreviousHealth = PlayerInfo.CurrentHealth;
		PlayerInfo.PreviousShield = PlayerInfo.CurrentShield;
		PlayerInfo.PreviousHealToHealth = PlayerInfo.CurrentHealToHealth;
		PlayerInfo.LastHit.Ratio = 1.f; //Mark as done playing.
		PlayerInfo.bInitialized = true;
		return;
	}

	if (PlayerInfo.VoiceSupportAnim > 0.f)
	{
		PlayerInfo.VoiceSupportAnim = FMax(PlayerInfo.VoiceSupportAnim - (DeltaTime * 0.5f), 0.f);
	}

	if (PlayerInfo.VoiceAlertAnim > 0.f)
	{
		PlayerInfo.VoiceAlertAnim = FMax(PlayerInfo.VoiceAlertAnim - DeltaTime, 0.f);
	}

	if (PlayerInfo.LastHit.Ratio < 1.f)
	{
		PlayerInfo.LastHit.Ratio += PlayerInfo.LastHit.FadeRate * DeltaTime;
		PlayerInfo.LastHit.Ratio = FMin(PlayerInfo.LastHit.Ratio, 1.f);
	}

	if (PlayerInfo.CurrentHealth != PlayerInfo.LastCheckedHealth)
	{
		if (PlayerInfo.CurrentHealth < PlayerInfo.LastCheckedHealth)
		{
			InitializeHitData(PlayerInfo);
		}
		PlayerInfo.LastCheckedHealth = PlayerInfo.CurrentHealth;
	}

	if (PlayerInfo.CurrentHealth < PlayerInfo.PreviousHealth)
	{
		PlayerInfo.PreviousHealth = Lerp(default.HealthInterpRate * DeltaTime, PlayerInfo.PreviousHealth, PlayerInfo.CurrentHealth);

		if (Abs(PlayerInfo.PreviousHealth - PlayerInfo.CurrentHealth) < 0.01f)
		{
			PlayerInfo.PreviousHealth = PlayerInfo.CurrentHealth;
		}
	}
	else if (PlayerInfo.CurrentHealth > PlayerInfo.PreviousHealth)
	{
		PlayerInfo.PreviousHealth = PlayerInfo.CurrentHealth;
	}

	if (PlayerInfo.CurrentHealToHealth <= 0.f)
	{
		PlayerInfo.PreviousHealToHealth = PlayerInfo.CurrentHealToHealth;
	}
	else if (PlayerInfo.CurrentHealToHealth != PlayerInfo.PreviousHealToHealth)
	{
		PlayerInfo.PreviousHealToHealth = Lerp(default.HealthInterpRate * 4.f * DeltaTime, FMax(PlayerInfo.PreviousHealToHealth, PlayerInfo.CurrentHealth), PlayerInfo.CurrentHealToHealth);

		if (Abs(PlayerInfo.PreviousHealToHealth - PlayerInfo.CurrentHealToHealth) < 0.01f)
		{
			PlayerInfo.PreviousHealToHealth = PlayerInfo.CurrentHealToHealth;
		}
	}

	if (PlayerInfo.CurrentShield < PlayerInfo.PreviousShield)
	{
		PlayerInfo.PreviousShield = Lerp(default.ShieldInterpRate * DeltaTime, PlayerInfo.PreviousShield, PlayerInfo.CurrentShield);

		if (Abs(PlayerInfo.PreviousShield - PlayerInfo.CurrentShield) < 0.01f)
		{
			PlayerInfo.PreviousShield = PlayerInfo.CurrentShield;
		}
	}
	else if (PlayerInfo.CurrentShield > PlayerInfo.PreviousShield)
	{
		PlayerInfo.PreviousShield = PlayerInfo.CurrentShield;
	}
}

simulated final function InitializeHitData(out PlayerInfoData PlayerInfo)
{
	local float NewLostHealth;
	NewLostHealth = PlayerInfo.PreviousHealth - PlayerInfo.CurrentHealth;
	if ( PlayerInfo.LastHit.Ratio >= 1.f )
	{
		PlayerInfo.LastHit.HitAmount = NewLostHealth;
		PlayerInfo.LastHit.FadeRate = Lerp(FMin(NewLostHealth / 0.5f, 1.f), 4.f, 1.f);
		PlayerInfo.LastHit.Ratio = 0.f;
		return;
	}
	
	if (NewLostHealth < PlayerInfo.LastHit.HitAmount * 0.5f && PlayerInfo.LastHit.Ratio < 0.75f)
	{
		return;
	}

	PlayerInfo.LastHit.HitAmount = NewLostHealth;
	PlayerInfo.LastHit.FadeRate = Lerp(FMin(NewLostHealth / 0.5f, 1.f), 4.f, 1.f);
	PlayerInfo.LastHit.Ratio = 0.f;
}

simulated function Tick(float DeltaTime)
{
	local int Index, PlayerInfoIndex;
	local PlayerReplicationInfo PRI;
	local bool bFoundData;
	local PlayerInfoData PlayerInfo;
	local TurboHumanPawn HumanPawn;
	local array<PlayerInfoData> SortedPlayerInfoList;

	if (TurboHUD == None || Level.GRI == None || !Level.GRI.bMatchHasBegun)
	{
		return;
	}
	
	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		PRI = PlayerInfoDataList[PlayerInfoIndex].TPRI;

		if (PRI == None || PRI.bOnlySpectator || PRI.bIsSpectator )
		{
			PlayerInfoDataList.Remove(PlayerInfoIndex, 1);
			continue;
		}
	}
	
	if (Level.TimeSeconds > PlayerCollectionTime)
	{
		PlayerCollectionTime = Level.TimeSeconds + 0.1f;

		foreach CollidingActors(Class'TurboHumanPawn', HumanPawn, TurboHUD.HealthBarCutoffDist, TurboHUD.PlayerOwner.CalcViewLocation)
		{
			PRI = HumanPawn.PlayerReplicationInfo;

			if (PRI == None || TurboHUD.PlayerOwner.PlayerReplicationInfo == PRI || PRI.bOnlySpectator || PRI.bIsSpectator)
			{
				continue;
			}

			HumanPawn.bNoTeamBeacon = true;

			bFoundData = false;
			for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
			{
				if (PlayerInfoDataList[PlayerInfoIndex].TPRI == PRI)
				{
					PlayerInfoDataList[PlayerInfoIndex].DistanceSquared = VSizeSquared(TurboHUD.PlayerOwner.CalcViewLocation - HumanPawn.Location);
					PlayerInfoDataList[PlayerInfoIndex].HumanPawn = HumanPawn;
					bFoundData = true;
					break;
				}
			}

			if (bFoundData)
			{
				continue;
			}

			PlayerInfoIndex = PlayerInfoDataList.Length;
			PlayerInfoDataList.Length = PlayerInfoDataList.Length + 1;
			PlayerInfoDataList[PlayerInfoIndex].TPRI = TurboPlayerReplicationInfo(PRI);
			PlayerInfoDataList[PlayerInfoIndex].HumanPawn = HumanPawn;
			PlayerInfoDataList[PlayerInfoIndex].DistanceSquared = VSizeSquared(TurboHUD.PlayerOwner.CalcViewLocation - HumanPawn.Location);
			PlayerInfoDataList[PlayerInfoIndex].ConnectionState = PlayerInfoDataList[PlayerInfoIndex].TPRI.GetConnectionState();
			PlayerInfoDataList[PlayerInfoIndex].bInitialized = false;
		}
	}
	else
	{
		//Still want to update distance for sorter.
		for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
		{
			HumanPawn = PlayerInfoDataList[PlayerInfoIndex].HumanPawn;

			if (HumanPawn == None)
			{
				continue;
			}

			PlayerInfoDataList[PlayerInfoIndex].DistanceSquared = VSizeSquared(TurboHUD.PlayerOwner.CalcViewLocation - HumanPawn.Location);
			PlayerInfoDataList[PlayerInfoIndex].ConnectionState = PlayerInfoDataList[PlayerInfoIndex].TPRI.GetConnectionState();
		}
	}

	//Sort entries.
	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		bFoundData = false;
		for (Index = 0; Index < SortedPlayerInfoList.Length; Index++)
		{
			if (SortedPlayerInfoList[Index].DistanceSquared < PlayerInfoDataList[PlayerInfoIndex].DistanceSquared)
			{
				continue;
			}

			bFoundData = true;
			SortedPlayerInfoList.Insert(Index, 1);
			SortedPlayerInfoList[Index] = PlayerInfoDataList[PlayerInfoIndex];
			break;
		}

		if (bFoundData)
		{
			continue;
		}

		SortedPlayerInfoList[SortedPlayerInfoList.Length] = PlayerInfoDataList[PlayerInfoIndex];
	}

	PlayerInfoDataList = SortedPlayerInfoList;

	//Tick entries.
	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		if (PlayerInfoDataList[PlayerInfoIndex].TPRI == None)
		{
			PlayerInfoDataList.Remove(PlayerInfoIndex, 1);
			continue;
		}
		
		PlayerInfo = PlayerInfoDataList[PlayerInfoIndex];
		TickPlayerInfo(DeltaTime, PlayerInfo);
		PlayerInfoDataList[PlayerInfoIndex] = PlayerInfo;
	}
}

static final simulated function bool ShouldDrawPlayerInfo(vector CameraPosition, vector CameraDirection, out PlayerInfoData PlayerInfo)
{
	if (PlayerInfo.TPRI == None || PlayerInfo.HumanPawn == None)
	{
		return false;
	}
		
	if (PlayerInfo.HumanPawn.FastTrace(PlayerInfo.HumanPawn.Location, CameraPosition))
	{
		PlayerInfo.VisibilityFade = 1.f;
	}

	if (PlayerInfo.CurrentHealth <= 0)
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
	local int Index;
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

	for (Index = PlayerInfoDataList.Length - 1; Index >= 0; Index--)
	{
		HumanPawn = PlayerInfoDataList[Index].HumanPawn;

		if (HumanPawn == None)
		{
			continue;
		}

		if (!ShouldDrawPlayerInfo(CamPos, ViewDir, PlayerInfoDataList[Index]))
		{
			continue;
		}

		if (PlayerInfoDataList[Index].VisibilityFade <= 0.f)
		{
			continue;
		}

		if (HumanPawn.Health <= 0.f)
		{
			continue;
		}

		ScreenPos = C.WorldToScreen(HumanPawn.Location + (vect(0,0,1) * HumanPawn.CollisionHeight));
		
		if( ScreenPos.X>=0 && ScreenPos.Y>=0 && ScreenPos.X<=C.ClipX && ScreenPos.Y<=C.ClipY )
		{
			DrawPlayerInfo(C, PlayerInfoDataList[Index], ScreenPos.X, ScreenPos.Y);
		}
	}

	if (class'V_FieldMedic'.static.IsFieldMedic(TurboHUD.KFPRI) || IsHoldingMedicGun())
	{
		DrawMedicPlayerInfo(C);
	}
	
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
}

simulated final function DrawPlayerInfo(Canvas C, PlayerInfoData PlayerInfo, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL, TempX, TempY, TempSize, TempStartSize;
	local float Dist, OffsetX;
	local byte BeaconAlpha,Counter;
	local float OldZ;
	local Material TempMaterial, TempStarMaterial;
	local byte i, TempLevel;
	local bool bDrawLostHealth;
	local bool bDrawLostShield;
	local float LastHitScale;
	local float LastHitAlpha;

	if (PlayerInfo.TPRI.bViewingMatineeCinematic)
	{
		return;
	}

	Dist = VSize(PlayerInfo.HumanPawn.Location - TurboHUD.PlayerOwner.CalcViewLocation);
	Dist -= TurboHUD.HealthBarFullVisDist;
	Dist = FClamp(Dist, 0, TurboHUD.HealthBarCutoffDist - TurboHUD.HealthBarFullVisDist);
	Dist = Dist / (TurboHUD.HealthBarCutoffDist - TurboHUD.HealthBarFullVisDist);
	BeaconAlpha = byte((1.f - Dist) * 255.f);
	BeaconAlpha = byte(255.f * FMin(PlayerInfo.VisibilityFade * 2.f, 1.f));

	if ( BeaconAlpha == 0 )
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

		for ( i = 0; i < TempLevel; i++ )
		{
			C.SetPos(TempX, TempY - (Counter * TempStartSize));
			C.DrawTile(TempStarMaterial, TempStartSize, TempStartSize, 0, 0, TempStarMaterial.MaterialUSize(), TempStarMaterial.MaterialVSize());

			if( ++Counter==5 )
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

	if (PlayerInfo.PreviousShield > 0.f || PlayerInfo.CurrentShield > 0.f)
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

	if (PlayerInfo.ConnectionState != Normal)
	{
		TempY -= (TurboHUD.BarHeight * 2.5f);
		C.SetPos(TempX + TurboHUD.BarHeight * 1.25f, TempY);

		switch (PlayerInfo.ConnectionState)
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
	bDrawLostHealth = PlayerInfo.PreviousHealth > PlayerInfo.CurrentHealth;
	DrawBackplate(C, ScreenLocX, ScreenLocY, BeaconAlpha, 1.f);

	if (PlayerInfo.PreviousHealToHealth > 0.f && PlayerInfo.PreviousHealToHealth > PlayerInfo.CurrentHealth)
	{
		HealToHealthBarColor.A = byte(float(default.HealToHealthBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX + FMax((TurboHUD.BarLength * (PlayerInfo.CurrentHealth - 0.01f)), 0.f), ScreenLocY, FClamp((PlayerInfo.PreviousHealToHealth - PlayerInfo.CurrentHealth) + 0.01f, 0, 1), HealToHealthBarColor, 1.f);
	}

	if (bDrawLostHealth)
	{
		HealthLossBarColor.A = byte(float(default.HealthLossBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX + FMax((TurboHUD.BarLength * (PlayerInfo.CurrentHealth - 0.01f)), 0.f), ScreenLocY, FClamp((PlayerInfo.PreviousHealth - PlayerInfo.CurrentHealth) + 0.01f, 0, 1), HealthLossBarColor, 1.f);
	}

	if (PlayerInfo.CurrentHealth > 0.f )
	{
		HealthBarColor.A = byte(float(default.HealthBarColor.A) * (float(BeaconAlpha) / 255.f));
		DrawBar(C, ScreenLocX, ScreenLocY, FClamp(PlayerInfo.CurrentHealth, 0, 1), HealthBarColor, 1.f);
	}
		
	// Armor
	if (PlayerInfo.PreviousShield > 0.f || PlayerInfo.CurrentShield > 0.f)
	{
		bDrawLostShield = PlayerInfo.PreviousShield > PlayerInfo.CurrentShield;
		DrawBackplate(C, ScreenLocX, ScreenLocY - (TurboHUD.BarHeight + 2.f), BeaconAlpha, 0.5f);
		if (bDrawLostShield)
		{
			ShieldLossBarColor.A = byte(float(default.ShieldLossBarColor.A) * (float(BeaconAlpha) / 255.f));
			DrawBar(C, ScreenLocX + FMax((TurboHUD.BarLength * (PlayerInfo.CurrentShield - 0.01f)), 0.f), ScreenLocY - (TurboHUD.BarHeight + 2.f), FClamp((PlayerInfo.PreviousShield - PlayerInfo.CurrentShield) + 0.01f, 0, 1), ShieldLossBarColor, 0.5f);
		}
		
		if ( PlayerInfo.CurrentShield > 0.f )
		{
			ShieldBarColor.A = byte(float(default.ShieldBarColor.A) * (float(BeaconAlpha) / 255.f));
			DrawBar(C, ScreenLocX, ScreenLocY - (TurboHUD.BarHeight + 2.f), FClamp(PlayerInfo.CurrentShield, 0, 1), ShieldBarColor, 0.5f);
		}
	}

	if ( PlayerInfo.LastHit.Ratio < 1.f)
	{
		LastHitScale = 1.f - ((PlayerInfo.LastHit.Ratio - 1.f) ** 4.f);
		LastHitAlpha = 1.f - (((2.f * PlayerInfo.LastHit.Ratio) - 1.f) ** 4.f);
		LastHitAlpha *= (float(BeaconAlpha) / 255.f);
		LastHitAlpha *= (float(HealthHitBarColor.A) / 255.f);
		
		C.DrawColor = HealthHitBarColor;
		C.DrawColor.A = (LastHitAlpha * 255.f);
		C.SetPos((ScreenLocX - (0.5 * TurboHUD.BarLength)) + (TurboHUD.BarLength * FClamp(PlayerInfo.CurrentHealth, 0, 1)), (ScreenLocY - (TurboHUD.BarHeight * 0.5f)) - (0.25f * TurboHUD.BarHeight * (LastHitScale * 1.f)));
		C.DrawTileStretched(TurboHUD.WhiteMaterial, (TurboHUD.BarLength * PlayerInfo.LastHit.HitAmount * 1.1f) + ((TurboHUD.BarLength * 0.05f) / PlayerInfo.LastHit.FadeRate), TurboHUD.BarHeight * (1.f + (LastHitScale * 0.5f)));
	}

	C.Z = OldZ;
}

simulated final function DrawBackplate(Canvas C, float XCentre, float YCentre, byte Alpha, float HeightScale)
{
	BarBackplateColor.A = int(float(default.BarBackplateColor.A) * (float(Alpha) / 255.f));
	C.DrawColor = BarBackplateColor;
	C.SetPos(XCentre - 0.5 * TurboHUD.BarLength, YCentre - (0.5 * TurboHUD.BarHeight * HeightScale));
	C.DrawTileStretched(TurboHUD.WhiteMaterial, TurboHUD.BarLength, TurboHUD.BarHeight * HeightScale);
}

simulated final function DrawBar(Canvas C, float XCentre, float YCentre, float BarPercentage, color Color, float HeightScale)
{
	C.DrawColor = Color;
	C.SetPos(XCentre - 0.5 * TurboHUD.BarLength, YCentre - (0.5 * TurboHUD.BarHeight * HeightScale));
	C.DrawTileStretched(TurboHUD.WhiteMaterial, TurboHUD.BarLength * BarPercentage, TurboHUD.BarHeight * HeightScale);
}

simulated final function StartVoiceSupportNotification(PlayerReplicationInfo Sender)
{
	local int PlayerInfoIndex;
	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		if (PlayerInfoDataList[PlayerInfoIndex].TPRI == Sender)
		{
			PlayerInfoDataList[PlayerInfoIndex].VoiceSupportAnim = 1.f;
			break;
		}
	}
}

simulated final function StartVoiceAlertNotification(PlayerReplicationInfo Sender)
{
	local int PlayerInfoIndex;
	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		if (PlayerInfoDataList[PlayerInfoIndex].TPRI == Sender)
		{
			PlayerInfoDataList[PlayerInfoIndex].VoiceAlertAnim = 1.f;
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
	local float TextSizeX, TextSizeY;
	local float MinEntrySizeX, EntrySizeY;
	local float TempX, TempY;
	local string PlayerName;
	local float AnimTime;
	local byte AlertOpacity;
	local float AlertScale;
	local float HealthPercent;
	
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;
	C.Font = TurboHUD.GetFontSizeIndex(C, -1);

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

	MinEntrySizeX += 24.f;
	EntrySizeY += 4.f;

	TempX = C.ClipX;
	TempY = C.ClipY * (1.f - (class'TurboHUDPlayer'.default.CashBackplateSize.Y + (class'TurboHUDPlayer'.default.BackplateSpacing.Y * 2.f)));

	for (PlayerInfoIndex = PlayerInfoDataList.Length - 1; PlayerInfoIndex >= 0; PlayerInfoIndex--)
	{
		if (PlayerInfoDataList[PlayerInfoIndex].CurrentHealth <= 0.f)
		{
			continue;
		}

		HealthPercent = PlayerInfoDataList[PlayerInfoIndex].CurrentHealth;

		C.FontScaleX = 1.f;
		C.FontScaleY = 1.f;

		C.SetDrawColor(0, 0, 0, 120);
		C.SetPos(TempX - MinEntrySizeX, TempY - EntrySizeY);
		C.DrawTileStretched(MedicBackplate, MinEntrySizeX + 4.f, EntrySizeY);

		PlayerName = Left(PlayerInfoDataList[PlayerInfoIndex].TPRI.PlayerName, 12);

		C.SetDrawColor(255, 255, 255, 255);
		C.TextSize(PlayerName, TextSizeX, TextSizeY);
		C.SetPos(TempX - (TextSizeX + 10.f), TempY - ((EntrySizeY * 0.5f) + (TextSizeY * 0.5f)));
		C.DrawTextClipped(PlayerName);
		
		C.FontScaleX = 0.667f;
		C.FontScaleY = 0.667f;
		C.SetPos((TempX - MinEntrySizeX) + 4.f, (TempY - EntrySizeY) - 8.f);
		C.DrawTextClipped(int(HealthPercent * GetHealthMax(PlayerInfoDataList[PlayerInfoIndex]))$class'TurboHUDScoreboard'.default.HealthyString);

		AnimTime = 1.f - PlayerInfoDataList[PlayerInfoIndex].VoiceSupportAnim;
		if (AnimTime < 1.f)	
		{
			AlertOpacity = Round(InterpCurveEval(MedicRequestOpacityCurve, AnimTime) * 160.f);
			C.SetDrawColor(255, 0, 0);
			C.DrawColor.A = AlertOpacity;

			AlertScale = InterpCurveEval(MedicRequestScaleCurve, AnimTime);

			C.SetPos((TempX - (MinEntrySizeX - (InterpCurveEval(MedicRequestMoveCurve, AnimTime) * 8.f))) - ((EntrySizeY * AlertScale * 0.8f)), TempY - (EntrySizeY * Lerp(0.5f, 1.f, AlertScale)));
			C.DrawTileStretched(MedicCap, EntrySizeY * AlertScale * 0.75f, EntrySizeY * AlertScale);
		}

		TempY -= EntrySizeY + 2.f;
	}
}

defaultproperties
{
	PlayerCollectionTime=0.1f

	PerkBackplate=Texture'KFTurbo.HUD.PerkBackplate_D'

	HealthInterpRate=1.f;
	ShieldInterpRate=2.f;

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

	MedicBackplate=Texture'KFTurbo.HUD.EdgeBackplate_D'
	MedicCap=Texture'KFTurbo.HUD.ContainerRoundedCap_D'

	MedicRequestOpacityPointList(0)=(InVal=0.0,OutVal=0)
	MedicRequestOpacityPointList(1)=(InVal=0.1,OutVal=1)
	MedicRequestOpacityPointList(2)=(InVal=0.2,OutVal=0)
	MedicRequestOpacityPointList(3)=(InVal=0.3,OutVal=1)
	MedicRequestOpacityPointList(4)=(InVal=0.4,OutVal=0)
	MedicRequestOpacityPointList(5)=(InVal=0.5,OutVal=1)
	MedicRequestOpacityPointList(6)=(InVal=0.6,OutVal=0)
	MedicRequestOpacityPointList(7)=(InVal=0.7,OutVal=1)
	MedicRequestOpacityPointList(8)=(InVal=0.95,OutVal=1)
	MedicRequestOpacityPointList(9)=(InVal=1.0,OutVal=0)

	MedicRequestMovePointList(0)=(InVal=0.0,OutVal=0)
	MedicRequestMovePointList(1)=(InVal=0.1,OutVal=1)
	MedicRequestMovePointList(2)=(InVal=1.0,OutVal=1)

	MedicRequestScalePointList(0)=(InVal=0.0,OutVal=1.25)
	MedicRequestScalePointList(1)=(InVal=0.1,OutVal=1)
	MedicRequestScalePointList(2)=(InVal=1.0,OutVal=1)
}