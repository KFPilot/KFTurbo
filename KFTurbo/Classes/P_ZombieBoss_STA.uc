//Killing Floor Turbo P_ZombieBoss_STA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_ZombieBoss_STA extends P_ZombieBoss;

defaultproperties
{
	CloakedSkinList(0)=Shader'KF_Specimens_Trip_T.patriarch_invisible_gun'
	CloakedSkinList(1)=Shader'KF_Specimens_Trip_T.patriarch_invisible'
    HelpMeSound=Sound'KF_EnemiesFinalSnd.Patriarch.Kev_SaveMe'

    RocketFireSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_FireRocket'
    MiniGunFireSound=Sound'KF_BasePatriarch.Attack.Kev_MG_GunfireLoop'
    MiniGunSpinSound=Sound'KF_BasePatriarch.Attack.Kev_MG_TurbineFireLoop'
    MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_HitPlayer_Impale'
    MoanVoice=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Talk'
    MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_HitPlayer_Fist'
    JumpSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Jump'
    DetachedArmClass=Class'KFChar.SeveredArmPatriarch'
    DetachedLegClass=Class'KFChar.SeveredLegPatriarch'
    DetachedHeadClass=Class'KFChar.SeveredHeadPatriarch'
    DetachedSpecialArmClass=Class'KFChar.SeveredRocketArmPatriarch'
    HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Pain'
    DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Death'
    AmbientSound=Sound'KF_BasePatriarch.Idle.Kev_IdleLoop'
    Mesh=SkeletalMesh'KF_Freaks_Trip.Patriarch_Freak'
    Skins(0)=Combiner'KF_Specimens_Trip_T.gatling_cmb'
    Skins(1)=Combiner'KF_Specimens_Trip_T.patriarch_cmb'
}
