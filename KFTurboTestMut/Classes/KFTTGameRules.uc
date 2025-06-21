class KFTTGameRules extends GameRules;

const TIME_HitInterval = 0.06;

var KFTurboTestMut Mut;

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, Vector HitLocation) {
	local KFTTPlayerController PC;
	local Inventory Inv;
	
	if (KFMonster(Killed) != None) {
		PC = KFTTPlayerController(Killer);
		if (PC != None && !PC.bHitMultipleZeds && PC.LastDamagedZed == Killed) {
			PC.ReceiveDamageMessages();
		}
	}
	else if (KFHumanPawn(Killed) != None) {
		PC = KFTTPlayerController(Killed.Controller);
		if (PC != None && PC.bKeepWeapons) {
			PC.KeptWeapons.Remove(0, PC.KeptWeapons.length);
			for (Inv = Killed.Inventory; Inv != None; Inv = Inv.Inventory) {
				if (KFWeapon(Inv) != None && !Mut.static.IsRequiredWeapon(Inv)) {
					PC.KeptWeapons[PC.KeptWeapons.length] = string(Inv.Class);
				}
			}
		}
	}

	return false;
}

function int NetDamage(int originalDamage, int damage, Pawn Injured, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType) {
	local KFMonster InjuredZed;
	local KFTTPlayerController PC;
	
	if (NextGameRules != None) {
		damage = NextGameRules.NetDamage(originalDamage, damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType);
	}
	
	if (InstigatedBy == None) {
		return damage;
	}

	PC = KFTTPlayerController(InstigatedBy.Controller);
	InjuredZed = KFMonster(Injured);
	if (PC != None && InjuredZed != None) {
		if (PC.LastDamagedZed == None) {
			PC.bHitMultipleZeds = false;
			PC.LastDamagedZed = InjuredZed;
			PC.hitCount = 0;
			PC.lastDamage = 0;
			PC.SetTimer(TIME_HitInterval, false);
		}
		else if (PC.LastDamagedZed != InjuredZed) {
			PC.bHitMultipleZeds = true;
		}
		
		PC.hitCount++;
		PC.lastDamage += damage;
	}
	
	return damage;
}

defaultproperties
{
}
