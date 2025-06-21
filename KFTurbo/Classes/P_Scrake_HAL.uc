//Killing Floor Turbo P_Scrake_HAL
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Scrake_HAL extends P_Scrake;


#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax
#exec OBJ LOAD FILE=KF_BaseScrake_HALLOWEEN.uax

defaultproperties
{
     SawAttackLoopSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Impale'
     ChainSawOffSound=SoundGroup'KF_ChainsawSnd.Chainsaw_Deselect'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Chainsaw_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmScrake_HALLOWEEN'
     DetachedLegClass=Class'KFChar.SeveredLegScrake_HALLOWEEN'
     DetachedHeadClass=Class'KFChar.SeveredHeadScrake_HALLOWEEN'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmScrakeSaw_HALLOWEEN'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Scrake.Scrake_Challenge'
     MenuName="HALLOWEEN Scrake"
     AmbientSound=Sound'KF_BaseScrake.Chainsaw.Scrake_Chainsaw_Idle'
     Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.Scrake_Halloween'
     Skins(0)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.Scrake.Scrake_RedneckZombie_CMB'
     Skins(1)=Combiner'KF_Specimens_Trip_T.scrake_cmb'
     Skins(2)=TexPanner'KF_Specimens_Trip_T.scrake_saw_panner'
}
