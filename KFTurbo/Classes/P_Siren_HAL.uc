//Killing Floor Turbo P_Siren_HAL
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Siren_HAL extends P_Siren;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax

defaultproperties
{
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.siren.Siren_Talk'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.siren.Siren_Jump'
     DetachedLegClass=Class'KFChar.SeveredLegSiren_HALLOWEEN'
     DetachedHeadClass=Class'KFChar.SeveredHeadSiren_HALLOWEEN'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.siren.Siren_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.siren.Siren_Death'
     MenuName="HALLOWEEN Siren"
     AmbientSound=Sound'KF_BaseSiren_HALLOWEEN.Siren_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.Siren_Halloween'
     Skins(0)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.siren.Siren_RedneckZombie_CMB'
     Skins(1)=FinalBlend'KF_Specimens_Trip_HALLOWEEN_T.siren.Siren_RedneckZombie_Hair_FB'
     
     Begin Object Class=AfflictionBurn Name=BurnAffliction
          BurnDurationModifier=1.f
          BurnSkinIndexList=(0)
     End Object
     MonsterBurnAffliction=CoreMonsterAffliction'BurnAffliction'
}
