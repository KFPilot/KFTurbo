//Killing Floor Turbo TurboHUDPerkProgressDrawer
//Utility to draw the twisted on-screen perk and progress bar.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboHUDPerkProgressDrawer extends Object;

enum EClipDirection
{
	Right,
	Down
};

struct ProgressPart
{
	var() Texture Texture;
	var() EClipDirection Clip;
	var() float Start;
	var() float End;
	var() float MinProgress;
	var() float MaxProgress;
};

var Texture ProgressBackplate;
var() ProgressPart ProgressTexture[7];

static final function DrawPerkProgress(Canvas C, float TopX, float TopY, float SizeX, float SizeY, float Progress, Color BackplateColor, Color ProgressColor)
{
	local int Index;
	local float SubProgress;
	local float DrawAmount;
	local Texture DrawTexture;
	local float DrawScaleX, DrawScaleY;

	C.DrawColor = BackplateColor;
	DrawScaleX = SizeX / float(default.ProgressBackplate.USize);
	DrawScaleY = SizeY / float(default.ProgressBackplate.VSize);

	C.SetPos(TopX, TopY);
	C.DrawTileScaled(default.ProgressBackplate, DrawScaleX, DrawScaleY);

	C.DrawColor = ProgressColor;

	for (Index = ArrayCount(default.ProgressTexture) - 1; Index >= 0; Index--)
	{
		if (default.ProgressTexture[Index].MinProgress > Progress)
		{
			continue;
		}

		C.SetPos(TopX, TopY);
	
		SubProgress = FMin((Progress - default.ProgressTexture[Index].MinProgress) / (default.ProgressTexture[Index].MaxProgress - default.ProgressTexture[Index].MinProgress), 1.f);

		if (SubProgress <= 0.f)
		{
			continue;
		}
		
		DrawTexture = default.ProgressTexture[Index].Texture;

		if (default.ProgressTexture[Index].Clip == EClipDirection.Right)
		{
			DrawAmount = Lerp(SubProgress, default.ProgressTexture[Index].Start, default.ProgressTexture[Index].End);
			C.DrawTile(DrawTexture, SizeX * (DrawAmount / DrawTexture.USize), SizeY, 0.f, 0.f, DrawAmount, DrawTexture.VSize);
		}
		else
		{
			DrawAmount = Lerp(SubProgress, default.ProgressTexture[Index].Start, default.ProgressTexture[Index].End);
			C.DrawTile(DrawTexture, SizeX, SizeY * (DrawAmount / DrawTexture.VSize), 0.f, 0.f, DrawTexture.USize, DrawAmount);
		}
	}
}

defaultproperties
{
	ProgressBackplate=Texture'KFTurbo.Ammo.CoiledProcessBackplate_D'
	ProgressTexture(0)=(Texture=Texture'KFTurbo.Ammo.CoiledProcess1_D',Clip=Right,Start=3.f,End=90.f,MinProgress=0.f,MaxProgress=0.15f)
	ProgressTexture(1)=(Texture=Texture'KFTurbo.Ammo.CoiledProcess2_D',Clip=Down,Start=50.f,End=115.f,MinProgress=0.15f,MaxProgress=0.3f)
	ProgressTexture(2)=(Texture=Texture'KFTurbo.Ammo.CoiledProcess3_D',Clip=Right,Start=57.f,End=145.f,MinProgress=0.3f,MaxProgress=0.4f)
	ProgressTexture(3)=(Texture=Texture'KFTurbo.Ammo.CoiledProcess4_D',Clip=Down,Start=89.f,End=202.f,MinProgress=0.4f,MaxProgress=0.6f)
	ProgressTexture(4)=(Texture=Texture'KFTurbo.Ammo.CoiledProcess5_D',Clip=Right,Start=112.f,End=213.f,MinProgress=0.6f,MaxProgress=0.75f)
	ProgressTexture(5)=(Texture=Texture'KFTurbo.Ammo.CoiledProcess6_D',Clip=Down,Start=141.f,End=239.f,MinProgress=0.75f,MaxProgress=0.85f)
	ProgressTexture(6)=(Texture=Texture'KFTurbo.Ammo.CoiledProcess7_D',Clip=Right,Start=185.f,End=248.f,MinProgress=0.85f,MaxProgress=1.f)
}