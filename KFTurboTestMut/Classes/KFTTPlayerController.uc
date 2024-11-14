class KFTTPlayerController extends TurboPlayerController
	config(User);

const MAX_DamageMessages = 50;
const MSG_Spec = "Sorry, spectators cannot use commands.";
const MSG_Dead = "Sorry, dead players cannot use commands.";
const STR_TeleTag = "SkellsTele";

var KFTurboTestMut Mut;
var KFMonster LastDamagedZed;
var array<Teleporter> Destinations;
var array<KFTTHeadHitbox> HeadHitboxes;
var array<string> KeptWeapons, DamageMessages;
var int hitCount, lastDamage, dmgMsgCount, spotIndex, headCount;
var float lastTriggerMsg, lastTeleport, lastSpawnProj, damageLifeTime;
var bool bHitMultipleZeds, bKeepWeapons, bDrawHitboxes, bInitDestinations;

var config byte numSegments;
var config Color DmgMsgCol, HitboxCol;
var config bool bWantsKeepWeapons, bEnableCrosshairs, bWantsDrawHitboxes;

replication {
	reliable if (bNetInitial && Role == ROLE_Authority)
		Mut;
	
	reliable if (Role == ROLE_Authority)
		bKeepWeapons, bDrawHitboxes;
	
	reliable if (Role == ROLE_Authority)
		ClientClearLevel, AddDamageMessage, SetDamageLifeTime, ClearDamageMessages;
	
	reliable if (Role < ROLE_Authority)
		ServerSetPerk, SetHealth, SetGameSpeed, ClearLevel, ClearZeds, ServerSetKeepWeapons, ServerSetDrawHitboxes, Whoosh, GodMode, ViewZeds, ViewSelf, ForceRadial, SpawnProj;
}

/* OVERRIDEN FUNCTIONS */

simulated function SendSelectedVeterancyToServer(optional bool bForceChange);
function SelectVeterancy(class<KFVeterancyTypes> VetSkill, optional bool bForceChange);
exec function TogglePathToTrader();
function SetShowPathToTrader(bool bShouldShowPath);
simulated function CheckForHint(int hintType);

event ClientOpenMenu(string Menu, optional bool bDisconnect,optional string Msg1, optional string Msg2)
{
	//Attempt fix weird issue where wrong login menu is present.
	if (Menu ~= string(class'ServerPerks.SRInvasionLoginMenu') || Menu ~= string(class'KFGui.KFInvasionLoginMenu'))
	{
		Menu = string(class'KFTurboTestMut.KFTTLoginMenu');
	}

	Super.ClientOpenMenu(Menu, bDisconnect, Msg1, Msg2);	
}

simulated function ClientReceiveLoginMenu(string MenuClass, bool bForce)
{
	if (MenuClass ~= string(class'KFTurbo.TurboInvasionLoginMenu') || MenuClass ~= string(class'ServerPerks.SRInvasionLoginMenu')
		|| MenuClass ~= string(class'KFGui.KFInvasionLoginMenu'))
	{
		MenuClass = string(class'KFTurboTestMut.KFTTLoginMenu');
	}
	
	Super.ClientReceiveLoginMenu(MenuClass, bForce);
}

event ClientMessage(coerce string S, optional Name Type) {
	local string Msg, UseBinds, KeyName;

	if (S ~= "You are already at full health.") {
		return;
	}
	
	if (InStr(S, "Press") != -1 && InStr(S, "USE") != -1) {
		UseBinds = ConsoleCommand("BINDINGTOKEY USE");
		if (UseBinds != "") {
			if (!Divide(UseBinds, ",", KeyName, Msg)) {
				KeyName = UseBinds;
			}

			Msg = Repl(S, "USE", KeyName);
		}
		else {
			Msg = S;
		}
		
		Super.ClientMessage(Msg, Type);
	}
	else {
		Super.ClientMessage(S, Type);
	}
}

function SetPawnClass(string inClass, string inCharacter) {
	inCharacter = class'KFTurboGameType'.static.GetValidCharacter(inCharacter);
	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(inCharacter);
}

function AcknowledgePossession(Pawn P) {
	if (Level.NetMode == NM_Standalone || Role < ROLE_Authority) {
		ServerSetKeepWeapons(bWantsKeepWeapons);
		ServerSetDrawHitboxes(bWantsDrawHitboxes);
	}
	
	Super.AcknowledgePossession(P);
}

/* DAMAGE MESSAGES */

function Timer() {
	ReceiveDamageMessages();
}

function ReceiveDamageMessages() {
	local int bodyHealth, headHealth;
	
	SetTimer(0.00, false);
	
	if (hitCount < 1) {
		return;
	}
	
	AddDamageMessage("Total hits:" @ hitCount, true);
	AddDamageMessage("Total damage:" @ lastDamage);
	
	if (bHitMultipleZeds) {
		AddDamageMessage("Multiple zeds hit");
	}
	else if (LastDamagedZed != None) {
		if (ZombieBoss(LastDamagedZed) == None) {
			headHealth = int(LastDamagedZed.default.headHealth * LastDamagedZed.DifficultyHealthModifer() * Mut.HealthModifer(LastDamagedZed.PlayerNumHeadHealthScale));
			AddDamageMessage("Head health:" @ int(LastDamagedZed.headHealth) @ "/" @ headHealth);
		}
		
		bodyHealth = int(LastDamagedZed.default.health * LastDamagedZed.DifficultyHealthModifer() * Mut.HealthModifer(LastDamagedZed.PlayerCountHealthScale));
		AddDamageMessage("Body health:" @ LastDamagedZed.health @ "/" @ bodyHealth);
	}
	
	bHitMultipleZeds = false;
	LastDamagedZed = None;
	hitCount = 0;
	lastDamage = 0;
	
	SetDamageLifeTime();
}

function AddDamageMessage(coerce string Msg, optional bool bFirst) {
	if (DamageMessages.length > MAX_DamageMessages) {
		DamageMessages.Remove(0, 1);
	}
	
	DamageMessages[DamageMessages.length] = Msg;
	if (bFirst) {
		dmgMsgCount = 1;
	}
	else {
		dmgMsgCount++;
	}
}

function SetDamageLifeTime() {
	damageLifeTime = Level.timeSeconds + class'SayMessagePlus'.default.lifeTime;
}

function ClearDamageMessages() {
	dmgMsgCount = 0;
	if (DamageMessages.length > 0) {
		DamageMessages.Remove(0, DamageMessages.length);
	}
}

function SetDmgMsgCol(Color newColor) {
	DmgMsgCol = newColor;
	SaveConfig();
}

/* HEAD HITBOXES */

function AddHitbox(KFTTHeadHitbox Hitbox) {
	HeadHitboxes[HeadHitboxes.length] = Hitbox;
}

function RemoveHitbox(KFTTHeadHitbox Hitbox) {
	local byte i;
	
	for (i = 0; i < HeadHitboxes.length; i++) {
		if (HeadHitboxes[i] == Hitbox) {
			HeadHitboxes.Remove(i, 1);
			return;
		}
	}
}

function DrawHitboxes() {
	local HUDKillingFloor KFHUD;
	local float scaleMod;
	local byte i;
	
	KFHUD = HUDKillingFloor(MyHUD);
	if (KFHUD == None) {
		return;
	}
	
	KFHUD.ClearStayingDebugLines();
	
	if (HeadHitboxes.length >= class'KFTurboTestMut'.default.MAX_HeadHitboxes) {
		return;
	}
	
	if (Pawn != None && class'KFTurboTestMut'.static.DealsMeleeDamage(Pawn.Weapon)) {
		scaleMod = 1.25;
	}
	else {
		scaleMod = 1.0;
	}
	
	for (i = 0; i < HeadHitboxes.length; i++) {
		if (HeadHitboxes[i] != None) {
			KFHUD.DrawStayingDebugSphere(HeadHitboxes[i].HeadLocation, HeadHitboxes[i].headScale * scaleMod, numSegments, HitboxCol.R, HitboxCol.G, HitboxCol.B);
		}
	}
}

function SetNumSegments(byte newSegments) {
	numSegments = newSegments;
	SaveConfig();
}

function SetHitboxCol(Color newColor) {
	HitboxCol = newColor;
	SaveConfig();
}

function ServerSetDrawHitboxes(bool newDrawHitboxes) {
	bDrawHitboxes = newDrawHitboxes;
	Mut.CheckPlayerHitboxes(Self);
}

function SetDrawHitboxes(bool newDrawHitboxes) {
	bWantsDrawHitboxes = newDrawHitboxes;
	ServerSetDrawHitboxes(newDrawHitboxes);
	if (!bWantsDrawHitboxes && MyHUD != None) {
		MyHUD.ClearStayingDebugLines();
	}
	
	SaveConfig();
}

/* COMMANDS */



function int GetPlayerVeterancyLevel(class<KFVeterancyTypes> NewVet)
{
	local ClientPerkRepLink CPRL;
	local int Index;

	CPRL = class'ClientPerkRepLink'.static.FindStats(self);

	if (CPRL == None)
	{
		return 0;
	}

	for( Index = 0; Index < CPRL.CachePerks.Length; Index++ )
	{
		if (CPRL.CachePerks[Index].PerkClass == NewVet)
		{
			return CPRL.CachePerks[Index].CurrentLevel - 1;
		}
	}

	return 0;
}

function ServerSetPerk(class<KFVeterancyTypes> NewVet)
{
	local KFPlayerReplicationInfo PRI;
	local KFHumanPawn P;
	local ClientPerkRepLink CPRL;
		
	CPRL = class'ClientPerkRepLink'.static.FindStats(self);

	PRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
	if (PRI != None)
	{
		PRI.ClientVeteranSkill = NewVet;
		PRI.ClientVeteranSkillLevel = GetPlayerVeterancyLevel(NewVet);
	}
	
	P = KFHumanPawn(Pawn);

	if (P != None)
	{
		P.VeterancyChanged();
	}
}

exec function SetPerk(string NewPerk, optional int newLevel)
{
	local KFPlayerReplicationInfo PRI;
	local string Msg;
	
	PRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
	if (PRI == None) {
		return;
	}
	
	switch(NewPerk) {
		case "med":
		case "medic":
			SelectedVeterancy = class'KFTurbo.V_FieldMedic';
			break;
		case "supp":
		case "support":
			SelectedVeterancy = class'KFTurbo.V_SupportSpec';
			break;
		case "sharp":
			SelectedVeterancy = class'KFTurbo.V_Sharpshooter';
			break;
		case "cmdo":
		case "mando":
			SelectedVeterancy = class'KFTurbo.V_Commando';
			break;
		case "zerk":
			SelectedVeterancy = class'KFTurbo.V_Berserker';
			break;
		case "fire":
		case "firebug":
			SelectedVeterancy = class'KFTurbo.V_Firebug';
			break;
		case "demo":
			SelectedVeterancy = class'KFTurbo.V_Demolitions';
			break;
		default:
			ClientMessage("Available perk names: med/medic, supp/support, sharp, cmdo/mando, zerk, fire/firebug, demo.");
			return;
	}
	
	Msg = "You are %adv% a %Perk%.";
	Msg = Repl(Msg, "%Perk%", SelectedVeterancy.default.VeterancyName);
	
	if (SelectedVeterancy != PRI.ClientVeteranSkill)
	{
		Msg = Repl(Msg, "%adv%", "now");
		ServerSetPerk(SelectedVeterancy);
		SetSelectedVeterancy(SelectedVeterancy);
		SaveConfig();
	}
	else
	{
		Msg = Repl(Msg, "%adv%", "already");
	}
	
	ClientMessage(Msg);
}

exec function SetHealth(int newNumPlayers) {
	Mut.SetHealth(Self, newNumPlayers);
}

exec function SetGameSpeed(float newSpeed) {
	Mut.SetGameSpeed(Self, newSpeed);
}

function ClientClearLevel() {
	local Pawn TrashPawn;
	local BossHPNeedle TrashNeedle;
	
	forEach DynamicActors(class'Pawn', TrashPawn) {
		if (TrashPawn.Controller == None) {
			TrashPawn.Destroy();
		}
	}
	
	forEach DynamicActors(class'BossHPNeedle', TrashNeedle) {
		TrashNeedle.Destroy();
	}
}

exec function ClearLevel() {
	Mut.ClearLevel(Self);
}

exec function ClearZeds() {
	Mut.ClearZeds(Self);
}

function ServerSetKeepWeapons(bool newKeepWeapons) {
	bKeepWeapons = newKeepWeapons;
}

function SetKeepWeapons(bool newKeepWeapons) {
	bWantsKeepWeapons = newKeepWeapons;
	ServerSetKeepWeapons(newKeepWeapons);
	SaveConfig();
}

function SetEnableCrosshairs(bool newEnableCrosshairs) {
	bEnableCrosshairs = newEnableCrosshairs;
	SaveConfig();
}

function InitDestinations() {
	local Teleporter T;
	local int i, j;
	
	forEach AllActors(class'Teleporter', T) {
		if (T != None && Left(T.Tag, Len(STR_TeleTag)) ~= STR_TeleTag) {
			Destinations[Destinations.length] = T;
		}
	}
	
	for (i = 0; i < Destinations.length - 1; i++) {
		for (j = i + 1; j < Destinations.length; j++) {
			if (int(Mid(Destinations[i].Tag, Len(STR_TeleTag))) > int(Mid(Destinations[j].Tag, Len(STR_TeleTag)))) {
				T = Destinations[i];
				Destinations[i] = Destinations[j];
				Destinations[j] = T;
			}
		}
	}
	
	if (Destinations.length == 0) {
		T = Teleporter(Level.Game.FindPlayerStart(Self));
		if (T != None) {
			Destinations[0] = T;
		}
	}
	
	bInitDestinations = true;
}

exec function Whoosh() {
	if (!bInitDestinations) {
		InitDestinations();
	}
	
	if (Destinations.length == 0) {
		ClientMessage("No destinations found");
		return;
	}
	
	if (lastTeleport > 0.0 && Level.timeSeconds - lastTeleport < 10.0) {
		spotIndex = ++spotIndex % Destinations.length;
	}
	else {
		spotIndex = 0;
	}
	
	if (Pawn != None) {
		if (Pawn.Location == Destinations[spotIndex].Location) {
			spotIndex = ++spotIndex % Destinations.length;
		}

		Pawn.SetLocation(Destinations[spotIndex].Location) ;
		Pawn.SetPhysics(PHYS_Falling);
		Pawn.SetOwner(Pawn.Owner);
	}
	else {
		if (Location == Destinations[spotIndex].Location) {
			spotIndex = ++spotIndex % Destinations.length;
		}
		
		SetLocation(Destinations[spotIndex].Location);		
	}
	
	lastTeleport = Level.timeSeconds;
}

exec function Trade() {
	if (KFHumanPawn(Pawn) != None) {
		Player.GUIController.CloseMenu();
		ShowBuyMenu("WeaponLocker", KFHumanPawn(Pawn).maxCarryWeight);
	}
}

exec function GodMode() {
	bGodMode = !bGodMode;
	if (bGodMode) {
		ClientMessage("God mode on");
	}
	else {
		ClientMessage("God mode off");
	}
}

exec function ViewZeds() {
	local Actor First;
	local bool bFound;
	local Controller C;

	for (C = Level.ControllerList; C != None; C = C.NextController) {
		if (C.IsA('KFMonsterController') && C.Pawn != None) {
			if (bFound || First == None) {
				First = C;
				if (bFound)
					break;
			}
			
			if (C == RealViewTarget)
				bFound = true;
		}
	}

	if (First != None) {
		SetViewTarget(First);
		ClientSetViewTarget(First);
		bBehindView = true;
		ClientSetBehindView(true);
		ClientMessage(ViewingFrom @ KFTTGameType(Level.Game).GetNameOf(KFMonsterController(First).Pawn));
	}
	else {
		ClientMessage("No zeds found");
	}
}

exec function ViewSelf(optional bool bSilent) {
	if (Pawn != None) {
		SetViewTarget(Pawn);
		ClientSetViewTarget(Pawn);
	}
	else {
		SetViewTarget(Self);
		ClientSetViewTarget(Self);
	}
	
	bBehindView = false;
	ClientSetBehindView(false);
	if (!bSilent)
		ClientMessage(OwnCamera);
}

exec function ForceRadial() {
	Mut.ForceRadial(Self);
}

function KFTTProjBase SpawnProj(class<KFTTProjBase> ProjClass) {
	if (Pawn != None && Pawn.Weapon != None && Level.timeSeconds - lastSpawnProj > 0.1) {
		lastSpawnProj = Level.timeSeconds;
		
		if (bBehindView) {
			return Pawn.Weapon.Spawn(ProjClass,,, Pawn.Location + Pawn.EyeHeight * Vect(0, 0, 1), Pawn.Rotation);
		}
		else {
			return Pawn.Weapon.Spawn(ProjClass,,, Pawn.Location + Pawn.EyeHeight * Vect(0, 0, 1), Rotation);
		}
	}
	
	return None;
}

exec function Poof() {
	SpawnProj(class'KFTurboTestMut.KFTTProjPoof');
}

/* STATES */

auto state PlayerWaiting {
	ignores SeePlayer, HearNoise, NotifyBump, TakeDamage, PhysicsVolumeChange, NextWeapon, PrevWeapon, SwitchToBestWeapon, ReceiveDamageMessages;

	exec function Fire(optional float F) {
		LoadPlayers();
		if (!bForcePrecache && Level.timeSeconds > 0.2)
			ServerRestartPlayer();
	}
	
	exec function SetPerk(string NewPerk, optional int newLevel) {
		ClientMessage(MSG_Dead);
	}

	exec function SetHealth(int newNumPlayers) {
		ClientMessage(MSG_Dead);
	}

	exec function SetGameSpeed(float newSpeed) {
		ClientMessage(MSG_Dead);
	}

	exec function ClearLevel() {
		ClientMessage(MSG_Dead);
	}
	
	exec function ClearZeds() {
		ClientMessage(MSG_Dead);
	}
	
	exec function Whoosh() {
		ClientMessage(MSG_Dead);
	}
	
	exec function Trade() {
		ClientMessage(MSG_Dead);
	}
	
	exec function GodMode() {
		ClientMessage(MSG_Dead);
	}
	
	exec function ForceRadial() {
		ClientMessage(MSG_Dead);
	}
}

state Dead {
	ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, NextWeapon, PrevWeapon, PawnDied, ReceiveDamageMessages;
	
	exec function Fire(optional float F) {
		LoadPlayers();
		if (!bForcePrecache && Level.timeSeconds > 0.2)
			ServerRestartPlayer();
	}
	
	exec function SetPerk(string NewPerk, optional int newLevel) {
		ClientMessage(MSG_Dead);
	}

	exec function SetHealth(int newNumPlayers) {
		ClientMessage(MSG_Dead);
	}

	exec function SetGameSpeed(float newSpeed) {
		ClientMessage(MSG_Dead);
	}

	exec function ClearLevel() {
		ClientMessage(MSG_Dead);
	}
	
	exec function ClearZeds() {
		ClientMessage(MSG_Dead);
	}
	
	exec function Whoosh() {
		ClientMessage(MSG_Dead);
	}
	
	exec function Trade() {
		ClientMessage(MSG_Dead);
	}
	
	exec function GodMode() {
		ClientMessage(MSG_Dead);
	}
	
	exec function ForceRadial() {
		ClientMessage(MSG_Dead);
	}
}

state Spectating {
	ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide, ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange, ReceiveDamageMessages;
	
	exec function SetPerk(string NewPerk, optional int newLevel) {
		ClientMessage(MSG_Spec);
	}

	exec function SetHealth(int newNumPlayers) {
		ClientMessage(MSG_Spec);
	}

	exec function SetGameSpeed(float newSpeed) {
		ClientMessage(MSG_Spec);
	}

	exec function ClearLevel() {
		ClientMessage(MSG_Spec);
	}
	
	exec function ClearZeds() {
		ClientMessage(MSG_Spec);
	}
	
	exec function Whoosh() {
		ClientMessage(MSG_Spec);
	}
	
	exec function Trade() {
		ClientMessage(MSG_Spec);
	}
	
	exec function GodMode() {
		ClientMessage(MSG_Spec);
	}
	
	exec function ForceRadial() {
		ClientMessage(MSG_Spec);
	}
}

defaultproperties
{
	NumSegments=10
	DmgMsgCol=(B=255,G=255,R=255,A=255)
	HitboxCol=(B=255,G=255,A=255)
	SelectedVeterancy = class'KFTurbo.V_Sharpshooter';
	bWantsTraderPath=False
	bChangedVeterancyThisWave=True
	MidGameMenuClass="KFTurboTestMut.KFTTLoginMenu"
	SteamStatsAndAchievementsClass=Class'KFTurboTestMut.KFTTSteamStatsAndAchievements'
	PawnClass=Class'KFTurboTestMut.KFTTHumanPawn'
	LobbyMenuClassString="KFTurbo.TurboLobbyMenu"
}
