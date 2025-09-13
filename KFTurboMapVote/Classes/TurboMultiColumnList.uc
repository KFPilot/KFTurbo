//Killing Floor Turbo TurboMultiColumnList
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboMultiColumnList extends MVMultiColumnList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController,MyOwner);
	
	UpdateFontScale();
}

function ResolutionChanged(int ResX, int ResY)
{
	Super.ResolutionChanged(ResX, ResY);

	UpdateFontScale();
}

function UpdateFontScale()
{
	if (Controller.ResY <= 720)
	{
		FontScale = eFontScale.FNS_Small;
	}
	else if (Controller.ResY < 2160)
	{
		FontScale = eFontScale.FNS_Medium;
	}
	else
	{
		FontScale = eFontScale.FNS_Large;
	}
}