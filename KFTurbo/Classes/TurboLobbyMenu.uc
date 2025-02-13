//Killing Floor Turbo TurboLobbyMenu
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboLobbyMenu extends SRLobbyMenu;

function bool ShowPerkMenu(GUIComponent Sender)
{
	if (PlayerOwner() != none)
		PlayerOwner().ClientOpenMenu(string(Class'TurboProfilePage'), false);
	return true;
}

function DrawPerk(Canvas Canvas)
{
	local float X, Y, Width, Height;
	local int LevelIndex;
	local float TempX, TempY;
	local float TempWidth, TempHeight;
	local float IconSize, ProgressBarWidth;
	local string PerkName, PerkLevelString;
	local KFPlayerReplicationInfo KFPRI;
	local GameReplicationInfo GRI;
	local Material M,SM;

	DrawPortrait();

	if( !bMOTDHidden )
	{
		X = 9.f/Canvas.ClipX;
		Y = 32.f/Canvas.ClipY;
		tb_ServerMOTD.WinWidth = ADBackground.WinWidth-X*2.f;
		tb_ServerMOTD.WinHeight = ADBackground.WinHeight-Y*1.25f;
		tb_ServerMOTD.WinLeft = ADBackground.WinLeft+X;
		tb_ServerMOTD.WinTop = ADBackground.WinTop+Y;

		if( !bMOTDInit )
		{
			GRI = PlayerOwner().Level.GRI;
			if( GRI!=None && GRI.MessageOfTheDay!="" )
			{
				bMOTDInit = true;
				tb_ServerMOTD.SetContent(GRI.MessageOfTheDay);
			}
		}
	}

	KFPRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

	if ( KFPRI==None || KFPRI.ClientVeteranSkill==None )
	{
		if( CurrentVeterancyLevel!=255 )
		{
			CurrentVeterancyLevel = 255;
			lb_PerkEffects.SetContent("None perk active");
		}
		return;
	}

	LevelIndex = KFPRI.ClientVeteranSkillLevel;

	if (class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill) != None)
	{
		PerkName = class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill).Static.GetVetInfoText(LevelIndex, 3);
	}
	else
	{
		PerkName = KFPRI.ClientVeteranSkill.default.VeterancyName;
	}

	PerkLevelString = "Lv" @ LevelIndex;

	//Get the position size etc in pixels
	X = (i_BGPerk.WinLeft + 0.00125) * Canvas.ClipX;
	Y = (i_BGPerk.WinTop + 0.0025) * Canvas.ClipY;

	X += 4.f;
	Y += 30.f;

	Width = (i_BGPerk.WinWidth - 0.0025) * Canvas.ClipX;
	Height = (i_BGPerk.WinHeight - 0.005) * Canvas.ClipY;

	Width -= 6.f;
	Height -= 34.f;

	// Offset for the Background
	TempX = X;
	TempY = Y;

	// Initialize the Canvas
	Canvas.Style = 1;
	Canvas.Font = class'ROHUD'.Static.GetSmallMenuFont(Canvas);
	Canvas.SetDrawColor(255, 255, 255, 255);

	// Draw Item Background
	Canvas.SetPos(TempX, TempY);
	//Canvas.DrawTileStretched(ItemBackground, Width, Height);
	
	IconSize = Height - ItemSpacing;

	// Draw Item Background
	Canvas.DrawTileStretched(PerkBackground, IconSize, IconSize);
	Canvas.SetPos(TempX + IconSize - 1.0, Y + 8.0);
	Canvas.DrawTileStretched(InfoBackground, Width - IconSize, Height - ItemSpacing - 16);

	// Offset and Calculate Icon's Size
	TempX += ItemBorder * Height * 0.25f;
	TempY += ItemBorder * Height * 0.25f;
	IconSize = Height - (ItemBorder * 0.5f * Height);

	// Draw Icon
	Canvas.SetPos(TempX, TempY);
	if( Class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill)!=None )
		Class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill).Static.PreDrawPerk(Canvas,KFPRI.ClientVeteranSkillLevel,M,SM);
	else M = KFPRI.ClientVeteranSkill.default.OnHUDIcon;
	Canvas.DrawTile(M, IconSize, IconSize, 0, 0, M.MaterialUSize(), M.MaterialVSize());

	TempX += IconSize + (IconToInfoSpacing * Width);
	TempY += ItemBorder * Height * 0.75f;
	TempY += TextTopOffset * Height;

	ProgressBarWidth = Width - (TempX - X) - (IconToInfoSpacing * Width);

	// Select Text Color
	Canvas.SetDrawColor(0, 0, 0, 255);

	// Draw the Perk's Level name
	Canvas.StrLen(PerkName, TempWidth, TempHeight);
	Canvas.SetPos(TempX, TempY);
	Canvas.DrawText(PerkName);

	// Draw the Perk's Level
	if (PerkLevelString != "")
	{
		Canvas.StrLen(PerkLevelString, TempWidth, TempHeight);
		Canvas.SetPos(TempX + ProgressBarWidth - TempWidth, TempY);
		Canvas.DrawText(PerkLevelString);
	}

	TempY += TempHeight + (0.01 * Height);

	if (CurrentVeterancy != KFPRI.ClientVeteranSkill || CurrentVeterancyLevel!=LevelIndex)
	{
		CurrentVeterancy = KFPRI.ClientVeteranSkill;
		CurrentVeterancyLevel = LevelIndex;
		lb_PerkEffects.SetContent(Class<SRVeterancyTypes>(KFPRI.ClientVeteranSkill).Static.GetVetInfoText(LevelIndex,1));
	}

	//PerkProgress = KFSteamStatsAndAchievements(PlayerOwner().SteamStatsAndAchievements).GetPerkProgress(CurIndex);
}

defaultproperties
{
     Begin Object Class=TurboLobbyFooter Name=BuyFooter
         RenderWeight=0.300000
         TabOrder=8
         bBoundToParent=False
         bScaleToParent=False
         OnPreDraw=BuyFooter.InternalOnPreDraw
     End Object
     t_Footer=TurboLobbyFooter'KFTurbo.TurboLobbyMenu.BuyFooter'

}
