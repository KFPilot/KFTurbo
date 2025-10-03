//Killing Floor Turbo P_Fleshpound
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Fleshpound extends MonsterFleshpound
    abstract
    DependsOn(PawnHelper);

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

//TODO: PROPERLY USE COREMONSTER'S FUNCTIONING OUT OF THESE MODIFICATIONS.
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	local int OldHealth;
	local Vector X,Y,Z;
	local bool bIsHeadShot;
	local float HeadShotCheckScale;
    local class<KFWeaponDamageType> WeaponDamageType;

    if (DamageType == class 'DamTypeVomit')
	{
		Damage = 0;
        Super(CoreMonster).TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitIndex);
        return;
	}

    WeaponDamageType = class<KFWeaponDamageType>(DamageType);

	GetAxes(Rotation, X,Y,Z);

	if( LastDamagedTime<Level.TimeSeconds )
    {
		TwoSecondDamageTotal = 0;
    }
	
    LastDamagedTime = Level.TimeSeconds + 2.f;
	OldHealth = Health;

    if (WeaponDamageType == None || !WeaponDamageType.default.bIsExplosive)
    {
        HeadShotCheckScale = 1.0;
        if( class<DamTypeMelee>(damageType) != none )
        {
            HeadShotCheckScale *= 1.25;
        }

        bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), HeadShotCheckScale);
        // Commando weapons don't get the damage reduction
		if (bIsHeadShot && class'V_Commando'.static.IsPerkDamageType(WeaponDamageType))
        {
            // Do nothing
        }
		// Don't reduce the damage so much if its a high headshot damage weapon
        else if( (bIsHeadShot && WeaponDamageType.default.HeadShotDamageMult >= 1.5) || (class<DamTypeCrossbuzzsaw>(DamageType) != None))
		{
			Damage *= 0.75;
		}
		else if (class<DamTypeM99SniperRifle>(DamageType) != None)
		{
			Damage *= 0.525;
		}
		else if (Level.Game.GameDifficulty >= 5.0 && bIsHeadshot && class<DamTypeCrossbow>(DamageType) != None)
		{
			Damage *= 0.35; // was 0.3 in Balance Round 1, then 0.4 in Round 2, then 0.3 in Round 3/4, and 0.35 in Round 5
		}
        else if (class<DamTypeCrossbuzzsaw>(DamageType) != None)
        {
            Damage *= 0.62f;
        }
		else if (bIsHeadshot && class<DamTypeDBShotgun>(DamageType) != None && IsInDamageBoostRadius(InstigatedBy))
		{
			Damage *= 0.6125f; //22% damage increase at point blank due to some odd reduction being applied.
		}
		else if (bIsHeadshot && class<DamTypeNailGun>(DamageType) != None)
		{
			Damage *= 0.54f; //8% damage increase to help nailgun be competitive with hunting shotgun.
		}
		else
		{
			Damage *= 0.5f;
		}
    }
    else if (WeaponDamageType != None && WeaponDamageType.default.bIsExplosive)
    {
        switch(DamageType)
        {
            case class'DamTypeFrag':
            case class'DamTypePipeBomb':
            case class'DamTypeMedicNade':
                Damage *= 2.0f;
                break;
            case class'DamTypeSeekerSixRocket':
                Damage *= 1.65f;
                break;
            default:
                Damage *= 1.25f;
                break;
        }
    }

	// Shut off his "Device" when dead
	if (Damage >= Health)
    {
		PostNetReceive();
    }

	Super(KFMonster).TakeDamage(Damage, instigatedBy, hitLocation, momentum, damageType,HitIndex) ;

	TwoSecondDamageTotal += OldHealth - Health; // Corrected issue where only the Base Health is counted toward the FP's Rage in Balance Round 6(second attempt)

	if (!bDecapitated && TwoSecondDamageTotal > RageDamageThreshold && !bChargingPlayer && !bZapped
        && (!(bCrispified && bBurnified) || bFrustrated))
    {
        StartCharging();
    }
}

function bool IsInDamageBoostRadius(Actor Other)
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
    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object
    MonsterAfflictionList(0)=CoreMonsterAffliction'BurnAffliction'

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object
    MonsterAfflictionList(1)=CoreMonsterAffliction'ZapAffliction'

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonStunnedSpeedModifier=0.25f
    End Object
    MonsterAfflictionList(2)=CoreMonsterAffliction'HarpoonAffliction'

    EventClasses(0)="P_Fleshpound_DEF"
    ControllerClass=Class'KFTurbo.AI_Fleshpound'
}
