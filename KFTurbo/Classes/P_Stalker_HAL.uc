//Killing Floor Turbo P_Stalker_HAL
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Stalker_HAL extends P_Stalker;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_HALLOWEEN_T.utx

defaultproperties
{
	DefaultSkin(0)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';
	DefaultSkin(1)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB';

	CloakedSkin(0)=Shader'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_Redneck_Invisible';
	CloakedSkin(1)=Shader'KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_Redneck_Invisible';

	MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Talk'
	MoanVolume=1.000000
	MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_HitPlayer'
	JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Jump'
	DetachedArmClass=Class'KFChar.SeveredArmStalker_HALLOWEEN'
	DetachedLegClass=Class'KFChar.SeveredLegStalker_HALLOWEEN'
	DetachedHeadClass=Class'KFChar.SeveredHeadStalker_HALLOWEEN'
	HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Pain'
	DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Death'
	ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
	ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
	ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
	ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Stalker.Stalker_Challenge'
	GruntVolume=0.250000
	MenuName="HALLOWEEN Stalker"
	AmbientSound=Sound'KF_BaseStalker.Stalker_IdleLoop'
	Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.Stalker_Halloween'
	Skins(0)=Shader'KF_Specimens_Trip_HALLOWEEN_T.Stalker.stalker_Redneck_invisible'
	Skins(1)=Shader'KF_Specimens_Trip_HALLOWEEN_T.Stalker.stalker_Redneck_invisible'
	TransientSoundVolume=0.600000
}
