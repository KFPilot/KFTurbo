//Killing Floor Turbo P_Gorefast_Classy
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Gorefast_Classy extends P_Gorefast;

#exec OBJ LOAD FILE=KF_BaseGorefast_xmas.uax
#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax

function PlayDyingSound()
{
	if(Level.NetMode != NM_Client && !bGibbed && !bDecapitated)
	{
		PlaySound(DeathSound[Rand(3)], SLOT_Pain,1.30,true,525);
	}

	Super.PlayDyingSound();
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{
	myLevel.AddPrecacheMaterial(Combiner'KFTurbo.ClassyFast.gorefastHat_cmb');
}

defaultproperties
{
     MoanVoice=Sound'KF_BaseGorefast_xmas.Speech.Gorefast_Talk16'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_HitPlayer'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Jump'
     DetachedArmClass=Class'KFChar.SeveredArmGorefast'
     DetachedLegClass=Class'KFChar.SeveredLegGorefast'
     DetachedHeadClass=Class'KFChar.SeveredHeadGorefast'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Pain'
     DeathSound(0)=Sound'KF_BaseGorefast_xmas.Death.Gorefast_Death1'
     DeathSound(1)=Sound'KF_BaseGorefast_xmas.Death.Gorefast_Death2'
     DeathSound(2)=Sound'KF_BaseGorefast_xmas.Death.Gorefast_Death3'
     ChallengeSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(1)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(2)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     ChallengeSound(3)=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Challenge'
     MenuName="Classy Gorefast"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.GoreFast.Gorefast_Idle'
     Mesh=SkeletalMesh'KFTurbo.classyfast_mesh'
     Skins(0)=Combiner'KFTurbo.ClassyFast.gorefastHat_cmb'
}
