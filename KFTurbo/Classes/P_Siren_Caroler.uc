//Killing Floor Turbo P_Siren_Caroler
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Siren_Caroler extends P_Siren_XMA;

var float ExtraEffectCooldownTime;
var float NextExtraEffectSpawnTime;

simulated function SpawnTwoShots()
{
    if( bDecapitated || bZapped || bHarpoonStunned )
    {
        return;
    }

    SpawnExtraSirenScreamEffect();

    Super.SpawnTwoShots();
}

simulated function SpawnExtraSirenScreamEffect()
{
     local Emitter ExtraEffect;

     if (Level.NetMode == NM_DedicatedServer)
     {
          return;
     }

     if (Level.TimeSeconds < NextExtraEffectSpawnTime)
     {
          return;
     }

     NextExtraEffectSpawnTime = Level.TimeSeconds + ExtraEffectCooldownTime;
     ExtraEffect = Spawn(class'P_Siren_Caroler_Scream', self);
     ExtraEffect.AttachToBone(self, 'Collision_Attach');
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local KFHumanPawn HumanPawn;
	local Vector PullDirection;
	local float Distance;
     local Vector MomentumVector;
     local float MomentumScale;

	if( bHurtEntry )
     {
		return;
     }

     Super.HurtRadius(DamageAmount, DamageRadius, DamageType, Momentum, HitLocation);

     bHurtEntry = true;

	foreach VisibleCollidingActors( class'KFHumanPawn', HumanPawn, DamageRadius, HitLocation )
	{
          PullDirection = HitLocation - HumanPawn.Location;
          Distance = FMax(1.f, VSize(PullDirection));
          PullDirection = PullDirection / Distance;

          MomentumScale = 300000.f;
          MomentumScale = MomentumScale / HumanPawn.Mass;
          MomentumVector = PullDirection * (Distance / DamageRadius) * MomentumScale;

          if (HumanPawn.Physics == PHYS_Walking)
          {
               MomentumVector.Z = FMax(MomentumVector.Z, 4.f);
          }
          
          HumanPawn.AddVelocity( MomentumVector );
     }

     bHurtEntry = false;
}

defaultproperties
{
     MenuName="Caroler"
     
     ScreamDamage=4

     ExtraEffectCooldownTime=4.5f
     NextExtraEffectSpawnTime=0.f
}
