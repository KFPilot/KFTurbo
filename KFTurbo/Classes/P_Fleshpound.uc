//Killing Floor Turbo P_Fleshpound
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Fleshpound extends MonsterFleshpound
    abstract;

var AI_Fleshpound ProAI;

simulated function PostNetBeginPlay()
{
	if (AvoidArea == None)
    {
        AvoidArea = Spawn(class'P_FleshPound_AvoidArea',self);
    }

	Super.PostNetBeginPlay();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	ProAI = AI_Fleshpound(Controller);
}

function ProcessMonsterDamageModifiers(out float Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, bool bIsHeadshot, optional int HitIndex)
{
	local class<CoreWeaponDamageType> WeaponDamageType;
	WeaponDamageType = class<CoreWeaponDamageType>(DamageType);

	if (WeaponDamageType != None)
	{
        if (WeaponDamageType.default.bIsExplosive)
        {
            ProcessMonsterExplosiveDamageModifiers(Damage, InstigatedBy, HitLocation, Momentum, WeaponDamageType, bIsHeadshot, HitIndex);
        }
		else
		{
            if (bIsHeadShot && class'V_Commando'.static.IsPerkDamageType(WeaponDamageType))
            {
                Damage *= 1.f; //Commando damage no longer receives penalty on headshot.
            }
            if (bIsHeadshot && (WeaponDamageType.default.HeadShotDamageMult >= 1.5 || (class<DamageTypeCrossbuzzsaw>(DamageType) != None)))
            {
                Damage *= 0.75f;
            }
            else if (class<DamageTypeM99SniperRifle>(DamageType) != None)
            {
                Damage *= 0.525;
            }
            else if (Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && class<DamageTypeCrossbow>(DamageType) != None)
            {
                Damage *= 0.35f;
            }
            else if (class<DamageTypeCrossbuzzsaw>(DamageType) != None)
            {
                Damage *= 0.62f;
            }
            else if (bIsHeadshot && class<DamageTypeDBShotgun>(DamageType) != None && InstigatedBy != None && IsInHuntingShotgunDamageBoostRadius(InstigatedBy))
            {
                Damage *= 0.6125f; //22% damage increase at point blank due to some odd reduction being applied.
            }
            else if (bIsHeadshot && class<DamageTypeNailGun>(DamageType) != None)
            {
                Damage *= 0.54f; //8% damage increase to help nailgun be competitive with hunting shotgun.
            }
            else
            {
                Damage *= 0.5f;
            }
		}
	}
	else if (ClassIsChildOf(WeaponDamageType, class'DamTypeVomit'))
	{
		if (ClassIsChildOf(WeaponDamageType, class'DamTypeBlowerThrower'))
		{
       		Damage *= 0.25f;
		}
		else
		{
			Damage = 0.f;
		}
	}
    else
    {
        Damage *= 0.5f;
    }
}

function ProcessMonsterExplosiveDamageModifiers(out float Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<CoreWeaponDamageType> DamageType, bool bIsHeadshot, optional int HitIndex)
{
    if (ClassIsChildOf(DamageType, class'DamageTypeLAW'))
    {
        Damage *= 1.25f; //Yes TWI code does not have a modifier for the LAW...
    }
    else if (ClassIsChildOf(DamageType, class'DamageTypeSeekerSixRocket'))
    {
        Damage *= 1.65f;
    }
    else if (ClassIsChildOf(DamageType, class'DamageTypeFrag') || ClassIsChildOf(DamageType, class'DamageTypePipeBomb') || ClassIsChildOf(DamageType, class'DamageTypeMedicNade'))
    {
        Damage *= 2.f;
    }
    //This is to help handle a more "general" case for explosive damage types. The above captures all explosive damage with specific multipliers.
    //The below modifier has been changed to a "catch all" for explosive damage types.
    else /*if (ClassIsChildOf(WeaponDamageType, class'DamageTypeM79Grenade') || ClassIsChildOf(WeaponDamageType, class'DamageTypeM203Grenade') 
        || ClassIsChildOf(WeaponDamageType, class'DamageTypeSealSquealExplosion') || ClassIsChildOf(WeaponDamageType, class'DamageTypeSeekerSixRocket'))*/
    {
        Damage *= 1.25f;
    }
}

function bool IsInHuntingShotgunDamageBoostRadius(Actor Other)
{
    local float Distance;
    Distance = VSize(Location - Other.Location);
    Distance -= (CollisionRadius + Other.CollisionRadius);
    return Distance < 8.f;
}

simulated function float GetOriginalGroundSpeed()
{
    if (bFrustrated || bChargingPlayer)
    {
        return Super.GetOriginalGroundSpeed() * 2.3f;
    }

    return Super.GetOriginalGroundSpeed();
}

simulated function SetBurningBehavior()
{
    if (bFrustrated || bChargingPlayer)
    {
        return;
    }

    if (ProAI != None && ProAI.bForcedRage)
    {
        return;
    }

    Super.SetBurningBehavior();
}

function StartCharging()
{
    if (AnimAction == 'KnockDown')
    {
        return;
    }

    Super.StartCharging();
}

state RageCharging
{
Ignores StartCharging;

	function BeginState()
	{
        local float DifficultyModifier;

		if(bZapped && (ProAI == None || !ProAI.bForcedRage))
        {
            GoToState('');
        }
        else
        {
            bChargingPlayer = true;

    		if( Level.NetMode!=NM_DedicatedServer )
    			ClientChargingAnims();

            if(Level.Game.GameDifficulty < 2.0)
                DifficultyModifier = 0.85;
            else if(Level.Game.GameDifficulty < 4.0)
                DifficultyModifier = 1.0;
            else if(Level.Game.GameDifficulty < 5.0)
                DifficultyModifier = 1.25;
            else
                DifficultyModifier = 3.0;

        	if(ProAI != None && ProAI.bForcedRage)
        		DifficultyModifier *= 1000.f;

    		RageEndTime = (Level.TimeSeconds + 5 * DifficultyModifier) + (FRand() * 6 * DifficultyModifier);
    		NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

    function PlayDirectionalHit(Vector HitLoc)
    {
        if( !bShotAnim )
        {
            Global.PlayDirectionalHit(HitLoc);
        }
    }

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal,bWasEnemy;

		bWasEnemy = (Controller.Target==Controller.Enemy);
		RetVal = Super(MonsterFleshpoundBase).MeleeDamageTarget(hitdamage*1.75, pushdir*3);

		if(RetVal && bWasEnemy && ProAI != None && !ProAI.bForcedRage)
        {
			GoToState('');
        }
            
		return RetVal;
	}
}

defaultproperties
{
    Begin Object Class=AfflictionBurnFleshpound Name=BurnAffliction
        BurnDurationModifier=1.f
        BurnSkinIndexList=(0)
    End Object
    MonsterBurnAffliction=AfflictionBurn'BurnAffliction'

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object
    MonsterZapAffliction=CoreMonsterAffliction'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonStunnedSpeedModifier=0.25f
    End Object
    MonsterHarpoonAffliction=CoreMonsterAffliction'HarpoonAffliction'

    EventClasses(0)="P_Fleshpound_DEF"
    ControllerClass=Class'KFTurbo.AI_Fleshpound'
}