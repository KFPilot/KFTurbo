class TurboHUDMarkInfo extends TurboHUDOverlay;

struct MarkInfoData
{
	var PlayerReplicationInfo PRI;
	var TurboPlayerReplicationInfo TPRI;
};

var array<MarkInfoData> MarkInfoDataList;

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

		PRI = Level.GRI.PRIArray[Index];

		if (PRI == None || PRI.bOnlySpectator || PRI.bIsSpectator )
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
	if (MarkInfo.PRI == None || MarkInfo.TPRI == None || MarkInfo.TPRI.MarkDisplayString == "")
	{
		return false;
	}

	if ((Normal((MarkInfo.TPRI.MarkInfo.Location + (vect(0,0,1.f) * MarkInfo.TPRI.WorldZOffset)) - CameraPosition) Dot CameraDirection) < 0.f )
	{
		return false;
	}

	return true;
}

simulated function Render(Canvas C)
{
	local int Index;
	local vector CamPos, ViewDir, ScreenPos;
	local rotator CamRot;

	if (KFPHUD == None || KFPHUD.Level.GRI == None)
	{
		return;
	}

	Super.Render(C);

	// Grab our View Direction
	C.GetCameraLocation(CamPos,CamRot);
	ViewDir = vector(CamRot);

	for (Index = MarkInfoDataList.Length - 1; Index >= 0; Index--)
	{
		if (!ShouldDrawMarkInfo(CamPos, ViewDir, MarkInfoDataList[Index]))
		{
			continue;
		}

		ScreenPos = C.WorldToScreen(MarkInfoDataList[Index].TPRI.MarkInfo.Location + (vect(0,0,1.f) * MarkInfoDataList[Index].TPRI.WorldZOffset));
		
		if( ScreenPos.X >= 0 && ScreenPos.Y >= 0 && ScreenPos.X <= C.ClipX && ScreenPos.Y <= C.ClipY )
		{
			DrawMarkInfo(C, MarkInfoDataList[Index], ScreenPos.X, ScreenPos.Y);
		}
	}
}

function DrawMarkInfo(Canvas C, out MarkInfoData MarkInfo, float ScreenLocX, float ScreenLocY)
{
	local float XL, YL, TempX, TempY;
	local float Dist;
	local byte BeaconAlpha;
	local float OldZ;
	local Color DrawColor;

	Dist = vsize(MarkInfo.TPRI.MarkInfo.Location - KFPHUD.PlayerOwner.CalcViewLocation);
	Dist -= KFPHUD.HealthBarFullVisDist * 2.f;
	Dist = FClamp(Dist, 0, (KFPHUD.HealthBarCutoffDist * 2.f) - (KFPHUD.HealthBarFullVisDist * 2.f));
	Dist = Dist / ((KFPHUD.HealthBarCutoffDist * 2.f) - (KFPHUD.HealthBarFullVisDist * 2.f));
	BeaconAlpha = byte((1.f - Dist) * 255.f);
	//BeaconAlpha = byte(255.f * FMin(PlayerInfo.VisibilityFade * 2.f, 1.f));

	if ( BeaconAlpha == 0 || MarkInfo.TPRI.MarkDisplayString == "")
	{
		return;
	}

	OldZ = C.Z;
	C.Z = 1.0;
	C.Style = KFPHUD.ERenderStyle.STY_Alpha;

	DrawColor = MarkInfo.TPRI.GetMarkerColor(MarkInfo.TPRI.MarkerColor);

	C.Font = KFPHUD.GetConsoleFont(C);
	C.TextSize(MarkInfo.TPRI.MarkDisplayString, XL, YL);

	TempX = ScreenLocX - (XL * 0.5);
	TempY = ScreenLocY - (YL * 1.f);
	TempX = int(TempX);
	TempY = int(TempY);

	C.SetPos(TempX + 1.f, TempY + 1.f);
	C.DrawColor = KFPHUD.BlackColor;
	C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
	C.DrawTextClipped(MarkInfo.TPRI.MarkDisplayString, false);

	C.DrawColor = DrawColor;
	C.DrawColor.A = BeaconAlpha;
	C.SetPos(TempX, TempY);
	C.DrawTextClipped(MarkInfo.TPRI.MarkDisplayString, false);

	C.FontScaleX = 0.75f;
	C.FontScaleY = 0.75f;

	C.TextSize(MarkInfo.PRI.PlayerName, XL, YL);

	C.SetPos((ScreenLocX - (XL * 0.5f)) + 1.f, (TempY - (YL)) + 1.f);
	C.DrawColor = KFPHUD.BlackColor;
	C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
	C.DrawTextClipped(MarkInfo.PRI.PlayerName, false);

	C.SetPos(ScreenLocX - (XL * 0.5f), TempY - (YL));
	C.DrawColor = DrawColor;
	C.DrawColor.A = BeaconAlpha;
	C.DrawTextClipped(MarkInfo.PRI.PlayerName, false);
	C.DrawColor = KFPHUD.BlackColor;

	C.Z = OldZ;
}


defaultproperties
{

}