class A_Burn extends A_BaseAffliction;

var bool bHasCompleted;
var float BurnRatio;

var float BurnPrimaryModifier;
var float BurnSecondaryModifier;
var float BurnDurationModifier;

struct BurnParameters
{
	var float BurnPrimaryModifier;
	var float BurnSecondaryModifier;
	var float BurnDuration;
	var int Priority;
};	
var BurnParameters Parameters;

struct AfflictionBurnPriorityData
{
	var class<KFWeaponDamageType> DamageType;
	var BurnParameters Parameters;
};
var array<AfflictionBurnPriorityData> FirePriorityList;


simulated function PreTick(float DeltaTime)
{
    if(!OwningMonster.bBurnified)
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
		CachedMovementSpeedModifier = Lerp(BurnRatio, Parameters.BurnPrimaryModifier, Parameters.BurnSecondaryModifier, true);
	}
	else
	{
		CachedMovementSpeedModifier = 1.f;
	}
}

simulated function TakeDamage(int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, int HitIndex)
{
	UpdateBurnData(DamageType);
}

final simulated function UpdateBurnData(class<DamageType> DamageType)
{
	local int Index;

	if (Parameters.Priority == 0)
	{
		return;
	}

	for (Index = 0; Index < FirePriorityList.Length; Index++)
	{
		//FirePriorityList is in most to least priority order. If the priority of an element is <= the current priority, we can assume there will not be any more entries with a higher priority.
		if (FirePriorityList[Index].Parameters.Priority <= Parameters.Priority)
		{
			break;
		}
		
		if (FirePriorityList[Index].DamageType != DamageType)
		{
			continue;
		}

		Parameters = FirePriorityList[Index].Parameters;
		//Half the burn ratio if we assigned a new burn type.
		BurnRatio = BurnRatio * 0.5f;
		break;
	}
}

defaultproperties
{
	bHasCompleted=false
	BurnRatio=0.f

	BurnPrimaryModifier=1.f
	BurnSecondaryModifier=1.f
	BurnDurationModifier=1.f
	
	//Default parameter for burn does nothing.
	Parameters=(BurnPrimaryModifier=1.f,BurnSecondaryModifier=1.f,BurnDuration=4.f,Priority=-1)

	FirePriorityList(0)=(DamageType=Class'KFMod.DamTypeHuskGun',Parameters=(BurnPrimaryModifier=0.250000,BurnSecondaryModifier=0.500000,BurnDuration=6.000000,Priority=5))
	FirePriorityList(1)=(DamageType=Class'KFMod.DamTypeTrenchgun',Parameters=(BurnPrimaryModifier=0.300000,BurnSecondaryModifier=0.600000,BurnDuration=5.500000,Priority=4))
	FirePriorityList(2)=(DamageType=Class'KFMod.DamTypeFlareRevolver',Parameters=(BurnPrimaryModifier=0.800000,BurnSecondaryModifier=0.900000,BurnDuration=4.500000,Priority=3))
	FirePriorityList(3)=(DamageType=Class'KFMod.DamTypeMAC10MPInc',Parameters=(BurnPrimaryModifier=0.850000,BurnSecondaryModifier=0.950000,BurnDuration=4.250000,Priority=2))
	FirePriorityList(4)=(DamageType=Class'KFMod.DamTypeFlamethrower',Parameters=(BurnPrimaryModifier=0.900000,BurnSecondaryModifier=1.000000,BurnDuration=4.000000,Priority=1))
	FirePriorityList(5)=(DamageType=Class'KFMod.DamTypeBurned',Parameters=(BurnPrimaryModifier=0.900000,BurnSecondaryModifier=1.000000,BurnDuration=4.000000,Priority=0))
}
