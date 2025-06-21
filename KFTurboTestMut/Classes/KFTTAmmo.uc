class KFTTAmmo extends KFMod.KFAmmoPickup;

state Pickup {
	function Touch(Actor Other) {
		local Pawn P;
		local KFPlayerReplicationInfo PRI;
		local Inventory CurInv;
		local KFAmmunition A;
		local int MaxAmmo;
		local bool bPickedUp;
		local Boomstick DBShotty;
		local bool bResuppliedBoomstick;

		P = Pawn(Other);
		if (P != None && P.bCanPickupInventory && P.Controller != None && FastTrace(Other.Location, Location)) {
			for (CurInv = Other.Inventory; CurInv != None; CurInv = CurInv.Inventory) {
				if (Boomstick(CurInv) != None)
					DBShotty = Boomstick(CurInv);

				A = KFAmmunition(CurInv);
				if (A != None && A.bAcceptsAmmoPickups) {
					MaxAmmo = A.default.MaxAmmo;
					
					PRI = KFPlayerReplicationInfo(P.PlayerReplicationInfo);
					if (PRI != None && PRI.ClientVeteranSkill != None)
						MaxAmmo = MaxAmmo * PRI.ClientVeteranSkill.static.AddExtraAmmoFor(PRI, A.Class);
				
					if (A.AmmoAmount < MaxAmmo) {
						A.AmmoAmount = MaxAmmo;
						
						if (DBShotgunAmmo(CurInv) != None)
							bResuppliedBoomstick = true;
							
						bPickedUp = true;
					}
				}
			}

			if (bPickedUp) {
				if (bResuppliedBoomstick && DBShotty != None)
					DBShotty.AmmoPickedUp();

				AnnouncePickup(P);
				GotoState('Sleeping', 'DelayedSpawn');
			}
		}
	}
}

auto state Sleeping {
	ignores Touch;

	function BeginState() {
		local int i;

		NetUpdateTime = Level.timeSeconds - 1;
		bHidden = true;
		SetCollision(false, false);

		for (i = 0; i < 4; i++)
			TeamOwner[i] = None;
	}

	function EndState() {
		NetUpdateTime = Level.timeSeconds - 1;
		bHidden = false;
		SetCollision(default.bCollideActors, default.bBlockActors);
	}
	
Begin:
	bHidden = false;

DelayedSpawn:
	Sleep(respawnTime);
	
	if (PickUpBase != None)
		PickUpBase.TurnOn();
		
	Goto('Respawn');

Respawn:
	bShowPickup = true;
	if (PickUpBase != None)
		PickUpBase.TurnOn();

	GotoState('Pickup');
}

defaultproperties
{
     RespawnTime=0.500000
     PickupMessage="Full Ammo"
}
