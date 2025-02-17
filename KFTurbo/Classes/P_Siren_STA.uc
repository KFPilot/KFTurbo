//Killing Floor Turbo P_Siren_STA
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Siren_STA extends P_Siren;

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Talk'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Jump'
     DetachedLegClass=Class'KFChar.SeveredLegSiren'
     DetachedHeadClass=Class'KFChar.SeveredHeadSiren'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd.siren.Siren_Death'
     AmbientSound=Sound'KF_BaseSiren.Siren_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip.Siren_Freak'
     Skins(0)=FinalBlend'KF_Specimens_Trip_T.siren_hair_fb'
     Skins(1)=Combiner'KF_Specimens_Trip_T.siren_cmb'
}
