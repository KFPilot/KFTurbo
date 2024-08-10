class TurboHUDMarkInfo extends TurboHUDOverlay;

struct MarkInfoData
{
	var PlayerReplicationInfo PRI;
	var TurboPlayerReplicationInfo TPRI;
};

var array<MarkInfoData> MarkInfoDataList;

var Texture MarkBackplate;

simulated function Initialize(TurboHUDKillingFloor OwnerHUD)
{
	Super.Initialize(OwnerHUD);
}

simulated function Tick(float DeltaTime)
{
	local int Index, MarkInfoIndex;
	local PlayerReplicationInfo PRI;
	local TurboPlayerReplicationInfo TPRI;
	local bool bFoundData;

	Super.Tick(DeltaTime);

	if (Level.GRI == None || Level.GRI.PRIArray.Length == 0)
	{
		return;
	}

	for (Index = MarkInfoDataList.Length - 1; Index >= 0; Index--)
	{
		PRI = MarkInfoDataList[Index].PRI;

		if (PRI == None || PRI.bOnlySpectator || PRI.bIsSpectator )
		{
			MarkInfoDataList.Remove(Index, 1);
			continue;
		}
	}

	for (Index = Level.GRI.PRIArray.Length - 1; Index >= 0; Index--)
	{
		PRI = Level.GRI.PRIArray[Index];
		if (PRI == None)
		{
			continue;
		}

		bFoundData = false;
		for (MarkInfoIndex = MarkInfoDataList.Length - 1; MarkInfoIndex >= 0; MarkInfoIndex--)
		{
			if (MarkInfoDataList[MarkInfoIndex].PRI == PRI)
			{
				bFoundData = true;
				break;
			}
		}

		if (bFoundData)
		{
			continue;
		}
		
		TPRI = class'TurboPlayerReplicationInfo'.static.GetTurboPRI(PRI);

		if (TPRI == None)
		{
			continue;
		}

		MarkInfoDataList.Insert(0, 1);
		MarkInfoDataList[0].PRI = PRI;
		MarkInfoDataList[0].TPRI = TPRI;
	}
}

static final simulated function bool ShouldDrawMarkInfo(vector CameraPosition, vector CameraDirection, out MarkInfoData MarkInfo)
{
	if (MarkInfo.PRI == None || MarkInfo.TPRI == None || MarkInfo.TPRI.MarkActorClass == None || MarkInfo.TPRI.MarkDisplayString == "")
	{
		return false;
	}

	if ((Normal((MarkInfo.TPRI.GetMarkLocation() + (vect(0,0,1.f) * MarkInfo.TPRI.WorldZOffset)) - CameraPosition) Dot CameraDirection) < 0.f )
	{
		return false;
	}

	return true;
}

simulated function Render(Canvas C)
{
	local int Index;
	local float OpacityScale;
	local vector CamPos, ViewDir, ScreenPos;
	local rotator CamRot;

	if (KFPHUD == None || KFPHUD.Level.GRI == None)
	{
		return;
	}

	Super.Render(C);

	OpacityScale = 1.f;

	if (KFPHUD.PawnOwner != None && KFWeapon(KFPHUD.PawnOwner.Weapon) != None)
	{
		if (KFWeapon(KFPHUD.PawnOwner.Weapon).bAimingRifle)
		{
			OpacityScale *= 0.33f;
		}
	}

	// Grab our View Direction
	C.GetCameraLocation(CamPos,CamRot);
	ViewDir = vector(CamRot);

	for (Index = MarkInfoDataList.Length - 1; Index >= 0; Index--)
	{
		if (!ShouldDrawMarkInfo(CamPos, ViewDir, MarkInfoDataList[Index]))
		{
			continue;
		}

		ScreenPos = C.WorldToScreen(MarkInfoDataList[Index].TPRI.GetMarkLocation() + (vect(0,0,1.f) * MarkInfoDataList[Index].TPRI.WorldZOffset));
		
		if( ScreenPos.X >= 0 && ScreenPos.Y >= 0 && ScreenPos.X <= C.ClipX && ScreenPos.Y <= C.ClipY )
		{
			DrawMarkInfo(C, MarkInfoDataList[Index], ScreenPos.X, ScreenPos.Y, OpacityScale);
		}
	}
}

function DrawMarkInfo(Canvas C, out MarkInfoData MarkInfo, float ScreenLocX, float ScreenLocY, float OpacityScale)
{
	local float XL, YL, TempX, TempY;
	local float PlayerDistance, Dist;
	local string DistanceString;
	local byte BeaconAlpha;
	local float BeaconScale;
	local float OldZ;
	local Color DrawColor;
	local float BackplateSize;

	Dist = vsize(MarkInfo.TPRI.GetMarkLocation() - KFPHUD.PlayerOwner.CalcViewLocation);
	PlayerDistance = Dist;
	Dist -= KFPHUD.HealthBarFullVisDist * 2.f;
	Dist = FClamp(Dist, 0.f, (KFPHUD.HealthBarCutoffDist * 2.f) - (KFPHUD.HealthBarFullVisDist * 2.f));
	Dist = Dist / ((KFPHUD.HealthBarCutoffDist * 2.f) - (KFPHUD.HealthBarFullVisDist * 2.f));
	//BeaconAlpha = byte(255.f * FMin(PlayerInfo.VisibilityFade * 2.f, 1.f));
	BeaconScale = Lerp(PlayerDistance / ((KFPHUD.HealthBarCutoffDist * 2.f) - (KFPHUD.HealthBarFullVisDist * 2.f)), 4.f, 8.f);
	BeaconAlpha = byte(FMax(1.f - Dist, 0.66f) * OpacityScale * 255.f);

	if ( MarkInfo.TPRI.MarkDisplayString == "")
	{
		return;
	}

	OldZ = C.Z;
	C.Z = 1.0;
	C.Style = KFPHUD.ERenderStyle.STY_Alpha;

	DrawColor = MarkInfo.TPRI.GetMarkerColor(MarkInfo.TPRI.MarkerColor);
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;

	DistanceString = int(PlayerDistance / 50.f)$"m";

	TempX = ScreenLocX;
	TempY = ScreenLocY;
	
	C.Font = KFPHUD.LoadFontStatic(Min(8,BeaconScale + 1));
	C.TextSize(DistanceString, XL, YL);
	TempY -= YL;
	BackplateSize = YL * 2.f;

	C.Font = KFPHUD.LoadFontStatic(Min(8,BeaconScale));
	C.TextSize(MarkInfo.TPRI.MarkDisplayString, XL, YL);
	TempY -= YL * 0.25f;
	BackplateSize += YL;
	BackplateSize *= 1.25f;

	C.SetPos(TempX - (BackplateSize * 0.5f), TempY - (BackplateSize * 0.5f));
	C.DrawColor = DrawColor;
	C.DrawColor.A = int(float(BeaconAlpha) * 0.25f);
	C.DrawTile(MarkBackplate, BackplateSize, BackplateSize, 0, 0, MarkBackplate.MaterialUSize(), MarkBackplate.MaterialVSize());	

	//Draw distance.
	C.Font = KFPHUD.LoadFontStatic(Min(8,BeaconScale + 1));
	C.TextSize(DistanceString, XL, YL);
	TempX = ScreenLocX - (XL * 0.5);
	TempY = ScreenLocY - (YL * 1.f);

	if (Min(8,BeaconScale + 1) < 7)
	{
		C.SetPos(TempX + 2.f, TempY + 2.f);
		C.DrawColor = KFPHUD.BlackColor;
		C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
		C.DrawTextClipped(DistanceString, false);
	}

	C.DrawColor = DrawColor;
	C.DrawColor.A = BeaconAlpha;

	C.SetPos(TempX, TempY);
	C.DrawTextClipped(DistanceString, false);

	//Draw mark name.
	C.Font = KFPHUD.LoadFontStatic(Min(8,BeaconScale));
	C.TextSize(MarkInfo.TPRI.MarkDisplayString, XL, YL);

	TempX = ScreenLocX - (XL * 0.5);
	TempY = TempY - (YL * 0.75f);
	TempX = int(TempX);
	TempY = int(TempY);

	C.SetPos(TempX + 2.f, TempY + 2.f);
	C.DrawColor = KFPHUD.BlackColor;
	C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
	C.DrawTextClipped(MarkInfo.TPRI.MarkDisplayString, false);

	C.DrawColor = DrawColor;
	C.DrawColor.A = BeaconAlpha;
	C.SetPos(TempX, TempY);
	C.DrawTextClipped(MarkInfo.TPRI.MarkDisplayString, false);

	//Draw mark instigator.
	C.Font = KFPHUD.LoadFontStatic(Min(8,BeaconScale + 1));
	C.TextSize(MarkInfo.PRI.PlayerName, XL, YL);

	TempX = ScreenLocX - (XL * 0.5);
	TempY = TempY - (YL * 0.75f);
	TempX = int(TempX);
	TempY = int(TempY);
	if (Min(8,BeaconScale + 1) < 7)
	{
		C.SetPos(TempX + 2.f, TempY + 2.f);
		C.DrawColor = KFPHUD.BlackColor;
		C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
		C.DrawTextClipped(MarkInfo.PRI.PlayerName, false);
		C.DrawColor = DrawColor;
		C.DrawColor.A = BeaconAlpha;
	}

	C.SetPos(TempX, TempY);
	C.DrawTextClipped(MarkInfo.PRI.PlayerName, false);
	C.DrawColor = KFPHUD.BlackColor;

	C.Z = OldZ;
}


defaultproperties
{
	MarkBackplate=Texture'KFTurbo.HUD.PerkBackplate_D'
}