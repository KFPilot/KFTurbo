class KFTTHumanPawn extends TurboHumanPawn;

function bool CanBuyNow() {
	return true;
}

function AddDefaultInventory() {
	local KFTTPlayerController PC;
	local KFPlayerReplicationInfo PRI;
	local int i;

	Level.Game.AddGameSpecificInventory(Self);

	for (i = 0; i < ArrayCount(RequiredEquipment); i++)
		if (RequiredEquipment[i] != "")
			CreateInventory(RequiredEquipment[i]);

	PC = KFTTPlayerController(Controller);
	if (PC != None && PC.bKeepWeapons) {
		for (i = 0; i < PC.KeptWeapons.length; i++)
			if (PC.KeptWeapons[i] != "")
				CreateInventory(PC.KeptWeapons[i]);
	}
	else {
		PRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
		if (PRI != None && PRI.ClientVeteranSkill != None)
			PRI.ClientVeteranSkill.static.AddDefaultInventory(PRI, Self);
	}

	if (Inventory != None)
		Inventory.OwnerEvent('LoadOut');

	Controller.ClientSwitchToBestWeapon();
}

defaultproperties
{
}
