class KFTTGameType extends KFTurboGameType;

function DramaticEvent(float BaseZedTimePossibility, optional float DesiredZedTimeDuration);
function DoBossDeath();
function AddBossBuddySquad();

function bool CheckMaxLives(PlayerReplicationInfo Scorer) {
	return false;
}

function RestartPlayer(Controller C) {
	if (C.Pawn != None)
		return;

	C.PlayerReplicationInfo.bOutOfLives = false;
	Super(Invasion).RestartPlayer(C);
	
	if (KFHumanPawn(C.Pawn) != None)
		KFHumanPawn(C.Pawn).VeterancyChanged();
	
	if (C.bIsPlayer)
		C.Pawn.bBlockActors = true;
}

function bool AllowBecomeActivePlayer(PlayerController PC) {
	if (numPlayers >= maxPlayers) {
		PC.ReceiveLocalizedMessage(GameMessageClass, 13);
		return false;
	}
	
	if (PC.PlayerReplicationInfo == None || !PC.PlayerReplicationInfo.bOnlySpectator)
		return false;

	if (Level.NetMode == NM_Standalone && numBots > initialBots) {
		remainingBots--;
		bPlayerBecameActive = true;
	}
	
	return true;
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType) {
	if (MonsterController(Killed) != None || Monster(KilledPawn) != None) {
		zombiesKilled++;
		KFGameReplicationInfo(Level.Game.GameReplicationInfo).maxMonsters = Max(totalMaxMonsters + numMonsters - 1, 0);
	}

	Super(Invasion).Killed(Killer, Killed, KilledPawn, DamageType);
}

State MatchInProgress {
	function bool BootShopPlayers() {
		return false;
	}

	function SelectShop();
	function CloseShops();
	function SetupPickups();

	function OpenShops() {
		local int i;

		bTradingDoorsOpen = true;

		for(i = 0; i < ShopList.length; i++)
			ShopList[i].OpenShop();
	}

	function Timer() {
		Global.Timer();

		if (NeedPlayers() && AddBot() && remainingBots > 0)
			remainingBots--;
		
		elapsedTime++;
		GameReplicationInfo.elapsedTime = elapsedTime;
		
		if (bUpdateViewTargs)
			UpdateViews();

		if (!bNoBots && !bBotsAdded) {
			if (KFGameReplicationInfo(GameReplicationInfo) != None)

			if (numPlayers + numBots < maxPlayers && KFGameReplicationInfo(GameReplicationInfo).pendingBots > 0) {
				AddBots(1);
				KFGameReplicationInfo(GameReplicationInfo).pendingBots--;
			}

			if (KFGameReplicationInfo(GameReplicationInfo).pendingBots == 0) {
				bBotsAdded = true;
				return;
			}
		}
	}

	function BeginState() {
		Super(Invasion).BeginState();

		waveNum = initialWave;
		InvasionGameReplicationInfo(GameReplicationInfo).waveNumber = waveNum;
		waveCountDown = 0;

		OpenShops();
	}
}

function DistributeCash(TurboPlayerController ExitingPlayer) {}

defaultproperties
{
	bIsTestGameType=true
	bIsHighDifficulty=false
    bStatsAndAchievementsEnabled=false

	GameName="Killing Floor Turbo Test Mode"
	Description="Test mode of the Killing Floor Turbo mod."
	LoginMenuClass="KFTurboTestMut.KFTTLoginMenu"
	MapPrefix="KFT"
	BeaconName="KFT"
	Acronym="KFT"
}