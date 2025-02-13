//Killing Floor Turbo TurboTab_ModelSelect
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_ModelSelect extends SRModelSelect;

function ListChange(GUIComponent Sender)
{
	local ImageListElem Elem;
	local int DotPosition;
	local string CaptionString;

	CharList.List.GetAtIndex(CharList.List.Index, Elem.Image, Elem.Item,Elem.Locked);

	if ( Elem.Item >= 0 && Elem.Item < Playerlist.Length )
	{
		if ( Elem.Locked==1 )
		{
			b_Ok.DisableMe();
		}
		else
		{
			b_Ok.EnableMe();
		}

		CaptionString = PlayerList[Elem.Item].DefaultName;
		DotPosition = InStr(CaptionString, ".");
		
		//If a package is in the name (has a . in the name), clean that up.
		if (DotPosition != -1)
		{
			CaptionString = Mid(CaptionString, DotPosition + 1);
		}

		//Turbo uses PRC_ to prefix PlayerRecordClass subclasses, so clean that up.
		CaptionString = Repl(CaptionString, "PRC_", "");
		//These are meant to be spaces!
		CaptionString = Repl(CaptionString, "_", " ");
		sb_Main.Caption = CaptionString;		
	}
	else
	{
		sb_Main.Caption = "";
	}
	UpdateSpinnyDude();
}

defaultproperties
{

}