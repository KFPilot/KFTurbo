class KFTTSteamStatsAndAchievements extends ROEngine.KFSteamStatsAndAchievements;

event Timer();
event OnPerkAvailable();
function FlushStatsToClient();
function SetSteamAchievementCompleted(int index);
simulated event PostNetReceive();
simulated event OnStatsAndAchievementsReady();
function ServerSteamStatsAndAchievementsInitialized();
simulated function UpdateAchievementProgress();

simulated event PostNetBeginPlay() {
	local int i;
	
	for (i = 0; i < Achievements.length; i++)
		Achievements[i].bCompleted = 1;
	
	if (Level.NetMode == NM_Client)
		PCOwner = Level.GetLocalPlayerController();
}

simulated function bool PlayerOwnsWeaponDLC(int AppID) {
	return true;
}

defaultproperties
{
     bUsedCheats=True
     RemoteRole=ROLE_DumbProxy
     bNetNotify=False
}
