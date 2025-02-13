//Killing Floor Turbo TurboHUDMarkInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDMarkInfo extends TurboHUDOverlay;

struct MarkInfoData
{
	var PlayerReplicationInfo PRI;
	var TurboPlayerMarkReplicationInfo TurboMarkPRI;
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
	local TurboPlayerMarkReplicationInfo TurboMarkPRI;
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
		
		TurboMarkPRI = class'TurboPlayerMarkReplicationInfo'.static.GetTurboMarkPRI(PRI);

		if (TurboMarkPRI == None)
		{
			continue;
		}

		MarkInfoDataList.Insert(0, 1);
		MarkInfoDataList[0].PRI = PRI;
		MarkInfoDataList[0].TurboMarkPRI = TurboMarkPRI;
	}
}

static final simulated function bool ShouldDrawMarkInfo(vector CameraPosition, vector CameraDirection, out MarkInfoData MarkInfo)
{
	if (MarkInfo.PRI == None || MarkInfo.TurboMarkPRI == None || MarkInfo.TurboMarkPRI.MarkActorClass == None || MarkInfo.TurboMarkPRI.MarkDisplayString == "")
	{
		return false;
	}

	if ((Normal((MarkInfo.TurboMarkPRI.GetMarkLocation() + (vect(0,0,1.f) * MarkInfo.TurboMarkPRI.WorldZOffset)) - CameraPosition) Dot CameraDirection) < 0.f )
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

	if (TurboHUD == None || Level.GRI == None)
	{
		return;
	}

	Super.Render(C);

	OpacityScale = 1.f;

	if (GetWeapon() != None)
	{
		if (GetWeapon().bAimingRifle)
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

		ScreenPos = C.WorldToScreen(MarkInfoDataList[Index].TurboMarkPRI.GetMarkLocation() + (vect(0,0,1.f) * MarkInfoDataList[Index].TurboMarkPRI.WorldZOffset));
		
		if( ScreenPos.X >= 0 && ScreenPos.Y >= 0 && ScreenPos.X <= C.ClipX && ScreenPos.Y <= C.ClipY )
		{
			DrawMarkInfo(C, MarkInfoDataList[Index], ScreenPos.X, ScreenPos.Y, OpacityScale);
		}
	}
	
	class'TurboHUDKillingFloor'.static.ResetCanvas(C);
}

simulated final function DrawMarkInfo(Canvas C, out MarkInfoData MarkInfo, float ScreenLocX, float ScreenLocY, float OpacityScale)
{
	local float XL, YL, TempX, TempY;
	local float PlayerDistance, Dist;
	local string DistanceString;
	local byte BeaconAlpha;
	local float BeaconScale;
	local float OldZ;
	local Color DrawColor;
	local float BackplateSize;

	Dist = vsize(MarkInfo.TurboMarkPRI.GetMarkLocation() - GetController().CalcViewLocation);
	PlayerDistance = Dist;
	Dist -= TurboHUD.HealthBarFullVisDist * 2.f;
	Dist = FClamp(Dist, 0.f, (TurboHUD.HealthBarCutoffDist * 2.f) - (TurboHUD.HealthBarFullVisDist * 2.f));
	Dist = Dist / ((TurboHUD.HealthBarCutoffDist * 2.f) - (TurboHUD.HealthBarFullVisDist * 2.f));
	//BeaconAlpha = byte(255.f * FMin(PlayerInfo.VisibilityFade * 2.f, 1.f));
	BeaconScale = Lerp(PlayerDistance / ((TurboHUD.HealthBarCutoffDist * 2.f) - (TurboHUD.HealthBarFullVisDist * 2.f)), 4.f, 8.f);
	BeaconAlpha = byte(FMax(1.f - Dist, 0.66f) * OpacityScale * 255.f);

	if ( MarkInfo.TurboMarkPRI.MarkDisplayString == "")
	{
		return;
	}

	OldZ = C.Z;
	C.Z = 1.0;
	C.Style = TurboHUD.ERenderStyle.STY_Alpha;

	DrawColor = MarkInfo.TurboMarkPRI.GetMarkerColor(MarkInfo.TurboMarkPRI.MarkerColor);
	C.FontScaleX = 1.f;
	C.FontScaleY = 1.f;

	DistanceString = int(PlayerDistance / 50.f)$"m";

	TempX = ScreenLocX;
	TempY = ScreenLocY;
	
	C.Font = TurboHUD.LoadFont(Min(8,BeaconScale + 1));
	C.TextSize(DistanceString, XL, YL);
	TempY -= YL;
	BackplateSize = YL * 2.f;

	C.Font = TurboHUD.LoadFont(Min(8,BeaconScale));
	C.TextSize(MarkInfo.TurboMarkPRI.MarkDisplayString, XL, YL);
	TempY -= YL * 0.25f;
	BackplateSize += YL;
	BackplateSize *= 1.25f;

	C.SetPos(TempX - (BackplateSize * 0.5f), TempY - (BackplateSize * 0.5f));
	C.DrawColor = DrawColor;
	C.DrawColor.A = int(float(BeaconAlpha) * 0.25f);
	C.DrawTile(MarkBackplate, BackplateSize, BackplateSize, 0, 0, MarkBackplate.MaterialUSize(), MarkBackplate.MaterialVSize());	

	//Draw distance.
	C.Font = TurboHUD.LoadFont(Min(8,BeaconScale + 1));
	C.TextSize(DistanceString, XL, YL);
	TempX = ScreenLocX - (XL * 0.5);
	TempY = ScreenLocY - (YL * 1.f);

	if (Min(8,BeaconScale + 1) < 7)
	{
		C.SetPos(TempX + 2.f, TempY + 2.f);
		C.DrawColor = TurboHUD.BlackColor;
		C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
		C.DrawTextClipped(DistanceString, false);
	}

	C.DrawColor = DrawColor;
	C.DrawColor.A = BeaconAlpha;

	C.SetPos(TempX, TempY);
	C.DrawTextClipped(DistanceString, false);

	//Draw mark name.
	C.Font = TurboHUD.LoadFont(Min(8,BeaconScale));
	C.TextSize(MarkInfo.TurboMarkPRI.MarkDisplayString, XL, YL);

	TempX = ScreenLocX - (XL * 0.5);
	TempY = TempY - (YL * 0.75f);
	TempX = int(TempX);
	TempY = int(TempY);

	C.SetPos(TempX + 2.f, TempY + 2.f);
	C.DrawColor = TurboHUD.BlackColor;
	C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
	C.DrawTextClipped(MarkInfo.TurboMarkPRI.MarkDisplayString, false);

	C.DrawColor = DrawColor;
	C.DrawColor.A = BeaconAlpha;
	C.SetPos(TempX, TempY);
	C.DrawTextClipped(MarkInfo.TurboMarkPRI.MarkDisplayString, false);

	//Draw mark instigator.
	C.Font = TurboHUD.LoadFont(Min(8,BeaconScale + 1));
	C.TextSize(MarkInfo.PRI.PlayerName, XL, YL);

	TempX = ScreenLocX - (XL * 0.5);
	TempY = TempY - (YL * 0.75f);
	TempX = int(TempX);
	TempY = int(TempY);
	if (Min(8,BeaconScale + 1) < 7)
	{
		C.SetPos(TempX + 2.f, TempY + 2.f);
		C.DrawColor = TurboHUD.BlackColor;
		C.DrawColor.A = (float(BeaconAlpha) * 0.5f);
		C.DrawTextClipped(MarkInfo.PRI.PlayerName, false);
		C.DrawColor = DrawColor;
		C.DrawColor.A = BeaconAlpha;
	}

	C.SetPos(TempX, TempY);
	C.DrawTextClipped(MarkInfo.PRI.PlayerName, false);
	C.DrawColor = TurboHUD.BlackColor;

	C.Z = OldZ;
}


defaultproperties
{
	MarkBackplate=Texture'KFTurbo.HUD.PerkBackplate_D'
}