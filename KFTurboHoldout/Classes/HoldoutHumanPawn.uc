//Killing Floor Turbo HoldoutHumanPawn
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutHumanPawn extends TurboHumanPawn;

function AddDefaultInventory()
{
	local int Index;

	Level.Game.AddGameSpecificInventory(self);

	for (Index = ArrayCount(RequiredEquipment) - 1; Index >= 0; Index--)
	{
		if (RequiredEquipment[Index] == "")
		{
			continue;
		}

		CreateInventory(RequiredEquipment[Index]);
	}

	if (W_Frag_Weap(Weapon) != None)
	{
		EquipAnythingButGrenade();
	}

	if (Inventory != None)
	{
		Inventory.OwnerEvent('LoadOut');
	}

	if (Controller != None)
	{
		Controller.ClientSwitchToBestWeapon();
	}
}

simulated function bool CanCarry(float Weight)
{
    if(Weight <= 0)
    {
        return true;
    }

	return (CurrentWeight + Weight) <= MaxCarryWeight;
}

function TossWeapon(Vector TossVel)
{
	local Vector X,Y,Z;

	if (Health <= 0)
	{
		PerformDeathToss(TossVel);
		return;
	}

	TossCarriedItems();

	Weapon.Velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	Weapon.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);
}

function PerformDeathToss(Vector TossVel)
{
	local Vector X,Y,Z;
	local Inventory WeaponToToss;
	local float Rating;

	if (Level.bLevelChange)
	{
		return;
	}

	if (KFWeapon(Weapon) == None || !KFWeapon(Weapon).bKFNeverThrow)
	{
		Super.TossWeapon(TossVel);
		return;
	}

	WeaponToToss = Inventory.RecommendWeapon(Rating);

	if (KFWeapon(WeaponToToss) == None || Rating < -50 || KFWeapon(WeaponToToss).bKFNeverThrow)
	{
		return;
	}

	WeaponToToss.Velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	WeaponToToss.DropFrom(Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);
}

defaultproperties
{
	bDebugServerBuyWeapon=false
	HealthHealingTo=0
	JumpZMultiplier=1.f

	RequiredEquipment(0)="KFTurbo.W_Knife_Weap"
	RequiredEquipment(1)="KFTurbo.W_Frag_Weap"
	RequiredEquipment(2)=""
    RequiredEquipment(3)=""
	RequiredEquipment(4)=""
	RequiredEquipment(5)=""
}