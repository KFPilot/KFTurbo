//Killing Floor Turbo TurboCard_ProConStrange_Something
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCard_ProConStrange_Something extends TurboCard_ProConStrange;

var Texture SomethingTexture;
var Color SomethingColor;

function SetupScriptedTexture(ScriptedTexture Tex)
{
	Super.SetupScriptedTexture(Tex);
	Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, SomethingTexture.USize, SomethingTexture.VSize, SomethingTexture, SomethingColor);
}

defaultproperties
{
	SomethingTexture=Texture'KFTurboCardGame.Card.Something_D'
	SomethingColor=(R=255,G=255,B=255,A=255)

	bCanEverRepeat=false
}