//Killing Floor Turbo TurboGUIHTMLTextBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIHTMLTextBox extends ServerPerks.GUIHTMLTextBox;

//Unfortunately InitHTMLArea is final so we need to redefine.
protected function TurboInitHTMLArea( Canvas C )
{
	local float XS,YS;
	local int i,j,X,Y,iStart,BestHeight,FontSize,PrevY,Remain,iLastWord,iLen,z,ImgHeight;
	local TurboHUDKillingFloor TurboHUD;
	TurboHUD = TurboHUDKillingFloor(PlayerOwner().myHUD);

	if (TurboHUD == None)
	{
		return;
	}

	// Used to detect resolution changes when text needs realignment.
	OldXSize = ActualWidth(WinWidth);
	OldYSize = ActualHeight(WinHeight);

	// Merge splitted lines again
	if( bHasSplitLines )
	{
		bHasSplitLines = false;
		for( i=1; i<Lines.Length; ++i )
		{
			if( Lines[i].bSplit )
			{
				Lines[i-1].Text @= Lines[i].Text;
				Lines.Remove(i--,1);
			}
		}
	}
	
	// Setup background image scaling
	if( BgImage.Img!=None )
	{
		switch( BgImage.Style )
		{
		case 1: // Tiled
			if( BgImage.X==BgImage.XS )
				BgImage.XOffset = C.ClipX;
			else
			{
				XS = C.ClipX / float(BgImage.XS) * float(BgImage.X);
				BgImage.XOffset = XS;
			}
			if( BgImage.Y==BgImage.YS )
				BgImage.YOffset = C.ClipY;
			else
			{
				XS = C.ClipY / float(BgImage.YS) * float(BgImage.Y);
				BgImage.YOffset = XS;
			}
			break;
		case 2: // Fit X
			XS = C.ClipY * (C.ClipX / float(BgImage.X));
			BgImage.YS = XS;
			break;
		case 3: // Fit Y
			XS = C.ClipX * (C.ClipY / float(BgImage.Y));
			BgImage.XS = XS;
			break;
		}
	}
	
	FontSize = -2;
	if ( C.SizeY < 480 )
		FontSize++;
	if ( C.SizeY < 600 )
		FontSize++;
	if ( C.SizeY < 800 )
		FontSize++;
	if ( C.SizeY < 1024 )
		FontSize++;
	if ( C.SizeY < 1250 )
		FontSize++;

	C.SetPos(0,0);
	if( Lines.Length>0 )
	{
		while( true )
		{
			if( i>=Lines.Length || (i>0 && Lines[i].LineSkips>0) )
			{
				for( j=iStart; j<i; ++j )
				{
					switch( Lines[j].Align )
					{
					case 0: // Left
						Lines[j].X = Lines[j].TOffset;
						break;
					case 1: // Center
						Lines[j].X = (C.ClipX-X+Lines[j].TOffset)/2;
						break;
					case 2: // Right
						Lines[j].X = C.ClipX-X+Lines[j].TOffset;
						break;
					}
				}
				if( i>=Lines.Length )
					break;
				X = 0;
				iStart = i;
				PrevY = BestHeight;
				BestHeight = 0;
			}
			if( Lines[i].FontSize>=247 )
				Lines[i].Font = TurboHUD.LoadFont(Lines[i].FontSize-247);
			else Lines[i].Font = TurboHUD.LoadFont(Clamp(8-(FontSize+Lines[i].FontSize),0,8));
			C.Font = Lines[i].Font;
			if( Lines[i].Text=="" )
			{
				C.TextSize("ABC",XS,YS);
				XS = 0;
			}
			else C.TextSize(Lines[i].Text,XS,YS);
			if( Lines[i].LineSkips>0 )
			{
				if( PrevY==0 )
					PrevY = YS;
				Y+=(PrevY*Lines[i].LineSkips);
			}
			X = Max(X,Lines[i].Tab);
			Lines[i].TOffset = X;
			Lines[i].Y = Y;
			Lines[i].YS = YS;
			BestHeight = Max(BestHeight,YS);
			if( (X+XS)>C.ClipX )
			{
				// Split to next row.
				Remain = C.ClipX-X;
				iLastWord = 0;
				iLen = Len(Lines[i].Text);
				for( j=1; j<iLen; ++j )
				{
					C.TextSize(Left(Lines[i].Text,j),XS,YS);
					if( Remain<XS )
					{
						if( iLastWord==0 ) // Must cut off a word now.
							SplitLine(i,Max(j-1,0));
						else SplitLine(i,iLastWord);
						break;
					}
					if( Mid(Lines[i].Text,j,1)==" " )
						iLastWord = j+1;
				}
				C.TextSize(Lines[i].Text,XS,YS);
			}
			Lines[i].XS = XS;
			X+=XS;
			
			for( j=0; j<Lines[i].ImgList.Length; ++j )
			{
				z = Lines[i].ImgList[j];
				if( Images[z].Align==3 )
					Images[z].X = X+Images[z].XOffset;
				else Images[z].X = Images[z].XOffset;
				Images[z].Y = Y+Images[z].YOffset;
				ImgHeight = Max(ImgHeight,Images[z].Y+Images[z].YS);
			}
			++i;
		}
		YSize = Max(Y+BestHeight,ImgHeight);
	}
	else YSize = 0;

	bNeedScrollbar = (YSize>C.ClipY);
	if( bNeedScrollbar )
	{
		MyScrollBar.EnableMe();
		MyScrollBar.Step = 16;
		MyScrollBar.BigStep = 512;
		MyScrollBar.ItemCount = YSize;
		MyScrollBar.ItemsPerPage = C.ClipY;
		MyScrollBar.UpdateGripPosition(0);
	}
	else MyScrollBar.DisableMe();
}

function bool RenderHTMLText( canvas C )
{
	local float CX,CY,YS;
	local int i,YOffset,MX,MY;
	local bool bMouseOnClient;

	CX = C.ClipX;
	CY = C.ClipY;
	C.OrgX = ActualLeft(WinLeft);
	C.OrgY = ActualTop(WinTop);
	C.ClipX = ActualWidth(WinWidth)-MyScrollBar.ActualWidth(MyScrollBar.WinWidth);
	C.ClipY = ActualHeight(WinHeight);

	if( bNeedsInit || OldXSize!=ActualWidth(WinWidth) || OldYSize!=ActualHeight(WinHeight) )
	{
		bNeedsInit = false;
		TurboInitHTMLArea(C);
	}
	if( bNeedScrollbar )
		YOffset = MyScrollBar.CurPos;

	C.Style = 5; // STY_Alpha

	if( BGColor.A>0 )
	{
		C.SetPos(0,0);
		C.DrawColor = BGColor;
		
		if( BgImage.Img!=None )
		{
			if( BgImage.Align==1 ) // not locked on screen.
				MX = YOffset;
			switch( BgImage.Style )
			{
			case 0: // Stretched to fit
				C.DrawTileClipped(BgImage.Img,C.ClipX,C.ClipY,0,MX,BgImage.X,BgImage.Y);
				break;
			case 1: // Tiled
				C.DrawTileClipped(BgImage.Img,C.ClipX,C.ClipY,0,MX,BgImage.XOffset,BgImage.YOffset);
				break;
			case 2: // Fit X
				C.DrawTileClipped(BgImage.Img,C.ClipX,C.ClipY,0,MX,BgImage.X,BgImage.YS);
				break;
			case 3: // Fit Y
				C.DrawTileClipped(BgImage.Img,C.ClipX,C.ClipY,0,MX,BgImage.XS,BgImage.Y);
				break;
			}
		}
		else C.DrawTile(Texture'WhiteTexture',C.ClipX,C.ClipY,0,0,1,1);
	}
	MX = Controller.MouseX-C.OrgX;
	MY = Controller.MouseY-C.OrgY;
	bMouseOnClient = (MX>=0 && MX<=C.ClipX && MY>=0 && MY<=C.ClipY);
	HoverOverLinkLine = -1;
	MY+=YOffset;

	C.DrawColor = Class'HUD'.Default.WhiteColor;
	for( i=0; i<Images.Length; ++i )
	{
		C.CurY = Images[i].Y-YOffset;
		if( (C.CurY+Images[i].YS)<0 || C.CurY>C.ClipY )
			continue;
		switch( Images[i].Align )
		{
		case 0: // Left
		case 3: // Unaligned, postition after text.
			C.CurX = 0;
			break;
		case 1: // Center
			C.CurX = (C.ClipX-Images[i].XS)/2;
			break;
		case 1: // Right
			C.CurX = C.ClipX-Images[i].XS;
			break;
		}
		C.CurX += Images[i].X;
		switch( Images[i].Style )
		{
		case 1: // Stretched
			DrawTileStretchedClipped(C,Images[i].Img,Images[i].XS,Images[i].YS);
			break;
		case 2: // Tiled on X axis
			C.DrawTileClipped(Images[i].Img,Images[i].XS,Images[i].YS,0,0,Images[i].XS,Images[i].Img.MaterialVSize());
			break;
		case 3: // Tiled on Y axis
			C.DrawTileClipped(Images[i].Img,Images[i].XS,Images[i].YS,0,0,Images[i].Img.MaterialUSize(),Images[i].YS);
			break;
		case 4: // Fully tiled
			C.DrawTileClipped(Images[i].Img,Images[i].XS,Images[i].YS,0,0,Images[i].XS,Images[i].YS);
			break;
		default: // Normal
			C.DrawTileClipped(Images[i].Img,Images[i].XS,Images[i].YS,0,0,Images[i].Img.MaterialUSize(),Images[i].Img.MaterialVSize());
		}
	}

	for( i=0; i<Lines.Length; ++i )
	{
		C.SetPos(Lines[i].X,Lines[i].Y-YOffset);
		if( (C.CurY+Lines[i].YS)<0 || Lines[i].Text=="" )
			continue;
		if( C.CurY>C.ClipY )
			break;
		
		// Check if mouse hovers over URL
		if( bMouseOnClient && Lines[i].bHasURL && MX>=Lines[i].X && MX<=(Lines[i].X+Lines[i].XS)
												&& MY>=Lines[i].Y && MY<=(Lines[i].Y+Lines[i].YS) )
		{
			HoverOverLinkLine = i;
			bMouseOnClient = false; // No need to check on rest anymore.
			C.DrawColor = Lines[i].ALColor;
		}
		else C.DrawColor = Lines[i].Color;

		C.Font = Lines[i].Font;
		C.DrawTextClipped(Lines[i].Text);
		if( Lines[i].bHasURL )
		{
			YS = Max(Lines[i].YS/15,1);
			C.SetPos(Lines[i].X,Lines[i].Y+Lines[i].YS-(YS*2)-YOffset);
			if( C.CurY<C.ClipY )
				C.DrawTileClipped(Texture'WhiteTexture',Lines[i].XS,YS,0,0,1,1);
		}
	}

	if( OldHoverLine!=HoverOverLinkLine )
	{
		OldHoverLine = HoverOverLinkLine;
		if( HoverOverLinkLine>=0 )
		{
			Controller.PlayInterfaceSound(CS_Hover);
			SetToolTipText(Lines[HoverOverLinkLine].URL);
		}
		else SetToolTipText("");
	}

	C.OrgX = 0;
	C.OrgY = 0;
	C.ClipX = CX;
	C.ClipY = CY;
	
	return false;
}

defaultproperties
{
	
}
