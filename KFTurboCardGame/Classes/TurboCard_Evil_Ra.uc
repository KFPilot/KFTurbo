//Killing Floor Turbo TurboCard_Evil_Ra
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCard_Evil_Ra extends TurboCard_Evil;

var Texture CurseOfRaTexture;
var Color CurseOfRaColor;

function SetupScriptedTexture(ScriptedTexture Tex)
{
	Super.SetupScriptedTexture(Tex);
	Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, CurseOfRaTexture.USize, CurseOfRaTexture.VSize, CurseOfRaTexture, CurseOfRaColor);
}

defaultproperties
{
	CardName(0)="Curse of Ra"

	CurseOfRaTexture=Texture'KFTurboCardGame.Card.CurseOfRa_D'
	CurseOfRaColor=(R=255,G=255,B=255,A=255)
}