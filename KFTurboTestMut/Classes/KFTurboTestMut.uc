class KFTurboTestMut extends Mutator;

var const byte MAX_HeadHitboxes;
var const float TIME_ClearDelay;

var array<KFMonster> MonsterList;
var array<KFTTHeadHitbox> HeadHitboxes;
var int numPlayers, hitboxCount;
var float gameSpeed, timeClearedZeds, timeClearedLevel;
var bool bWaitClearZeds, bWaitClearLevel, bDrawHitboxes;

var bool bInitializedInteraction;

replication {
	reliable if (Role == ROLE_Authority)
		numPlayers, gameSpeed, bWaitClearZeds, bWaitClearLevel;
}

static function class<DamageType> GetDamageType(Weapon W) {
	local class<WeaponFire> FireClass;
	
	if (W == None) {
		return None;
	}
	
	FireClass = W.default.FireModeClass[0];
	if (class<KFMeleeFire>(FireClass) != None) {
		return class<KFMeleeFire>(FireClass).default.HitDamageClass;
	}
	else if (class<InstantFire>(FireClass) != None) {
		return class<InstantFire>(FireClass).default.DamageType;
	}
	else if (class<BaseProjectileFire>(FireClass) != None && FireClass.default.ProjectileClass != None) {
		if (class<LAWProj>(FireClass.default.ProjectileClass) != None) {
			return class<LAWProj>(FireClass.default.ProjectileClass).default.ImpactDamageType;
		}
		
		return FireClass.default.ProjectileClass.default.MyDamageType;
	}
	
	return None;
}

static function bool DealsMeleeDamage(Weapon W) {
	local class<DamageType> DmgClass;
	
	DmgClass = static.GetDamageType(W);
	
	return class<DamTypeMelee>(DmgClass) != None;
}

static function bool IsRequiredWeapon(Inventory W) {
	return KFWeapon(W) != None && (Knife(W) != None || Single(W) != None || Frag(W) != None || Syringe(W) != None || Welder(W) != None);
}

function float HealthModifer(float hpScale) {
	return 1.0 + (numPlayers - 1) * hpScale;
}

function PostBeginPlay() {
	local KFTTGameType GT;
	local KFTTGameRules GR;
		
	Super.PostBeginPlay();
		
	GT = KFTTGameType(Level.Game);
	if (GT == None) {
		Level.ServerTravel("?game=KFTurboTestMut.KFTTGameType", true);
	}
	else {
		GR = Spawn(class'KFTTGameRules');
		GR.Mut = Self;
		if (GT.GameRulesModifiers == None) {
			GT.GameRulesModifiers = GR;
		}
		else {
			GT.GameRulesModifiers.AddGameRules(GR);
		}
		
		GT.HUDType = string(class'KFTTHUD');
	
		if (!ClassIsChildOf(GT.PlayerControllerClass, class'KFTTPlayerController')) {
			GT.PlayerControllerClass = class'KFTTPlayerController';
			GT.PlayerControllerClassName = string(class'KFTTPlayerController');
		}
	}
}

function bool ReplaceActorClass(out class<Actor> MC)
{
    local class<KFMonstersCollection> MColl;
    local string MCName;
    local byte i, l;
       
    if (class'KFTurboGameType'.default.MonsterCollection == None) {
            return false;
    }
       
    MColl = class'KFTurboGameType'.default.MonsterCollection;
       
    if(MC == None || InStr(MC, "Boss") != -1)
	{
        return false;
    }
       
    for (i = 0; i < class'KFTurboGameType'.default.MonsterCollection.default.StandardMonsterClasses.length; i++)
	{
        MCName = MColl.default.StandardMonsterClasses[i].MClassName;
            l = Min(Len(MCName), Len(string(MC)));
            if (Left(MCName, l) ~= Left(string(MC), l))
			{
                MC = class<KFMonster>(DynamicLoadObject(MCName, class'Class'));
                return true;
            }
    }
    return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
	local KFMonster Zed;
	local float newHp, newHeadHp;
	local byte i;
	
	Zed = KFMonster(Other);
	if (Zed != None) {
		newHp = Zed.health / Zed.NumPlayersHealthModifer() * HealthModifer(Zed.PlayerCountHealthScale);
		newHeadHp = Zed.headHealth / Zed.NumPlayersHeadHealthModifer() * HealthModifer(Zed.PlayerNumHeadHealthScale);
		Zed.health = newHp;
		Zed.healthMax = newHp;
		Zed.headHealth = newHeadHp;
		if (numPlayers > 1 && Level.Game.numPlayers == 1) {
			Zed.MeleeDamage /= 0.75;
			Zed.spinDamConst /= 0.75;
			Zed.spinDamRand /= 0.75;
			Zed.screamDamage /= 0.75;
		}
		
		//Do not spawn hitboxes for wave simulation monsters.
		MonsterList[MonsterList.Length] = Zed;
	}
	else if (Other.IsA('KFTTPlayerController')) {
		KFTTPlayerController(Other).Mut = Self;
	}
	else if (Other.IsA('Pickup')) {
		if (Other.IsA('FirstAidKit')) {
			FirstAidKit(Other).respawnTime = 0.5;
			FirstAidKit(Other).respawnEffectTime = 0.0;
			FirstAidKit(Other).healingAmount = 666;
		}
		else if (Other.IsA('Vest')) {
			Vest(Other).respawnTime = 0.5;
			Vest(Other).respawnEffectTime = 0.0;
		}
	}
	else if (Other.IsA('NoZedUseTriggerP')) {
		NoZedUseTrigger(Other).Message = Repl(NoZedUseTrigger(Other).Message, "Press 'E'", "Press 'USE'");
	}
	else if (Other.IsA('ScriptedTrigger')) {
		for (i = 0; i < ScriptedTrigger(Other).Actions.length; i++) {
			if (ACTION_SpawnActor(ScriptedTrigger(Other).Actions[i]) != None) {
				ReplaceActorClass(ACTION_SpawnActor(ScriptedTrigger(Other).Actions[i]).ActorClass);
			}
		}
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

function ModifyPlayer(Pawn Other) {
	if (KFHumanPawn(Other) != None && KFHumanPawn(Other).PlayerReplicationInfo != None) {
		KFHumanPawn(Other).PlayerReplicationInfo.score = 50000;
	}
	
	Super.ModifyPlayer(Other);
}

function NotifyLogout(Controller Exiting) {
	local KFTTGameType GT;
	
	GT = KFTTGameType(Level.Game);
	if (GT != None && GT.numPlayers == 0 && GT.numSpectators == 0) {
		ClearZeds();
		ClearLevel();
	}
	
	Super.NotifyLogout(Exiting);
}

simulated function Tick(float DeltaTime)
{
	local int Index;
	
	if (Level.NetMode != NM_DedicatedServer && !bInitializedInteraction && Level.GetLocalPlayerController() != None)
	{
		Level.GetLocalPlayerController().Player.InteractionMaster.AddInteraction("KFTurboTestMut.KFTTInteraction", Level.GetLocalPlayerController().Player);
		bInitializedInteraction = true;

		if (Role != ROLE_Authority)
		{
			Disable('Tick');
		}
	}

	for (Index = MonsterList.Length - 1; Index >= 0; Index--)
	{
		if (MonsterList[Index] == None || MonsterList[Index].Tag == 'WaveSimulation')
		{
			continue;
		}

		AddHitbox(MonsterList[Index]);
	}

	MonsterList.Length = 0;
}

function Timer() {
	if (bWaitClearZeds && Level.timeSeconds - timeClearedZeds > TIME_ClearDelay) {
		bWaitClearZeds = false;
	}

	if (bWaitClearLevel && Level.timeSeconds - timeClearedLevel > TIME_ClearDelay) {
		bWaitClearLevel = false;
	}
	
	if (!bWaitClearZeds && !bWaitClearLevel) {
		SetTimer(0.00, false);
	}
}

/* HITBOXES */

function AddHitbox(KFMonster Zed) {
	local KFTTHeadHitbox NewHitbox;
	
	NewHitbox = Spawn(class'KFTurboTestMut.KFTTHeadHitbox', Zed);
	if (NewHitbox != None) {
		NewHitbox.Mut = Self;
		HeadHitboxes[HeadHitboxes.length] = NewHitbox;
		CheckHitboxes();
	}
}

function RemoveHitbox(KFTTHeadHitbox Hitbox) {
	local byte i;
	
	for (i = HeadHitboxes.Length - 1; i >= 0; i--) {
		if (HeadHitboxes[i] == Hitbox) {
			HeadHitboxes.Remove(i, 1);
			break;
		}
	}
	
	CheckHitboxes();
}

function CheckHitboxes() {
	local Controller C;
	
	if (HeadHitboxes.length >= MAX_HeadHitboxes) {
		if (bDrawHitboxes) {
			bDrawHitboxes = false;
			for (C = Level.ControllerList; C != None; C = C.NextController) {
				CheckPlayerHitboxes(KFTTPlayerController(C));
			}
		}
	}
	else {
		CheckDrawHitboxes();
	}
}

function CheckPlayerHitboxes(KFTTPlayerController Sender) {
	if (Sender != None) {
		if (HeadHitboxes.length >= MAX_HeadHitboxes) {
			if (Sender.bDrawHitboxes) {
				Sender.ClientMessage("WARNING: Head hitboxes will be shown only when the number of zeds alive is less than" @ MAX_HeadHitboxes);
			}
		}
		else {
			CheckDrawHitboxes();
		}
	}
}

function CheckDrawHitboxes() {
	local Controller C;
	local bool bNewDrawHitboxes;
	
	bNewDrawHitboxes = false;
	for (C = Level.ControllerList; C != None; C = C.NextController) {
		if (KFTTPlayerController(C) != None) {
			if (KFTTPlayerController(C).bDrawHitboxes) {
				bNewDrawHitboxes = true;
				break;
			}
		}
	}
	
	if (bDrawHitboxes != bNewDrawHitboxes) {
		bDrawHitboxes = bNewDrawHitboxes;
	}
}

/* COMMANDS */

function string GetPlayerName(PlayerController Sender) {
	if (Sender == None) {
		return "Someone";
	}
	else {
		return Sender.GetHumanReadableName();
	}
}

function SetHealth(PlayerController Sender, int newNumPlayers) {
	local int i;
	
	i = Clamp(newNumPlayers, 1, 99);
	if (numPlayers == i) {
		Sender.ClientMessage("Health already scaled to" @ numPlayers @ "player(s)");
	}
	else {
		numPlayers = i;
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "scaled health to" @ numPlayers @ "player(s)");
	}
}

function SetGameSpeed(PlayerController Sender, float newSpeed) {
	local float f;

	f = FClamp(newSpeed, 0.1, 1.0);
	if (gameSpeed == f) {
		Sender.ClientMessage("Speed already set to" @ gameSpeed);
	}
	else {
		gameSpeed = f;
		Level.Game.SetGameSpeed(gameSpeed);
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "set the game speed to" @ gameSpeed);
	}
}

function ClearZeds(optional PlayerController Sender) {
	local KFMonster TrashMonster;
	
	if (!bWaitClearZeds) {
		forEach DynamicActors(class'KFMonster', TrashMonster) {
			TrashMonster.Destroy();
		}

		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "removed all zeds");
		
		timeClearedZeds = Level.timeSeconds;
		bWaitClearZeds = true;
		if (!bWaitClearLevel) {
			SetTimer(1.00, true);
		}
	}
}

function ClearLevel(optional PlayerController Sender) {
	local Pawn TrashPawn;
	local KFWeaponPickup TrashPickup;
	local Projectile TrashProjectile;
	local BossHPNeedle TrashNeedle;
	local KFDoorMover KFDM;
	local Controller C;
	
	if (!bWaitClearLevel) {
		forEach DynamicActors(class'Pawn', TrashPawn) {
			if (TrashPawn.Controller == None) {
				TrashPawn.Destroy();
			}
		}
		
		forEach DynamicActors(class'KFWeaponPickup', TrashPickup) {
			if (KFHumanPawn(TrashPickup.Owner) == None) {
				TrashPickup.Destroy();
			}
		}
			
		forEach DynamicActors(class'Projectile', TrashProjectile) {
			TrashProjectile.Destroy();
		}
		
		forEach DynamicActors(class'BossHPNeedle', TrashNeedle) {
			TrashNeedle.Destroy();
		}
		
		foreach DynamicActors(class'KFDoorMover', KFDM) {
			if (KFDM.bDoorIsDead) {
				KFDM.RespawnDoor();
			}
			else {
				KFDM.SetWeldStrength(0.0);
				if (KFDM.MyTrigger != None) {
					KFDM.MyTrigger.WeldStrength = 0;
				}
			}
		}

		for (C = Level.ControllerList; C != None; C = C.NextController) {
			if (KFTTPlayerController(C) != None) {
				KFTTPlayerController(C).ClientClearLevel();
				KFTTPlayerController(C).ClientForceCollectGarbage();
			}
		}
		
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "cleaned up the level");
		
		timeClearedLevel = Level.timeSeconds;
		bWaitClearLevel = true;
		if (!bWaitClearZeds) {
			SetTimer(1.00, true);
		}
	}
}

function ForceRadial(PlayerController Sender) {
	local ZombieBoss LevelBoss;
	local byte bossCount;

	forEach DynamicActors(class'ZombieBoss', LevelBoss) {
		if (!LevelBoss.IsInState('RadialAttack')) {
			LevelBoss.GotoState('RadialAttack');
			bossCount++;
		}
	}
	
	if (bossCount > 0) {
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "forced radial attack for" @ bossCount @ "Patriarch(s)");
	}
	else {
		Sender.ClientMessage("No Patriarchs found");
	}
}

simulated function String GetHumanReadableName()
{
	return FriendlyName;
}

defaultproperties
{
     MAX_HeadHitboxes=32
     TIME_ClearDelay=10.000000
     NumPlayers=6
     GameSpeed=1.000000
     bAddToServerPackages=True
     GroupName="KFPerkTest"
     FriendlyName="Killing Floor Turbo Practice"
     Description="Adds features to help players practice the KFTurbo mod."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
