//Killing Floor Turbo P_Fleshpound_XMA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Fleshpound_XMA extends P_Fleshpound;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax

simulated function DeviceGoRed()
{
	Skins[2]=Shader'KFCharacters.FPRedBloomShader';
}

simulated function DeviceGoNormal()
{
	Skins[2] = Shader'KFCharacters.FPAmberBloomShader';
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.NutPound.NutPound_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.NutPound_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.NutPounder_T');
}

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmPound_XMas'
     DetachedLegClass=Class'KFChar.SeveredLegPound_XMas'
     DetachedHeadClass=Class'KFChar.SeveredHeadPound_XMas'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Fleshpound.FP_Challenge'
     MenuName="Christmas Flesh Pound"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Fleshpound.FP_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.NutPound'
     Skins(0)=Combiner'KF_Specimens_Trip_XMAS_T.NutPound.NutPound_cmb'
     Skins(1)=FinalBlend'KF_Specimens_Trip_XMAS_T.NutPound.nutpound_hair_fb'
     Skins(2)=Shader'KFCharacters.FPAmberBloomShader'
}
