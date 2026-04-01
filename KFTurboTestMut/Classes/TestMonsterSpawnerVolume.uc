//Killing Floor Turbo TestMonsterSpawnerVolume
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TestMonsterSpawnerVolume extends Volume;

var(Spawner) Name AssociatedSpawnerTags[2];
var TestMonsterSpawner AssociatedSpawners[2];

function PostBeginPlay()
{
	foreach AllActors(class'TestMonsterSpawner', AssociatedSpawners[0], AssociatedSpawnerTags[0])
		break;
	foreach AllActors(class'TestMonsterSpawner', AssociatedSpawners[1], AssociatedSpawnerTags[1])
		break;
	
	AssociatedActor = AssociatedSpawners[0];

	Super.PostBeginPlay();
}

state AssociatedTouch
{
	event Touch(Actor Other)
	{
		if (KFHumanPawn(Other) == None)
		{
			return;
		}

		AssociatedActor.Touch(Other);
		AssociatedSpawners[0].Touch(Other);
		AssociatedSpawners[1].Touch(Other);
	}

	event UnTouch(Actor Other)
	{
		if (KFHumanPawn(Other) == None)
		{
			return;
		}
		
		AssociatedActor.UnTouch(Other);
		AssociatedSpawners[0].UnTouch(Other);
		AssociatedSpawners[1].UnTouch(Other);
	}
}

defaultproperties
{

}
