//Killing Floor Turbo AfflictionBurn
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AfflictionBurn extends CoreMonsterAfflictionBurn;

var bool bHasCompleted;
var float BurnRatio;

//Speed modifiers
var float BurnPrimaryModifier;
var float BurnSecondaryModifier;

var float BurnDurationModifier;

struct BurnParameters
{
	var float BurnPrimaryModifier;
	var float BurnSecondaryModifier;
	var float BurnDuration;
};	
var BurnParameters Parameters;

struct AfflictionBurnPriorityData
{
	var class<CoreWeaponDamageType> DamageType; //Used to determine BurnStrength.
	var BurnParameters Parameters;
};
var array<AfflictionBurnPriorityData> FirePriorityList;

//Damage modifier
var float BurnMonsterDamageModifier;

var class<DamageType> LastBurnDamageType;
var float HighestBurnStrength; //Highest burn strength that has been applied.

simulated function Tick(CoreMonster Monster, float DeltaTime)
{
	Super.Tick(Monster, DeltaTime);

    if(Monster == None || !Monster.bBurnified)
    {
		return;
    }

	if (bHasCompleted)
	{
		return;
	}

	BurnRatio += (DeltaTime / Parameters.BurnDuration);

	if (BurnRatio >= 1.f)
	{
		bHasCompleted = true;
	}

	if (!bHasCompleted)
	{
		SetMovementSpeedModifier(Monster, Lerp(BurnRatio, Parameters.BurnPrimaryModifier, Parameters.BurnSecondaryModifier, true));
	}
	else
	{
		SetMovementSpeedModifier(Monster, 1.f);
		bShouldTick = !IsDoneTicking(Monster);
	}
}

simulated function bool IsDoneTicking(CoreMonster Monster)
{
	return Super.IsDoneTicking(Monster) && (BurnRatio >= 1.f || BurnRatio <= 0.f);
}

function ProcessBurnDamage(CoreMonster Monster, out float Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<CoreWeaponDamageType> WeaponDamageType, bool bIsHeadshot, optional int HitIndex)
{
	Super.ProcessBurnDamage(Monster, Damage, InstigatedBy, HitLocation, Momentum, WeaponDamageType, bIsHeadshot, HitIndex);
	UpdateBurnData(WeaponDamageType);
}

function UpdateBurnData(class<CoreWeaponDamageType> WeaponDamageType)
{
	local int Index;
	local float NewBurnStrength;
	local float EntryBurnStrength;
	NewBurnStrength = WeaponDamageType.default.BurnStrength;

	if (HighestBurnStrength >= NewBurnStrength)
	{
		return;
	}

	HighestBurnStrength = NewBurnStrength;

	bShouldTick = true;
	for (Index = 0; Index < FirePriorityList.Length; Index++)
	{
		if (FirePriorityList[Index].DamageType.default.BurnStrength > WeaponDamageType)
		{
			continue;
		}

		Parameters = FirePriorityList[Index].Parameters;
		//Half the burn ratio if we assigned a new burn type.
		BurnRatio = BurnRatio * 0.5f;
		break;
	}
}

function TakeFireDamage(CoreMonster Monster, int Damage, Pawn FireDamageInstigator)
{
	local Vector DummyHitLoc, DummyMomentum;
	Monster.bSkipPlayDirectionalHit = true;
	Monster.TakeDamage(Damage, FireDamageInstigator, DummyHitLoc, DummyMomentum, Monster.FireDamageClass);
	Monster.bSkipPlayDirectionalHit = false;

	if (Monster.BurnDown > 0)
	{
		Monster.BurnDown--;
	}

	if (Monster.BurnDown < Monster.CrispUpThreshhold)
	{
		Monster.ZombieCrispUp();
	}

	if (Monster.BurnDown == 0)
	{
		Monster.bBurnified = false;
		SetMovementSpeedModifier(Monster, 1.f);
	}
}

simulated function MeleeDamageTarget(CoreMonster Monster, out float Damage)
{
	if (Monster.BurnDown > 0)
	{
		Damage *= BurnMonsterDamageModifier;
	}
}


simulated function SetBurningBehavior(CoreMonster Monster) {}

simulated function UnSetBurningBehavior(CoreMonster Monster) {}

defaultproperties
{
	bHasCompleted=false
	BurnRatio=0.f

	BurnPrimaryModifier=1.f
	BurnSecondaryModifier=1.f
	BurnDurationModifier=1.f
	
	BurnMonsterDamageModifier=0.8f;

	//Default parameter for burn does nothing.
	Parameters=(BurnPrimaryModifier=1.f,BurnSecondaryModifier=1.f,BurnDuration=4.f,Priority=-1)

	FirePriorityList(0)=(DamageType=Class'KFMod.DamTypeHuskGun',Parameters=(BurnPrimaryModifier=0.250000,BurnSecondaryModifier=0.500000,BurnDuration=6.000000))
	FirePriorityList(1)=(DamageType=Class'KFTurbo.W_Trenchgun_DT',Parameters=(BurnPrimaryModifier=0.300000,BurnSecondaryModifier=0.600000,BurnDuration=5.500000,))
	FirePriorityList(2)=(DamageType=Class'KFTurbo.W_Flamethrower_DT',Parameters=(BurnPrimaryModifier=0.500000,BurnSecondaryModifier=0.600000,BurnDuration=6.000000))
	FirePriorityList(3)=(DamageType=Class'KFTurbo.W_FlareRevolver_Impact_DT',Parameters=(BurnPrimaryModifier=0.800000,BurnSecondaryModifier=0.900000,BurnDuration=4.500000))
	FirePriorityList(4)=(DamageType=Class'KFTurbo.W_ThompsonSMG_DT',Parameters=(BurnPrimaryModifier=0.850000,BurnSecondaryModifier=0.950000,BurnDuration=4.250000))
	FirePriorityList(5)=(DamageType=Class'KFTurbo.W_MAC10_DT',Parameters=(BurnPrimaryModifier=0.850000,BurnSecondaryModifier=0.950000,BurnDuration=4.250000))
	FirePriorityList(6)=(DamageType=Class'KFMod.DamTypeBurned',Parameters=(BurnPrimaryModifier=0.900000,BurnSecondaryModifier=1.000000,BurnDuration=4.000000))
}
