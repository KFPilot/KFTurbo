//Killing Floor Turbo TurboPlayerController
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboPlayerController extends CorePlayerController;

var private ClientPerkRepLink ClientPerkRepLink;	
var private TurboRepLink TurboRepLink;
var class<WeaponRemappingSettings> WeaponRemappingSettings;
var TurboInteraction TurboInteraction;
var TurboChatInteraction TurboChatInteraction;
var class<TurboCommandHandler> TurboCommandHandlerClass; //Can be modified in a Mutator's CheckReplacement() within a submodule. 
var TurboCommandHandler TurboCommandHandler;

var float ClientNextMarkTime, NextMarkTime;
var float VoteCooldownTime, NextVoteTime;
var float NextStartVoteTime;

var class<TurboSpectatorActor> SpectatorActorClass;
var TurboSpectatorActor SpectatorActor;
var float NextSpectateUseTargetTime, SpectateUseTargetCooldown;

var bool bInLoginMenu, bHasClosedLoginMenu;
var float LoginMenuTime;

var array< TurboPlayerEventHandler > PlayerEventHandlerList;

var bool bPipebombUsesSpecialGroup;

var array< class<PerkLockTurboLocalMessage> > PerkChangeLockList;

var protected array<TurboOptionObject> ExternalOptionList;

replication
{
	reliable if( Role == ROLE_Authority )
		ClientCloseBuyMenu;
	reliable if( Role < ROLE_Authority )
		ServerSetPipebombUsesSpecialGroup;
	reliable if( Role < ROLE_Authority )
		Vote, VoteTest, ServerMarkActor, ServerNotifyShoppingState, ServerNotifyLoginMenuState;
	reliable if( Role < ROLE_Authority )
		ServerDebugSkipWave, ServerDebugRestartWave, ServerDebugSetWave, ServerDebugPreventGameOver, ServerDebugSpawnFriend;
	reliable if( Role < ROLE_Authority )
		AdminSetTraderTime, AdminSetMaxPlayers, AdminSetFakedPlayer, AdminSetPlayerHealth, AdminSetSpawnRate, AdminSetMaxMonsters, AdminShowSettings;
}

simulated function PostBeginPlay()
{
	//For some reason this really does not like getting set!
	if (class<TurboPlayerReplicationInfo>(PlayerReplicationInfoClass) == None)
	{
		PlayerReplicationInfoClass = class'TurboPlayerReplicationInfo';
	}

	Super.PostBeginPlay();

	if (Role != ROLE_Authority)
	{
		//Spin up CPRL fixer
		Spawn(class'TurboRepLinkFix', Self);
	}

	if (Role == ROLE_Authority && !Level.bLevelChange)
	{
		CreateCommandHandler();
	}
}

simulated function CreateCommandHandler()
{
	if (TurboCommandHandlerClass == None)
	{
		TurboCommandHandlerClass = class'TurboCommandHandler';
	}

	TurboCommandHandler = Spawn(TurboCommandHandlerClass, Self);
}

simulated function InitInputSystem()
{
	Super.InitInputSystem();

	if (!Level.bLevelChange)
	{
		SetupTurboInteraction();
	}
}

exec function ChangeCharacter(string newCharacter, optional string inClass)
{
	Super.ChangeCharacter(newCharacter,inClass);

	if (Level.NetMode == NM_Standalone && xPawn(Pawn) != None && PawnSetupRecord.Species != None)
	{
		xPawn(Pawn).bAlreadySetup = false;
		PawnSetupRecord.Species.static.Setup(Pawn, PawnSetupRecord);
	}
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (LoginMenuTime >= 0.f && (LoginMenuTime < Level.TimeSeconds) && IsLocalPlayerController())
	{
		ServerNotifyLoginMenuState(false);
		LoginMenuTime = -1.f;
	}
}

simulated final function bool IsLocalPlayerController()
{
	return Viewport(Player) != None;
}

function ClientPerkRepLink GetClientPerkRepLink()
{
	if (ClientPerkRepLink == None)
	{
		ClientPerkRepLink = Class'ClientPerkRepLink'.Static.FindStats(Self);
	}

	return ClientPerkRepLink;
}

function TurboRepLink GetTurboRepLink()
{
	if (TurboRepLink == None)
	{
		TurboRepLink = class'TurboRepLink'.static.FindTurboRepLink(Self);
	}

	return TurboRepLink;
}

simulated function SetupTurboInteraction()
{
	if (Level.NetMode == NM_DedicatedServer)
	{
		return;
	}

	if (Player == None || Player.InteractionMaster == None)
	{
		return;
	}

	if (TurboInteraction == None)
	{
		TurboInteraction = TurboInteraction(Player.InteractionMaster.AddInteraction("KFTurbo.TurboInteraction", Player));

		if (TurboInteraction != None)
		{
			TurboInteraction.OnInteractionCreated();
		}
	}

	if (TurboChatInteraction == None)
	{
		TurboChatInteraction = TurboChatInteraction(Player.InteractionMaster.AddInteraction("KFTurbo.TurboChatInteraction", Player));
	}
}

function ServerNotifyShoppingState(bool bNewShoppingState)
{
	if (KFGameType(Level.Game) == None || KFGameType(Level.Game).bWaveInProgress)
	{
		bNewShoppingState = false;
	}

	bShopping = bNewShoppingState;
}

//Holding escape would allow for people to spam the server with the ServerNotifyLoginMenuState RPC inadvertently...
simulated function SetLoginMenuState(bool bNewLoginMenuState)
{
	if (bNewLoginMenuState)
	{
		if (bHasClosedLoginMenu)
		{
			ServerNotifyLoginMenuState(true);
			LoginMenuTime = -1.f;
			bHasClosedLoginMenu = false;
		}
	}
	else
	{
		LoginMenuTime = Level.TimeSeconds + 1.f;
		bHasClosedLoginMenu = true;
	}
}

function ServerNotifyLoginMenuState(bool bNewLoginMenuState)
{
	bInLoginMenu = bNewLoginMenuState;
}

simulated function ClientSetHUD(class<HUD> newHUDClass, class<Scoreboard> newScoringClass )
{
	if (class<TurboHUDKillingFloor>(newHUDClass) == None)
	{
		Super.ClientSetHUD(class'KFTurbo.TurboHUDKillingFloor', newScoringClass);
	}

	Super.ClientSetHUD(newHUDClass, newScoringClass);
}

event ClientOpenMenu(string Menu, optional bool bDisconnect,optional string Msg1, optional string Msg2)
{
	//Attempt fix weird issue where wrong login menu is present.
	if (Menu ~= string(class'ServerPerks.SRInvasionLoginMenu') || Menu ~= string(class'KFGui.KFInvasionLoginMenu'))
	{
		Menu = string(class'KFTurbo.TurboInvasionLoginMenu');
	}

	if (Menu ~= string(class'ServerPerks.SRLobbyMenu') || Menu ~= string(class'KFGui.LobbyMenu'))
	{
		Menu = string(class'KFTurbo.TurboLobbyMenu');
	}

	Super.ClientOpenMenu(Menu, bDisconnect, Msg1, Msg2);	
}

//Returns true if player joined in the last 10 seconds.
final simulated function bool PlayerJoinedRecently()
{
	return PlayerReplicationInfo == None || PlayerReplicationInfo.StartTime == 0.f || Level.GRI == None || (Abs(Level.GRI.ElapsedTime - PlayerReplicationInfo.StartTime) < 10);
}

simulated event ReceiveLocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	local class<TurboLocalMessage> TurboLocalMessage;
	local string LocalMessageString;

	if (Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None)
	{
		return;
	}

	switch(Message)
	{
		case class'KFMod.WaitingMessage':
			Message = class'TurboMessageWaiting';
			break;
		case class'UnrealGame.PickupMessagePlus':
			Message = class'TurboMessagePickup';
			break;
		case class'ServerPerks.KFVetEarnedMessageSR':
			if (PlayerJoinedRecently())
			{
				return;
			}
			Message = class'TurboMessageVeterancy';
			break;
	}

	TurboLocalMessage = class<TurboLocalMessage>(Message);

	if (TurboLocalMessage != None && TurboLocalMessage.static.IgnoreLocalMessage(Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject))
	{
		return;
	}

    Message.Static.ClientReceive( Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
	
	if (Player == None || Player.Console == None)
	{
		return;
	}

	LocalMessageString = Message.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (Message.static.IsConsoleMessage(Switch))
	{
		Player.Console.Message(LocalMessageString, 0);
	}
	
	if (TurboLocalMessage != None && TurboLocalMessage.static.IsRelevantToInGameChat(Self, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject) && ExtendedConsole(Player.Console) != None)
	{
		ExtendedConsole(Player.Console).OnChat(LocalMessageString, 0);
	}
}

function ClientLocationalVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name MessageType, byte MessageIndex, optional Pawn SoundSender, optional vector SenderLocation)
{
	local class<VoicePack> VoicePack;
	VoicePack = Sender.VoiceType;
	if (MessageType == 'TRADER' && class'TurboInteraction'.static.UseMerchantReplacement(Self))
	{
		Sender.VoiceType = class'MerchantVoicePack';
	}

	Super.ClientLocationalVoiceMessage(Sender, Recipient, MessageType, MessageIndex, SoundSender, SenderLocation);

	Sender.VoiceType = VoicePack;

	if (TurboHUDKillingFloor(myHUD) != None)
	{
		TurboHUDKillingFloor(myHUD).ReceivedVoiceMessage(Sender, MessageType, MessageIndex, SoundSender, SenderLocation);
	}
}

exec function Speech( Name Type, int Index, string CallSign )
{
	if (Pawn != None && TurboInteraction != None)
	{
		TurboInteraction.CheckForVoiceCommandMark(Type, Index);
	}

	Super.Speech(Type, Index, CallSign);

	//Route voice commands for "Yes" and "No" to voting.
	if (Type == 'ACK' && (Index == 0 || Index == 1))
	{
		Vote(Eval(Index == 0, "YES", "NO"));
	}
}

function bool AllowTextMessage(string Msg)
{
	if (Level.NetMode == NM_Standalone || PlayerReplicationInfo.bAdmin || PlayerReplicationInfo.bSilentAdmin)
	{
		return true;
	}

	if (Level.TimeSeconds - LastBroadcastTime > 0.75f)
	{
		LastBroadcastTime = Level.TimeSeconds;
		return true;
	}

	return false;
}

function ServerSay(string Msg)
{
	Super.ServerSay(Msg);

	if (Len(Msg) > 10)
	{
		return;
	}

	Msg = Caps(Msg);

	switch(Msg)
	{
		case "YES":
		case ":YESYES:":
			Vote("YES");
			break;
		case "NO":
		case ":NONO:":
			Vote("NO");
			break;
	}
}

event TeamMessage(PlayerReplicationInfo PRI, coerce string Message, name Type)
{
	local string MessagePrefix;
	local string RedColorString, WhiteColorString;

	if (Level.NetMode == NM_DedicatedServer || GameReplicationInfo == None)
	{
		return;
	}

	if (AllowTextToSpeech(PRI, Type))
	{
		TextToSpeech(Message, TextToSpeechVoiceVolume);
	}

	if (Type == 'TeamSayQuiet')
	{
		Type = 'TeamSay';
	}

	if (myHUD != None)
	{
		myHUD.Message(PRI, MessagePrefix $ Message, Type);
	}

	if (Player == None || Player.Console == None)
	{
		return;
	}

	RedColorString = chr(27)$chr(200)$chr(1)$chr(1);
	WhiteColorString = chr(27)$chr(255)$chr(255)$chr(255);

	if (Type != 'TRADER' && PRI != None && PRI.Team != None && GameReplicationInfo.bTeamGame && PRI.Team.TeamIndex == 0)
	{
		MessagePrefix = RedColorString;
	}
	else
	{
		MessagePrefix = WhiteColorString;
	}

	//Trader should be prefixed with trader, not the client's PlayerName.
	if (Type == 'TRADER')
	{
		MessagePrefix = MessagePrefix $ class'HUDKillingFloor'.default.TraderString $ ": ";
	}
	else if (PRI != None)
	{
		MessagePrefix = MessagePrefix $ PRI.PlayerName $ ": " ;
	}
	else
	{
		MessagePrefix = "";
	}

	Player.Console.Chat(MessagePrefix $ WhiteColorString $ class'GUIComponent'.static.StripColorCodes(Message), 6.0, PRI);
}

function AttemptMarkActor(vector Start, vector End, Actor TargetActor, class<TurboMarkerType> DataClassOverride, int DataOverride, TurboPlayerMarkReplicationInfo.EMarkColor Color)
{
	local TurboPlayerMarkReplicationInfo TurboMarkPRI;
	local Pickup FoundPickup;

	if ((TargetActor == None || TargetActor.bWorldGeometry) && (Player != None))
	{
		foreach CollidingActors(class'Pickup', FoundPickup, 40.f, End)
			break;

		if (FoundPickup == None)
		{
			return;
		}

		TargetActor = FoundPickup;

		if (TargetActor == None || TargetActor.bWorldGeometry)
		{
			return;
		}
	}
	
    if (Pawn(TargetActor.Base) != None)
    {
        TargetActor = TargetActor.Base;
    }
	
	if (Role != ROLE_Authority)
	{
		ServerMarkActor(Start, End, TargetActor, DataClassOverride, DataOverride, Color);
		return;
	}

	if (NextMarkTime > Level.TimeSeconds)
	{
		return;
	}

	NextMarkTime = Level.TimeSeconds + 0.1f;

	TurboMarkPRI = class'TurboPlayerMarkReplicationInfo'.static.GetTurboMarkPRI(PlayerReplicationInfo);

	if (TurboMarkPRI != None)
	{
		TurboMarkPRI.MarkerColor = Color;
		TurboMarkPRI.MarkActor(TargetActor, DataClassOverride, DataOverride);
	}
}

function ServerMarkActor(vector Start, vector End, Actor TargetActor, class<TurboMarkerType> DataClassOverride, int DataOverride, TurboPlayerMarkReplicationInfo.EMarkColor Color)
{
	AttemptMarkActor(Start, End, TargetActor, DataClassOverride, DataOverride, Color);
}

function ClientCloseBuyMenu()
{
	local GUIController GUIController;
	local TurboGUIBuyMenu BuyMenu;

	if (Player == None || GUIController(Player.GUIController) == None)
	{
		return;
	}
	
	GUIController = GUIController(Player.GUIController);

	BuyMenu = TurboGUIBuyMenu(GUIController.FindMenuByClass(Class'TurboGUIBuyMenu'));
	
	if (BuyMenu != None)
	{
		BuyMenu.CloseSale(false);
	}
}

function ShowBuyMenu(string wlTag,float maxweight)
{
	StopForceFeedback();
	ClientOpenMenu(string(Class'TurboGUIBuyMenu'),,wlTag,string(maxweight));
}

function ServerSetWantsTraderPath(bool bNewWantsTraderPath)
{
	if (class'KFTurboGameType'.static.StaticIsHighDifficulty(Self))
	{
		return;
	}

	Super.ServerSetWantsTraderPath(bNewWantsTraderPath);
}

simulated function ClientReceiveLoginMenu(string MenuClass, bool bForce)
{
	if (MenuClass ~= "ServerPerks.SRInvasionLoginMenu" || MenuClass ~= "KFGui.KFInvasionLoginMenu")
	{
		MenuClass = string(class'KFTurbo.TurboInvasionLoginMenu');
	}

	Super.ClientReceiveLoginMenu(MenuClass, bForce);
}

simulated function ShowLoginMenu()
{
	if (Pawn != None && Pawn.Health > 0)
	{
		return;
	}

	if (PlayerReplicationInfo != None && PlayerReplicationInfo.bReadyToPlay)
	{
		return;
	}

	if (GameReplicationInfo != None)
	{
		ClientReplaceMenu(LobbyMenuClassString);
	}
}

function ServerInitializeSteamStatInt(byte Index, int Value)
{
	local ClientPerkRepLink CPRL;
	local SRCustomProgressInt Progress;
	local class<SRCustomProgressInt> ProgressClass;

	CPRL = GetClientPerkRepLink();

	if (!class'KFTurboGameType'.static.StaticAreStatsAndAchievementsEnabled(Self))
	{
		return;
	}

	if (CPRL == None)
	{
		return;
	}

	Value = Max(Value, 0);

	switch (Index)
	{
	case 0:
		ProgressClass = class'VP_DamageHealed';
		break;
	case 1:
		ProgressClass = class'VP_WeldingPoints';
		break;
	case 2:
		ProgressClass = class'VP_ShotgunDamage';
		break;
	case 3:
		ProgressClass = class'VP_HeadshotKills';
		break;
	case 4:
		ProgressClass = class'VP_StalkerKills';
		break;
	case 5:
		ProgressClass = class'VP_BullpupDamage';
		break;
	case 6:
		ProgressClass = class'VP_MeleeDamage';
		break;
	case 7:
		ProgressClass = class'VP_FlamethrowerDamage';
		break;
	case 21:
		ProgressClass = class'VP_ExplosiveDamage';
		break;
	default:
		return;
	}

	Progress = SRCustomProgressInt(CPRL.AddCustomValue(ProgressClass));

	if (Progress == None)
	{
		return;
	}

	if (Progress.CurrentValue < Value)
	{
		Progress.CurrentValue = Value;
		Progress.ValueUpdated();
	}
}

function AddPerkChangeLock(class<PerkLockTurboLocalMessage> Lock)
{
	local int Index;
	if (Lock == None)
	{
		return;
	}

	for (Index = PerkChangeLockList.Length - 1; Index >= 0; Index--)
	{
		if (Lock == PerkChangeLockList[Index])
		{
			return;
		}
	}

	PerkChangeLockList.Length = PerkChangeLockList.Length + 1;
	PerkChangeLockList[PerkChangeLockList.Length - 1] = Lock;
}

function RemovePerkChangeLock(class<PerkLockTurboLocalMessage> Lock)
{
	local int Index;
	if (Lock == None)
	{
		return;
	}

	for (Index = PerkChangeLockList.Length - 1; Index >= 0; Index--)
	{
		if (Lock == PerkChangeLockList[Index])
		{
			PerkChangeLockList.Remove(Index, 1);
			return;
		}
	}
}

function bool AttemptChangePerk(class<KFVeterancyTypes> VetSkill)
{
	local int Index;
	local class<TurboVeterancyTypes> TurboVeterancyClass;

	if (TurboPlayerReplicationInfo(PlayerReplicationInfo) == None || TurboPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill == VetSkill)
	{
		return true;
	}

	TurboVeterancyClass = class<TurboVeterancyTypes>(VetSkill);

	if (TurboVeterancyClass == None)
	{
		return false;
	}
	
	for (Index = 0; Index < PerkChangeLockList.Length; Index++)
	{
		if (!PerkChangeLockList[Index].static.CanSelectPerk(TurboVeterancyClass))
		{
			BroadcastLocalizedMessage(PerkChangeLockList[Index],, PlayerReplicationInfo,, TurboVeterancyClass);
			return false;
		}
	}

	return true;
}

function SelectVeterancy(class<KFVeterancyTypes> VetSkill, optional bool bForceChange)
{
	if (!AttemptChangePerk(VetSkill))
	{
		return;
	}

	Super.SelectVeterancy(VetSkill, bForceChange);
}

function KFClientSwitchToBestWeapon()
{
	SwitchToBestWeapon();
}

exec function SwitchToBestWeapon()
{
	local float Rating;

	if (Pawn == None || Pawn.Inventory == None)
	{
		return;
	}

    if (Pawn.PendingWeapon == None)
    {
	    Pawn.PendingWeapon = Pawn.Inventory.RecommendWeapon(Rating);

		if (Pawn.PendingWeapon == None || W_Frag_Weap(Pawn.PendingWeapon) != None)
		{
			Pawn.PendingWeapon = Weapon(Pawn.FindInventoryType(class'KFTurbo.W_Knife_Weap'));
		}

	    if (Pawn.PendingWeapon == Pawn.Weapon)
		{
		    Pawn.PendingWeapon = None;
		}

	    if (Pawn.PendingWeapon == None)
		{
    		return;
		}
    }

	StopFiring();

	if (Pawn.Weapon == None)
	{
		Pawn.ChangedWeapon();
	}
	else if (Pawn.Weapon != Pawn.PendingWeapon)
    {
		Pawn.Weapon.PutDown();
    }
}

simulated function AddExtraOptionConfig(TurboOptionObject Config)
{
	if (Config == None)
	{
		return;
	}

	ExternalOptionList[ExternalOptionList.Length] = Config;
}

simulated function bool HasExtraOptions()
{
	return ExternalOptionList.Length != 0;
}

simulated function GenerateExtraOptions(TurboTab_TurboSettings TurboSettings, int TabOrder)
{
	local int Index;
	for (Index = 0; Index < ExternalOptionList.Length; Index++)
	{
		ExternalOptionList[Index].GenerateOptions(TurboSettings, TabOrder + Index);
	}
}

exec function GetWeapon(class<Weapon> NewWeaponClass )
{
	if (WeaponRemappingSettings != None)
	{
		NewWeaponClass = WeaponRemappingSettings.static.GetRemappedWeapon(Self, NewWeaponClass);
	}
	
	Super.GetWeapon(NewWeaponClass);
}

final function bool HasPermissionForCommand(bool bIsAdminOnlyCommand)
{
	if (!bIsAdminOnlyCommand || !class'KFTurboMut'.default.bRequireAdminForDifficultyCommands)
	{
		return true;
	}

	return PlayerReplicationInfo != None && (Level.NetMode == NM_Standalone || PlayerReplicationInfo.bAdmin);
}

exec function ServerDebugSkipWave()
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SkipWave(Self);
	}
}

exec function ServerDebugRestartWave()
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.RestartWave(Self);
	}
}

exec function ServerDebugSetWave(int NewWaveNum)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetWave(Self, NewWaveNum);
	}
}

exec function ServerDebugPreventGameOver()
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.PreventGameOver(Self);
	}
}

exec function ServerDebugSpawnFriend()
{
	local TeamAI TeamAI;
	local TurboHumanBot Soldier;

	if (TurboCommandHandler == None || !TurboCommandHandler.CanExecuteCommand(self, true))
	{
		return;
	}

	foreach DynamicActors(class'TeamAI', TeamAI)
	{
		break;
	}


	Soldier = Spawn(class'TurboHumanBot');
	Soldier.PlayerReplicationInfo.Team.TeamIndex = PlayerReplicationInfo.Team.TeamIndex;
	Soldier.GiveWeapon("KFTurbo.W_Shotgun_Weap");
	TeamAI.AddSquadWithLeader(Soldier.Controller, None);
}

exec function AdminSetTraderTime(int Time)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetTraderTime(Self, Time);
	}
}

exec function AdminSetMaxPlayers(int PlayerCount)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetMaxPlayers(Self, PlayerCount);
	}
}

exec function AdminSetFakedPlayer(int FakedPlayerCount)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetFakedPlayer(Self, FakedPlayerCount);
	}
}

exec function AdminSetPlayerHealth(int PlayerHealthCount)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetPlayerHealth(Self, PlayerHealthCount);
	}
}

exec function AdminSetSpawnRate(float SpawnRateModifier)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetSpawnRate(Self, SpawnRateModifier);
	}
}

exec function AdminSetMaxMonsters(float MaxMonstersModifier)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetMaxMonsters(Self, MaxMonstersModifier);
	}
}

exec function AdminSetMonsterWanderEnabled(bool bEnabled)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetMonsterWanderEnabled(Self, bEnabled);
	}
}

exec function AdminSetZedTimeEnabled(bool bEnabled)
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.SetZedTimeEnabled(Self, bEnabled);
	}
}

exec function AdminShowSettings()
{
	if (TurboCommandHandler != None)
	{
		TurboCommandHandler.ShowSettings(Self);
	}
}

exec function FreeCamera(bool bFreeCamera) {}

exec simulated function EndTrader()
{
	if (Level.NetMode == NM_DedicatedServer)
	{
		return;
	}

	Vote(class'TurboGameVoteEndTrader'.static.GetVoteID());
}

exec function Vote(string VoteString)
{
	if (Role != ROLE_Authority)
	{
		return;
	}

	if (NextVoteTime > Level.TimeSeconds)
	{
		return;
	}

	NextVoteTime = Level.TimeSeconds + VoteCooldownTime;

	if (TurboGameReplicationInfo(Level.GRI).VoteInstance == None && NextStartVoteTime > Level.TimeSeconds)
	{
		return;
	}

	TurboGameReplicationInfo(Level.GRI).PlayerVote(TurboPlayerReplicationInfo(PlayerReplicationInfo), VoteString);
}

//Immediately creates a test vote. For testing purposes.
exec function VoteTest()
{
	local TurboGameReplicationInfo TurboGRI;

	if (Level.NetMode != NM_Standalone && (PlayerReplicationInfo == None || !PlayerReplicationInfo.bAdmin))
	{
		return;
	}

	if (Role != ROLE_Authority)
	{
		return;
	}

	TurboGRI = TurboGameReplicationInfo(Level.GRI);

	if (TurboGRI != None)
	{
		return;
	}

	TurboGRI.VoteInstance = Spawn(class'TurboGameVoteTest', Self);
	TurboGRI.VoteInstance.InitiateVote(TurboPlayerReplicationInfo(PlayerReplicationInfo));
	
	if (TurboGRI.VoteInstance != None && TurboGRI.VoteInstance.GetVoteState() < Expired)
	{
		TurboGRI.RegisterVoteInstance(TurboGRI.VoteInstance);
	}
}

simulated function ClientWeaponSpawned(class<Weapon> WeaponClass, Inventory Inv)
{
	local class<KFWeapon> KFWeaponClass;
	local class<KFWeaponAttachment> KFAttachmentClass;
	local bool bNeedsWeaponLoad, bNeedsAttachmentLoad;

	if (Level.NetMode == NM_DedicatedServer)
	{
		return;
	}

	KFWeaponClass = class<KFWeapon>(WeaponClass);

	if (KFWeaponClass == None)
	{
		return;
	}

	bNeedsWeaponLoad = KFWeaponClass.default.Mesh == None || (KFWeaponClass.default.MeshRef != "" && string(KFWeaponClass.default.Mesh) != KFWeaponClass.default.MeshRef);
	//Need to also check if skins didn't load or are different. Happens when variant weapons are loaded after non-variants are.
	bNeedsWeaponLoad = bNeedsWeaponLoad || KFWeaponClass.default.Skins.Length == 0 || KFWeaponClass.default.Skins[0] == None;
	bNeedsWeaponLoad = bNeedsWeaponLoad || (KFWeaponClass.default.SkinRefs.Length != 0 && KFWeaponClass.default.SkinRefs[0] != "" && string(KFWeaponClass.default.Skins[0]) != KFWeaponClass.default.SkinRefs[0]);

	if (bNeedsWeaponLoad)
	{
		KFWeaponClass.static.PreloadAssets(Inv);
	}

	KFAttachmentClass = class<KFWeaponAttachment>(KFWeaponClass.default.AttachmentClass);
	bNeedsAttachmentLoad = KFAttachmentClass != None && (KFAttachmentClass.default.Mesh == None || (KFAttachmentClass.default.MeshRef != "" && string(KFAttachmentClass.default.Mesh) != KFAttachmentClass.default.MeshRef));

	if (bNeedsAttachmentLoad)
	{
		if (Inv != None)
		{
			KFAttachmentClass.static.PreloadAssets(KFWeaponAttachment(Inv.ThirdPersonActor));    
		}
		else
		{
			KFAttachmentClass.static.PreloadAssets();
		}
	}

	PreloadCoreFireModeAssets(KFWeaponClass.default.FireModeClass[0]);
	PreloadCoreFireModeAssets(KFWeaponClass.default.FireModeClass[1]);
}

simulated function rotator RecoilHandler(rotator NewRotation, float DeltaTime)
{
	if (RecoilRotator.Pitch + RecoilRotator.Yaw + RecoilRotator.Roll <= 0)
	{
		return NewRotation;
	}

	NewRotation += (RecoilRotator / RecoilSpeed) * DeltaTime;

    if (Level.TimeSeconds - LastRecoilTime > RecoilSpeed)
    {
		RecoilRotator = rot(0,0,0);
    }

	return NewRotation;
}

function BecomeSpectator()
{
	local TurboGameReplicationInfo TGRI;

	if (PlayerReplicationInfo == None || PlayerReplicationInfo.bOnlySpectator)
	{
		Super.BecomeSpectator();
		return;
	}

	Super.BecomeSpectator();

	if (PlayerReplicationInfo.bOnlySpectator)
	{
        TGRI = TurboGameReplicationInfo(Level.GRI);
        if (TGRI != None && TGRI.VoteInstance != None && !TGRI.VoteInstance.CanSpectatorsVote())
        {
           TGRI.RevokePlayerVote(TurboPlayerReplicationInfo(PlayerReplicationInfo));
        }
	}
}

function ServerUse()
{
	Super.ServerUse();

	if (Role == ROLE_Authority && Pawn == None)
	{
		SpectateUseTarget();
	}
}

function SpectateUseTarget() {}

state Spectating
{
	function SpectateUseTarget()
	{
		local Vector XAxis, YAxis, ZAxis;
		local Actor HitActor;
		
		if (!(ViewTarget == None || ViewTarget == Self))
		{
			return;
		}

		if (Level.TimeSeconds < NextSpectateUseTargetTime)
		{
			return;
		}

		NextSpectateUseTargetTime = Level.TimeSeconds + SpectateUseTargetCooldown;

		GetAxes(Rotation, XAxis, YAxis, ZAxis);
		HitActor = Trace(YAxis, ZAxis, Location + (XAxis * 500.f), Location, true, vect(16, 16, 16));

		if (Pawn(HitActor) == None)
		{
			if (Pawn(HitActor.Base) != None)
			{
				HitActor = HitActor.Base;
			}
			else
			{
				return;
			}
		}

		SetViewTarget(HitActor);
		ClientSetViewTarget(HitActor);

		bBehindView = true;
    	ClientSetBehindView(bBehindView);
	}

	function BeginState()
	{
		Super.BeginState();
		
		if (Role == ROLE_Authority && SpectatorActorClass != None && SpectatorActor == None && !KFTurboGameType(Level.Game).bHasVisibleSpectatorMutator)
		{
			SpectatorActor = Spawn(SpectatorActorClass, PlayerReplicationInfo);
		}
	}

	function EndState()
	{
		Super.EndState();
		
		if (Role == ROLE_Authority && SpectatorActor != None)
		{
			SpectatorActor.Destroy();
		}
	}
}

simulated function SetPipebombUsesSpecialGroup(bool bNewPipebombUsesSpecialGroup)
{
	local W_Pipebomb_Weap Pipebomb;

	if (bNewPipebombUsesSpecialGroup == bPipebombUsesSpecialGroup)
	{
		return;
	}

	bPipebombUsesSpecialGroup = bNewPipebombUsesSpecialGroup;

	if (Role != ROLE_Authority)
	{
		ServerSetPipebombUsesSpecialGroup(bNewPipebombUsesSpecialGroup);
	}

	if (Pawn == None)
	{
		return;
	}

	Pipebomb = W_Pipebomb_Weap(Pawn.FindInventoryType(class'W_Pipebomb_Weap'));

	if (Pipebomb == None)
	{
		return;
	}

	Pipebomb.UpdateInventoryGroup(bPipebombUsesSpecialGroup);

	//Only auth should reshuffle.
	if (Role == ROLE_Authority)
	{
		Pawn.DeleteInventory(Pipebomb);
		Pawn.AddInventory(Pipebomb);
	}
}

function ServerSetPipebombUsesSpecialGroup(bool bNewPipebombUsesSpecialGroup)
{
	local W_Pipebomb_Weap Pipebomb;

	if (Role != ROLE_Authority || bNewPipebombUsesSpecialGroup == bPipebombUsesSpecialGroup)
	{
		return;
	}

	bPipebombUsesSpecialGroup = bNewPipebombUsesSpecialGroup;

	if (Pawn == None)
	{
		return;
	}

	Pipebomb = W_Pipebomb_Weap(Pawn.FindInventoryType(class'W_Pipebomb_Weap'));

	if (Pipebomb == None)
	{
		return;
	}

	Pipebomb.UpdateInventoryGroup(bPipebombUsesSpecialGroup);
	Pawn.DeleteInventory(Pipebomb);
	Pawn.AddInventory(Pipebomb);
}

function bool ShouldPipebombUseSpecialGroup()
{
	return bPipebombUsesSpecialGroup;
}

defaultproperties
{
	LobbyMenuClassString="KFTurbo.TurboLobbyMenu"
	PawnClass=Class'KFTurbo.TurboHumanPawn'
    PlayerReplicationInfoClass=Class'KFTurbo.TurboPlayerReplicationInfo'

    SpectatorActorClass=class'TurboSpectatorActorEye'

	WeaponRemappingSettings=class'WeaponRemappingSettingsImpl'

	bInLoginMenu=false
	bHasClosedLoginMenu=true //Starts as closed.
	LoginMenuTime=-1.f

	VoteCooldownTime=0.1f
	SpectateUseTargetCooldown=0.1f
}