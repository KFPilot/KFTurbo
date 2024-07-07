class W_M4203_Weap extends M4203AssaultRifle
	dependson(W_M4203_Fire);

enum ELoadState
{
	Invalid,
	Unloaded,
	Loaded
};

var ELoadState SecondaryLoadState;
var bool bAwaitingSecondaryStatus;

replication
{
	reliable if(Role == ROLE_Authority)
		ClientSetLoadState, ClientNotifyReload;
	reliable if(Role < ROLE_Authority)
		ServerReloadSecondary;
}

simulated function bool CanZoomNow()
{
	return W_M4203_Fire(FireMode[1]).IsIdle();
}

simulated function bool AllowReload()
{
	if (!W_M4203_Fire(FireMode[1]).IsIdle())
	{
		return false;
	}

	return Super(M4AssaultRifle).AllowReload();
}

exec function ReloadMeNow()
{
	if (!AllowReload())
	{
		if (W_M4203_Fire(FireMode[1]).IsFiring())
		{
			W_M4203_Fire(FireMode[1]).NotifyPendingReload();
		}
		return;
	}

	Super.ReloadMeNow();
}

simulated function UpdateSecondaryFromLoadState(ELoadState NewLoadState)
{
	switch (NewLoadState)
	{
	case Loaded:
		W_M4203_Fire(FireMode[1]).SetFireState(ReadyLoaded);
		break;
	default:
		W_M4203_Fire(FireMode[1]).SetFireState(Ready);
		break;
	}

	if (Instigator != None && Instigator.Role == ROLE_Authority && !Instigator.IsLocallyControlled())
	{
		ClientSetLoadState(NewLoadState);
	}
}

simulated function ClientSetLoadState(ELoadState NewLoadState)
{
	UpdateSecondaryFromLoadState(NewLoadState);
}

simulated function ClientNotifyReload(float WorldTimeSecondsOverride)
{
	local W_M4203_Fire M4203Fire;
	M4203Fire = W_M4203_Fire(FireMode[1]);

	if (M4203Fire != None && M4203Fire.GetFireState() != Reloading)
	{
		M4203Fire.SetFireState(Ready);
		M4203Fire.PerformReload(WorldTimeSecondsOverride);
	}
}

function ServerReloadSecondary()
{
	local W_M4203_Fire M4203Fire;
	M4203Fire = W_M4203_Fire(FireMode[1]);

	if (M4203Fire != None && M4203Fire.GetFireState() != Reloading)
	{
		M4203Fire.PerformReload(Level.TimeSeconds);
	}
}

simulated function bool PutDown()
{
	if (!W_M4203_Fire(FireMode[1]).IsIdle())
	{
		return false;
	}

	if (!Super.PutDown())
	{
		return false;
	}

	return true;
}

simulated function bool ReadyToFire(int Mode)
{
	if(!W_M4203_Fire(FireMode[1]).IsIdle())
	{
		return false;
	}

	if (Mode == 1 && !W_M4203_Fire(FireMode[1]).IsReadyAndLoaded())
	{
		return false;
	}
	
	return Super(M4AssaultRifle).ReadyToFire(Mode);
}

simulated function bool StartFire(int Mode)
{
	if (!Super.StartFire(Mode))
	{
		if (!bIsReloading && ClientState == WS_ReadyToFire && Mode == 1
			&& Instigator != None && Instigator.IsLocallyControlled())
		{
			if (W_M4203_Fire(FireMode[1]).IsReady() && !W_M4203_Fire(FireMode[1]).IsFiring() && !W_M4203_Fire(FireMode[1]).IsCurrentlyFiring())
			{
				W_M4203_Fire(FireMode[1]).PerformReload(Level.TimeSeconds);

				if (Role != ROLE_Authority)
				{
					ServerReloadSecondary();
				}
			}
		}

		return false;
	}

	if (Mode == 1 && bAimingRifle)
	{
		ZoomOut(true);
	}
	
	return true;
}

simulated function Timer()
{
	Super.Timer();
}

defaultproperties
{
     bAwaitingSecondaryStatus=True
     MagCapacity=30
     HudImage=Texture'KillingFloor2HUD.WeaponSelect.M4_203_unselected'
     SelectedHudImage=Texture'KillingFloor2HUD.WeaponSelect.M4_203'
     MeshRef="KFTurbo.M4M203Aimpoint_1st"
     SkinRefs(1)="KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr"
     FireModeClass(0)=Class'KFTurbo.W_M4203_Fire_Bullet'
     FireModeClass(1)=Class'KFTurbo.W_M4203_Fire'
     InventoryGroup=3
     PickupClass=Class'KFTurbo.W_M4203_Pickup'
     AttachmentClass=Class'KFTurbo.W_M4203_Attachment'
     Mesh=SkeletalMesh'KFTurbo.M4M203Aimpoint_1st'
     Skins(0)=Combiner'KF_Weapons4_Trip_T.Weapons.m4_cmb'
     Skins(1)=Shader'KF_Weapons2_Trip_T.Special.Aimpoint_sight_shdr'
}
