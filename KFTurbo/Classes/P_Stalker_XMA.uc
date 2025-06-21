//Killing Floor Turbo P_Stalker_XMA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Stalker_XMA extends P_Stalker;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_XMAS_T.utx

static simulated function PreCacheMaterials(LevelInfo myLevel)
{
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.stalkerclause_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.stalker_claus');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.stalkcerclause_ref_cmb');

	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_XMAS_T.stalker_invisible');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.StalkerCloakOpacity_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause_cloakrefract_cmb');
	myLevel.AddPrecacheMaterial(Material'KFCharacters.StalkerSkin');
}

defaultproperties
{
    DefaultSkin(0)=Combiner'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb'
	DefaultSkin(1)=FinalBlend'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_fb'

	CloakedSkin(0)=Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible'
	CloakedSkin(1)=Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible'

	MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Talk'
	MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_HitPlayer'
	JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Jump'
	DetachedArmClass=Class'KFChar.SeveredArmStalker_XMas'
	DetachedLegClass=Class'KFChar.SeveredLegStalker_XMas'
	DetachedHeadClass=Class'KFChar.SeveredHeadStalker_XMas'
	HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Pain'
	DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Death'
	ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
	ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
	ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
	ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Stalker.Stalker_Challenge'
	MenuName="Christmas Stalker"
	AmbientSound=Sound'KF_BaseStalker.Stalker_IdleLoop'
	Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.StalkerClause'
	Skins(0)=Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible'
	Skins(1)=Shader'KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_invisible'
}
