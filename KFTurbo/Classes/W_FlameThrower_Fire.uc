//Killing Floor Turbo W_FlameThrower_Fire
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_Flamethrower_Fire extends WeaponFlamethrowerBurstFire;

var int FireEffectCount;
var int ProjectileCounter;
var class<Projectile> LowProjectileClass;
var class<Projectile> MinProjectileClass;

function DoFireEffect()
{
     if (++FireEffectCount >= 10) { class'WeaponHelper'.static.OnWeaponFire(self); FireEffectCount = 0; }
     Super.DoFireEffect();
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
     ProjectileCounter++;
     return class'WeaponHelper'.static.SpawnProjectile(Self, Start, Dir);
}

function Projectile ForceSpawnProjectile(Vector Start, Rotator Dir)
{
     return class'WeaponHelper'.static.ForceSpawnProjectile(Self, Start, Dir);
}

function class<Projectile> GetDesiredProjectileClass()
{
     if (ProjectileCounter % 5 == 4)
     {
          return ProjectileClass;
     }

     if (ProjectileCounter % 2 == 1)
     {
          return LowProjectileClass;
     }

     return MinProjectileClass;
}

defaultproperties
{
     ProjectileClass=class'KFTurbo.W_FlameThrower_Proj'
     LowProjectileClass=class'KFTurbo.W_FlameThrower_Proj_Low'
     MinProjectileClass=class'KFTurbo.W_FlameThrower_Proj_Min'
     Spread=0.002200
     AmmoClass=class'W_Flamethrower_Ammo'
}
