//Killing Floor Turbo W_PipeBomb_Projectile
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_PipeBomb_Projectile extends PipeBombProjectile;

var Sound DeflectSound;
var string DeflectSoundRef;

static function PreloadAssets()
{
    Super.PreloadAssets();

    default.DeflectSound = Sound(DynamicLoadObject(default.DeflectSoundRef, class'Sound', true));
}

static function bool UnloadAssets()
{
    Super.UnloadAssets();

    default.DeflectSound = None;

	return true;
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode == NM_DedicatedServer)
    {
        ExplodeSounds[0] = None;
    }
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
    if (bDisintegrated || ClassIsChildOf(DamageType, class'DamTypePipeBomb') || ClassIsChildOf(DamageType, class'DamTypeMelee'))
    {
        return;
    }
	
    if (InstigatedBy == none || InstigatedBy != none && InstigatedBy.PlayerReplicationInfo != none &&
		InstigatedBy.PlayerReplicationInfo.Team != none && InstigatedBy.PlayerReplicationInfo.Team.TeamIndex == PlacedTeam &&
		Class<KFWeaponDamageType>(DamageType) != none && (Class<KFWeaponDamageType>(DamageType).default.bIsExplosive || InstigatedBy != Instigator))
    {
        return;
    }

    if (bHasExploded && class<KFWeaponDamageType>(DamageType) != None && !class<KFWeaponDamageType>(DamageType).default.bIsExplosive)
    {
        PlaySound(DeflectSound, ESoundSlot.SLOT_None, 150,, 500.f);
    }

    if (class<SirenScreamDamage>(DamageType) != None)
    {
        if (Damage >= 25)
        {
            Disintegrate(HitLocation, vect(0,0,1));
        }
        
        return;
    }
    
    Explode(HitLocation, vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (bHasExploded)
	{
		return;
	}

	Super.Explode(HitLocation, HitNormal);
}

defaultproperties
{
    ShrapnelClass=Class'KFTurbo.W_PipeBomb_Shrapnel'
    DeflectSoundRef="ProjectileSounds.cannon_rounds.AP_deflect"
    bGameRelevant=false
}