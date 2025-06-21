//Killing Floor Turbo P_Husk_STA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Husk_STA extends P_Husk;

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Bloat.Bloat_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmHusk'
     DetachedLegClass=Class'KFChar.SeveredLegHusk'
     DetachedHeadClass=Class'KFChar.SeveredHeadHusk'
     DetachedSpecialArmClass=Class'KFChar.SeveredArmHuskGun'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Death'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd.Husk.Husk_Challenge'
     AmbientSound=Sound'KF_BaseHusk.Husk_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks2_Trip.Burns_Freak'
     Skins(0)=Texture'KF_Specimens_Trip_T_Two.burns.burns_tatters'
}
