//Killing Floor Turbo AI_ZombieBoss
//Helps with improving the decision making of the Patriarch.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AI_ZombieBoss extends BossZombieController;

var float EnemyTargetProximityDistanceSq;
var float LongDistanceChargeDistanceSq;

//Returns true if the provided pawn is our enemy or near our enemy and either the provided pawn or our enemy is currently visible to us.
//Target must be far away.
function bool ShouldLongDistanceCharge(Pawn Target)
{
	if (Pawn == None || Pawn.Health <= 0)
	{
		return false;
	}

	if (Enemy == None || Target == None)
	{
		return false;
	}

	if (VSizeSquared(Enemy.Location - Target.Location) > EnemyTargetProximityDistanceSq)
	{
		return false;
	}

	if (VSizeSquared(Pawn.Location - Enemy.Location) < LongDistanceChargeDistanceSq && VSizeSquared(Pawn.Location - Target.Location) < LongDistanceChargeDistanceSq)
	{
		return false;
	}

	return FastTrace(Pawn.Location, Target.Location) || FastTrace(Pawn.Location, Enemy.Location);
}

defaultproperties
{
	EnemyTargetProximityDistanceSq=90000.f //300sq
	LongDistanceChargeDistanceSq=9000000.f //3000sq
}
