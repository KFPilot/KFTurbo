class KFTTInteraction extends Interaction;

const XHAIR_LineLength = 16.0;
const XHAIR_LineWidth = 2.0;

var KFTTPlayerController PC;

event NotifyLevelChange() {
	Master.RemoveInteraction(Self);
}

function PostRender(Canvas C) {
	PC = KFTTPlayerController(ViewportOwner.Actor);
	if (PC == None) {
		return;
	}
	
	if (PC.bDrawHitboxes && PC.bWantsDrawHitboxes) {
		PC.DrawHitboxes();
	}
	
	if (PC.bEnableCrosshairs) {
		C.SetPos((float(C.sizeX) - XHAIR_LineWidth) / 2, (float(C.sizeY) - XHAIR_LineLength) / 2);
		C.DrawTile(Texture'Engine.WhiteSquareTexture', XHAIR_LineWidth, XHAIR_LineLength, 0, 0, 2, 2);
		
		C.SetPos((float(C.sizeX) - XHAIR_LineLength) / 2, (float(C.sizeY) - XHAIR_LineWidth) / 2);
		C.DrawTile(Texture'Engine.WhiteSquareTexture', XHAIR_LineLength, XHAIR_LineWidth, 0, 0, 2, 2);
	}
	
	if (PC.MyHUD != None && PC.dmgMsgCount > 0 && PC.damageLifeTime > PC.Level.timeSeconds) {
		DisplayMessages(C);
	}
}

function DisplayMessages(Canvas C) {
	local HUD MyHUD;
	local int i, j, xPos, yPos;
	local float xL, yL;

	MyHUD = PC.MyHUD;
	C.Font = MyHUD.GetConsoleFont(C);
	C.TextSize("A", xL, yL);
	xPos = MyHUD.consoleMessagePosX * MyHUD.hudCanvasScale * C.sizeX + (1.0 - MyHUD.hudCanvasScale) * C.sizeX / 2.0;
	yPos = MyHUD.consoleMessagePosY * MyHUD.hudCanvasScale * C.sizeY + (1.0 - MyHUD.hudCanvasScale) * C.sizeY / 2.0;
	yPos -= yL * (ArrayCount(MyHUD.TextMessages) + PC.dmgMsgCount + 1);
	
	j = Max(0, PC.DamageMessages.length - PC.dmgMsgCount);
	for (i = j; i < PC.DamageMessages.length; i++) {
		C.StrLen(PC.DamageMessages[i], xL, yL);
		C.SetPos(xPos, yPos);
		C.DrawColor = PC.DmgMsgCol;
		C.DrawText(PC.DamageMessages[i], false);
		yPos += yL;
	}
}

defaultproperties
{
     bVisible=True
}
