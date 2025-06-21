//Killing Floor Turbo P_Scrake_STA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Scrake_STA extends P_Scrake;

defaultproperties
{
     SawAttackLoopSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Impale'
     ChainSawOffSound=SoundGroup'KF_ChainsawSnd.Chainsaw_Deselect'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Chainsaw_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmScrake'
     DetachedLegClass=Class'KFChar.SeveredLegScrake'
     DetachedHeadClass=Class'KFChar.SeveredHeadScrake'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmScrakeSaw'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Scrake.Scrake_Challenge'
     AmbientSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip.Scrake_Freak'
     Skins(0)=Shader'KF_Specimens_Trip_T.scrake_FB'
     Skins(1)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
}
