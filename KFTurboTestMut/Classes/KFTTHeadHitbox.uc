class KFTTHeadHitbox extends Actor;

var KFTurboTestMut Mut;
var KFTTPlayerController LP;
var KFMonster Zed;
var Vector HeadLocation;
var float headScale;

replication {
	reliable if (Role == ROLE_Authority && Mut != None && Mut.bDrawHitboxes && KFTTPlayerController(Level.ReplicationViewer) != None && KFTTPlayerController(Level.ReplicationViewer).bDrawHitboxes)
		HeadLocation, headScale;
}

simulated event PostBeginPlay() {
	Super.PostBeginPlay();
	
	if (Role == ROLE_Authority && Owner != None) {
		SetLocation(Owner.Location);
		SetPhysics(PHYS_None);
		SetBase(Owner);
		Zed = KFMonster(Owner);
	}
	
	LP = KFTTPlayerController(Level.GetLocalPlayerController());
	if (LP != None) {
		LP.AddHitbox(Self);
	}
}

event Tick(float deltaTime) {
	local Coords C;
	local bool bAltHeadLoc;
	
	Super.Tick(deltaTime);
	
	if (Zed == None || Zed.bDecapitated || Zed.HeadBone == '' || Zed.health <= 0) {
		Destroy();
		return;
	}
	
	if (Role < ROLE_Authority || !Mut.bDrawHitboxes) {
		return;
	}
	
	if (Level.NetMode == NM_DedicatedServer && Zed.Physics == PHYS_Walking && !Zed.IsAnimating(0) && !Zed.IsAnimating(1) && !Zed.bIsCrouched) {
		bAltHeadLoc = true;
	}
	
	headScale = Zed.headRadius * Zed.headScale;
	if(bAltHeadLoc) {
		HeadLocation = Zed.Location + (Zed.OnlineHeadshotOffset >> Zed.Rotation);
		if (Level.NetMode == NM_DedicatedServer) {
			headScale *= Zed.onlineHeadshotScale;
		}
	}
	else {
		C = Zed.GetBoneCoords(Zed.HeadBone);
		HeadLocation = C.Origin + (Zed.headHeight * Zed.headScale * C.XAxis);
	}
}

simulated event Destroyed() {
	if (Mut != None) {
		Mut.RemoveHitbox(Self);
	}
	
	if (LP != None) {
		LP.RemoveHitbox(Self);
	}
	
	Super.Destroyed();
}

defaultproperties
{
     bHidden=True
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_SimulatedProxy
     NetPriority=2.000000
}
