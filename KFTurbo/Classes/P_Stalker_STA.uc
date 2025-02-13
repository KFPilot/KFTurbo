//Killing Floor Turbo P_Stalker_STA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Stalker_STA extends P_Stalker;

defaultproperties
{
     DefaultSkin(0)=Combiner'KF_Specimens_Trip_T.stalker_cmb'
     DefaultSkin(1)=FinalBlend'KF_Specimens_Trip_T.stalker_fb'

     CloakedSkin(0)=Shader'KF_Specimens_Trip_T.stalker_invisible'
     CloakedSkin(1)=Shader'KF_Specimens_Trip_T.stalker_invisible'

     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmStalker'
     DetachedLegClass=Class'KFChar.SeveredLegStalker'
     DetachedHeadClass=Class'KFChar.SeveredHeadStalker'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Stalker.Stalker_Challenge'
     AmbientSound=Sound'KF_BaseStalker.Stalker_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip.Stalker_Freak'
     Skins(0)=Shader'KF_Specimens_Trip_T.stalker_invisible'
     Skins(1)=Shader'KF_Specimens_Trip_T.stalker_invisible'
}
