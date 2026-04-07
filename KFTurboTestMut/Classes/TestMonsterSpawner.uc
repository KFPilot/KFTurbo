//Killing Floor Turbo TestMonsterSpawner
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TestMonsterSpawner extends Keypoint
	hidecategories(Advanced,Force,Karma,LightColor,Lighting,Sound,UseTrigger);

var(Spawner) PawnHelper.EMonster Monster;
var class<KFMonster> MonsterClass;

var KFTTPlayerController LastSpawnInstigator;
var KFMonster LastSpawnedMonster;
var float NextSpawnTime;

function PostBeginPlay()
{
	local Rotator NewRotation;
	Super.PostBeginPlay();
	
	MonsterClass = class<KFMonster>(DynamicLoadObject(class'MC_Turbo'.default.MonsterClasses[int(Monster)].MClassName, class'Class'));
	NewRotation = Rotation;
	NewRotation.Pitch = 0;
	NewRotation.Roll = 0;
	SetRotation(NewRotation);
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	if (NextSpawnTime > Level.TimeSeconds)
	{
		return;
	}

	NextSpawnTime = Level.TimeSeconds + 0.05f;

	if (MonsterClass == None || EventInstigator == None || EventInstigator.Controller == None)
	{
		return;
	}

	SetLastSpawnInstigator(KFTTPlayerController(EventInstigator.Controller));
	SpawnMonster();
	
	if (LastSpawnedMonster == None)
	{
		return;
	}

	AttemptRespawnStart();
}

function SetLastSpawnInstigator(KFTTPlayerController NewLastSpawnInstigator)
{
	if (LastSpawnInstigator != None && LastSpawnInstigator.RespawningSpawner == Self)
	{
		LastSpawnInstigator.RespawningSpawner = None;
		GotoState('');
	}

	LastSpawnInstigator = NewLastSpawnInstigator;

	if (LastSpawnInstigator != None)
	{
		LastSpawnInstigator.RespawningSpawner = Self;
	}
}

function SpawnMonster()
{
	if (MonsterClass == None)
	{
		return;
	}

	LastSpawnedMonster = Spawn(MonsterClass, Self,, Location, Rotation);

	if (LastSpawnedMonster == None || LastSpawnInstigator == None || LastSpawnInstigator.Pawn == None)
	{
		return;
	}

	if (MonsterController(LastSpawnedMonster.Controller) != None)
	{
		MonsterController(LastSpawnedMonster.Controller).SetEnemy(LastSpawnInstigator.Pawn);
	}
}

function AttemptRespawnStart()
{
	if (LastSpawnInstigator == None || !LastSpawnInstigator.IsAutoRespawnEnabled())
	{
		return;
	}
	
	if (LastSpawnedMonster == None || LastSpawnedMonster.Health <= 0)
	{
		return;
	}

	GotoState('RespawnMonster');
}

function KillSpawnedMonster()
{
	if (LastSpawnedMonster != None && LastSpawnedMonster.Health > 0)
	{
		LastSpawnedMonster.Died(None, None, LastSpawnedMonster.Location);
	}
}

state RespawnMonster
{
	function AttemptRespawnStart() {}

	function SetLastSpawnInstigator(KFTTPlayerController NewLastSpawnInstigator)
	{
		Global.SetLastSpawnInstigator(NewLastSpawnInstigator);

		if (LastSpawnInstigator == None || !LastSpawnInstigator.IsAutoRespawnEnabled())
		{
			GotoState('');
		}
	}

	event UnTouch(Actor Other)
	{
		if (LastSpawnInstigator == None || LastSpawnInstigator.Pawn == None || LastSpawnInstigator.Pawn != Other)
		{
			return;
		}

		KillSpawnedMonster();
		SetLastSpawnInstigator(None);
	}

Begin:
	while(true)
	{
		if (LastSpawnInstigator == None || LastSpawnInstigator.Pawn == None || LastSpawnInstigator.Pawn.Health <= 0)
		{
			KillSpawnedMonster();
			break;
		}

		if (!LastSpawnInstigator.IsAutoRespawnEnabled() || LastSpawnInstigator.RespawningSpawner != Self)
		{
			break;
		}
		
		if (LastSpawnedMonster == None || LastSpawnedMonster.Health <= 0)
		{
			SpawnMonster();
		}

		Sleep(0.1f);
	}

	GotoState('');
}

defaultproperties
{
	bStatic=false
	bDirectional=true
	Texture=Texture'Gameplay.S_SpecialEvent'
	CollisionRadius=0
    CollisionHeight=0
}