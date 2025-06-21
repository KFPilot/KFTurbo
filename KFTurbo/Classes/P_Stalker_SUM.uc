//Killing Floor Turbo P_Stalker_SUM
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Stalker_SUM extends P_Stalker;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_CIRCUS.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_CIRCUS_T.utx

static simulated function PreCacheMaterials(LevelInfo myLevel)
{
	myLevel.AddPrecacheMaterial(Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB');
	myLevel.AddPrecacheMaterial(FinalBlend'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_fb');
	myLevel.AddPrecacheMaterial(Material'KFX.FBDecloakShader');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.StalkerCloakOpacity_cmb');
	myLevel.AddPrecacheMaterial(Material'KFCharacters.StalkerSkin');
}

defaultproperties
{
    DefaultSkin(0)=Combiner'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB'
	DefaultSkin(1)=FinalBlend'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_fb'

	CloakedSkin(0)=Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr'
	CloakedSkin(1)=Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr'

	MoanVoice=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Talk'
	MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_HitPlayer'
	JumpSound=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Jump'
	DetachedArmClass=Class'KFChar.SeveredArmStalker_CIRCUS'
	DetachedLegClass=Class'KFChar.SeveredLegStalker_CIRCUS'
	DetachedHeadClass=Class'KFChar.SeveredHeadStalker_CIRCUS'
	HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Pain'
	DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Death'
	ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
	ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
	ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
	ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_CIRCUS.Stalker.Stalker_Challenge'
	MenuName="Circus Stalker"
	AmbientSound=Sound'KF_BaseStalker.Stalker_IdleLoop'
	Mesh=SkeletalMesh'KF_Freaks_Trip_CIRCUS.stalker_CIRCUS'
	Skins(0)=Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr'
	Skins(1)=Shader'KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_Invisible_CIRCUS_shdr'
}
