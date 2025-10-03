//Killing Floor Turbo P_Bloat
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class P_Bloat extends MonsterBloat DependsOn(PawnHelper);

function RangedAttack(Actor A)
{
	local int LastFireTime;
    local float ChargeChance;

	if ( bShotAnim )
		return;

	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('Claw');
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
	}
	else if ( VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
		SetAnimAction('Claw');
		//PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else if ( (KFDoorMover(A) != none || VSize(A.Location-Location) <= 250) && !bDecapitated && !bHarpoonStunned)
	{
		bShotAnim = true;

        // Decide what chance the bloat has of charging during a puke attack
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ChargeChance = 0.2;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ChargeChance = 0.4;
        }
        else if( Level.Game.GameDifficulty < 5.0 )
        {
            ChargeChance = 0.6;
        }
        else // Hardest difficulty
        {
            ChargeChance = 0.8;
        }

		// Randomly do a moving attack so the player can't kite the zed
        if( FRand() < ChargeChance )
		{
    		SetAnimAction('ZombieBarfMoving');
    		RunAttackTimeout = GetAnimDuration('ZombieBarf', 1.0);
    		bMovingPukeAttack=true;
		}
		else
		{
    		SetAnimAction('ZombieBarf');
    		Controller.bPreparingMove = true;
    		Acceleration = vect(0,0,0);
		}


		// Randomly send out a message about Bloat Vomit burning(3% chance)
		if ( FRand() < 0.03 && KFHumanPawn(A) != none && PlayerController(KFHumanPawn(A).Controller) != none )
		{
			PlayerController(KFHumanPawn(A).Controller).Speech('AUTO', 7, "");
		}
	}
}

defaultproperties
{
    Begin Object Class=AfflictionBurn Name=BurnAffliction
        BurnDurationModifier=1.f
    End Object

    Begin Object Class=AfflictionZap Name=ZapAffliction
        ZapDischargeRate=0.5f
    End Object

    Begin Object Class=AfflictionHarpoon Name=HarpoonAffliction
        HarpoonSpeedModifier=0.5f
    End Object
}
