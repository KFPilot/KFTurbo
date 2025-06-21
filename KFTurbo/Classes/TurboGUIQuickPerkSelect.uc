//Killing Floor Turbo TurboGUIQuickPerkSelect
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboGUIQuickPerkSelect extends ServerPerks.SRKFQuickPerkSelect;

function bool MyOnDraw(Canvas C)
{                                                                                                         
	local int i, j;
	local ClientPerkRepLink S;
	local Material M,SM;

	Super(GUIMultiComponent).OnDraw(C);
	
	C.SetDrawColor(255, 255, 255, 255);
	
	// make em square
	if ( !bResized )
	{
		ResizeIcons(C);
	}	
		
	// Current perk background
	C.SetPos(WinLeft * C.ClipX , WinTop * C.ClipY);
	C.DrawTileScaled(CurPerkBack, (WinHeight * C.ClipY) / CurPerkBack.USize, (WinHeight * C.ClipY) / CurPerkBack.USize);

	S = Class'ClientPerkRepLink'.Static.FindStats(C.Viewport.Actor);

	if (S == None)
	{
		return false;
	}

	// check if the current perk has changed recently
	CheckPerksX(S);

	j = 0;

	// Draw the available perks
	for (i=0; i <= MaxPerks; i++) //Changed to <= to fix weird missing perk (although the original should have worked?).
	{
		if (i != CurPerk)
		{
			S.CachePerks[i].PerkClass.Static.PreDrawPerk(C,Max(S.CachePerks[i].CurrentLevel,1)-1,M,SM);
			PerkSelectIcons[j].Image = M;
			PerkSelectIcons[j].Index = i;
			PerkSelectIcons[j].ImageColor = C.DrawColor;
			PerkSelectIcons[j].ImageColor.A = 255;
			j++;
		}
	}

	for (i = j; i < ArrayCount(PerkSelectIcons); ++i)
	{
		PerkSelectIcons[i].Image = None;
		PerkSelectIcons[i].Index = -1;
	}

	// Draw current perk
	if( CurPerk!=255 )
		DrawCurrentPerkX(S, C, CurPerk);
	
	return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local TurboPlayerController TurboPlayerController;

	if (Sender.IsA('KFIndexedGUIImage') && KFIndexedGUIImage(Sender).Index >= 0)
	{
		TurboPlayerController = TurboPlayerController(PlayerOwner());

		if (TurboPlayerController != None && TurboPlayerController.GetClientPerkRepLink() != None)
		{
			TurboPlayerController.SelectVeterancy(TurboPlayerController.GetClientPerkRepLink().CachePerks[KFIndexedGUIImage(Sender).Index].PerkClass);
		}

		bPerkChange = true;
	}
	
	return false;	
}

function DrawCurrentPerkX( ClientPerkRepLink S, Canvas C, Int PerkIndex)
{
	local Class<SRVeterancyTypes> V;
	local Material M,SM;

	V = S.CachePerks[PerkIndex].PerkClass;
	C.SetPos(WinLeft * C.ClipX , WinTop * C.ClipY);
	V.Static.PreDrawPerk(C,Max(S.CachePerks[PerkIndex].CurrentLevel,1)-1,M,SM);
	if( M!=None )
		C.DrawTileScaled(M, (WinHeight * C.ClipY) / M.MaterialUSize(), (WinHeight * C.ClipY) / M.MaterialVSize());
}

function CheckPerksX( ClientPerkRepLink S )
{
	local int i;
	local KFPlayerReplicationInfo PRI;

	// Grab the Player Controller for later use
	PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);
                                                                                         
	// Hold onto our reference
	if( S==None )
		return;

	if( S.CachePerks.Length==0 )
	{
		S.ServerRequestPerks();
		return;
	}

	// Update the ItemCount and select the first item
	MaxPerks = Min(S.CachePerks.Length,ArrayCount(PerkSelectIcons));
	CurPerk = 255;

	for( i=0; i<S.CachePerks.Length; i++ )
	{
		if ( PRI!=none && S.CachePerks[i].PerkClass==PRI.ClientVeteranSkill )
		{
			CurPerk = i;
			break;
		}
	}
	
	bPerkChange = false;
}

defaultproperties
{

}