//Killing Floor Turbo W_M4203_Ammo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_M4203_Ammo extends M203Ammo;

simulated function CheckOutOfAmmo()
{
	Super.CheckOutOfAmmo();

	if (AmmoAmount <= 0)
	{
		NotifyFireModeEmpty();
	}
}

simulated function NotifyFireModeEmpty()
{
	local Weapon W;

	if (Pawn(Owner) == None || !Pawn(Owner).IsLocallyControlled() || Pawn(Owner).Weapon == None)
	{
		return;
	}

	W = Pawn(Owner).Weapon;

	if (W_M4203_Fire(W.GetFireMode(1)) == None)
	{
		return;
	}

	W_M4203_Fire(W.GetFireMode(1)).SetFireState(Ready); //Hack to make sure fire mode doesn't fail to update state on last fire.
}

defaultproperties
{
     AmmoPickupAmount=1
     MaxAmmo=10
     InitialAmount=5
}
