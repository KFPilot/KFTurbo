//Killing Floor Turbo W_HuskGun_Proj_Strong
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_HuskGun_Proj_Strong extends W_HuskGun_Proj_Medium;

function TakeDamage(int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
     class'WeaponHelper'.static.HuskGunProjTakeDamage(self, Damage, InstigatedBy, Hitlocation, Momentum, DamageType, HitIndex);
}

defaultproperties
{
     ExplosionEmitter=Class'KFMod.FlameImpact_Strong'
     FlameTrailEmitterClass=Class'KFMod.FlameThrowerHusk_Strong'
     ExplosionSoundVolume=2.000000
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Large'
}
