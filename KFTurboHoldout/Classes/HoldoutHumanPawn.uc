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
	//Don't toss a weapon on death. Let the Holdout game mode handle this.
	if (Health <= 0)
	{
		return;
	}

	Super.TossWeapon(TossVel);
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