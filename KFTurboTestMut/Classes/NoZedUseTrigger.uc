class NoZedUseTrigger extends UseTrigger;

var float flReFireDelay, lastAttempt;

function UsedBy(Pawn User) {
	if (Level.timeSeconds - lastAttempt < flReFireDelay || User.IsA('KFMonster') || KFHumanPawn(User) == None)
		return;
	
	lastAttempt = Level.timeSeconds;
	
	Super.UsedBy(User);
}

function Touch(Actor Other) {
	local Pawn P;
	local KFTTPlayerController C;
	
	P = KFHumanPawn(Other);
	if (P == None)
		return;

	C = KFTTPlayerController(P.Controller);
	if (C != None && P.health > 0 && Message != "") {
		if (Level.timeSeconds - C.lastTriggerMsg > 0.1) {
			C.ClientMessage(Message);
			C.lastTriggerMsg = Level.timeSeconds;
		}
	}
}

defaultproperties
{
     flReFireDelay=0.500000
     bDirectional=True
}
