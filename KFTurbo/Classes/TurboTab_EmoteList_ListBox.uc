//Killing Floor Turbo TurboTab_EmoteList_ListBox
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboTab_EmoteList_ListBox extends GUIListBoxBase;

var TurboTab_EmoteList_VertList List;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'TurboTab_EmoteList_VertList');
	Super.InitComponent(MyController,MyOwner);
	List = TurboTab_EmoteList_VertList(AddComponent(DefaultListClass));

	if (List == None)
	{
		return;
	}

	InitBaseList(List);
}

defaultproperties
{
	
}