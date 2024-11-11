class KFTTHUD extends TurboHUDKillingFloor;

simulated function DrawKFHUDTextElements(Canvas C) 
{
	if (WaveInfoHUD != None)
	{
		WaveInfoHUD.Render(C);
	}
}

function DrawDoorHealthBars(Canvas C) {
	if (PlayerOwner.Pawn != None)
		Super.DrawDoorHealthBars(C);
}

simulated function DrawModOverlay(Canvas C) {
	local float MaxRBrighten, MaxGBrighten, MaxBBrighten;
	local PlayerReplicationInfo PRI;
	local bool bHasDefaultPhysicsVolume, bHasKFPhysicsVolume;

	C.SetPos(0, 0);

	if (VisionOverlay != None) {
		if(PlayerOwner == None || PlayerOwner.PlayerReplicationInfo == None) {
			return;
		}

		PRI = PlayerOwner.PlayerReplicationInfo;
		if (PlayerOwner.Pawn != None && PlayerOwner.Pawn.Health > 0) {
			if (PlayerOwner.pawn.Health < PlayerOwner.pawn.HealthMax * 0.25) {
				VisionOverlay = NearDeathOverlay;
			}
			else {
				VisionOverlay = default.VisionOverlay;
			}
		}

		if (!bInitialDark && PRI.bReadyToPlay) {
			C.SetDrawColor(0, 0, 0, 255);
			C.DrawTile(VisionOverlay, C.SizeX, C.SizeY, 0, 0, 1024, 1024);
			bInitialDark = true;
			return;
		}

		if (KFLevelRule != None && !KFLevelRule.bUseVisionOverlay) {
			return;
		}

		MaxRBrighten = Round(LastR* (1.0 - (LastR / 255)) - 2) ;
		MaxGBrighten = Round(LastG* (1.0 - (LastG / 255)) - 2) ;
		MaxBBrighten = Round(LastB* (1.0 - (LastB / 255)) - 2) ;

		C.SetDrawColor(LastR + MaxRBrighten, LastG + MaxGBrighten, LastB + MaxBBrighten, GrainAlpha);
		C.DrawTileScaled(VisionOverlay, C.SizeX, C.SizeY);

		if (PlayerOwner != None && PlayerOwner.Pawn != None) {
			if(DefaultPhysicsVolume(PlayerOwner.Pawn.PhysicsVolume) != None || PlayerOwner.Pawn.PhysicsVolume.IsA('KF_StoryCheckPointVolume')) {
				bHasDefaultPhysicsVolume = true;
			}
			else if(KFPhysicsVolume(PlayerOwner.Pawn.PhysicsVolume) != None) {
				bHasKFPhysicsVolume = true;
			}

			if (PRI.PlayerZone != None && !PRI.PlayerZone.bDistanceFog && PRI.PlayerVolume == None || !bHasDefaultPhysicsVolume && !PlayerOwner.Pawn.PhysicsVolume.bDistanceFog) {
				if(!bHasKFPhysicsVolume) {
					return;
				}
			}
		}

		if (PlayerOwner != None && !bZoneChanged && PlayerOwner.Pawn != None) {
			if (CurrentZone != PlayerOwner.PlayerReplicationInfo.PlayerZone || (!bHasDefaultPhysicsVolume && !bHasKFPhysicsVolume) && CurrentVolume != PlayerOwner.Pawn.PhysicsVolume) {
				if (CurrentZone != None) {
					LastZone = CurrentZone;
				}
				else if (CurrentVolume != None) {
					LastVolume = CurrentVolume;
				}

				if (PRI.PlayerZone != None && PRI.PlayerZone.bDistanceFog && (bHasDefaultPhysicsVolume || bHasKFPhysicsVolume) && !PRI.PlayerZone.bNoKFColorCorrection) {
					CurrentVolume = None;
					CurrentZone = PRI.PlayerZone;
				}
				else if (!bHasDefaultPhysicsVolume && PlayerOwner.Pawn.PhysicsVolume.bDistanceFog && !PlayerOwner.Pawn.PhysicsVolume.bNoKFColorCorrection) {
					CurrentZone = None;
					CurrentVolume = PlayerOwner.Pawn.PhysicsVolume;
				}

				if (CurrentVolume != None) {
					LastZone = None;
				}
				else if (CurrentZone != None) {
					LastVolume = None;
				}

				if (LastZone != None) {
					if(LastZone.bNewKFColorCorrection) {
						LastR = LastZone.KFOverlayColor.R;
						LastG = LastZone.KFOverlayColor.G;
						LastB = LastZone.KFOverlayColor.B;
					}
					else {
						LastR = LastZone.DistanceFogColor.R;
						LastG = LastZone.DistanceFogColor.G;
						LastB = LastZone.DistanceFogColor.B;
					}
				}
				else if (LastVolume != None) {
					if(LastVolume.bNewKFColorCorrection) {
						LastR = LastVolume.KFOverlayColor.R;
						LastG = LastVolume.KFOverlayColor.G;
						LastB = LastVolume.KFOverlayColor.B;
					}
					else {
						LastR = LastVolume.DistanceFogColor.R;
						LastG = LastVolume.DistanceFogColor.G;
						LastB = LastVolume.DistanceFogColor.B;
					}
				}
				else if (LastZone != None && LastVolume != None) {
					return;
				}

				if (LastZone != CurrentZone || LastVolume != CurrentVolume) {
					bZoneChanged = true;
					SetTimer(OverlayFadeSpeed, false);
				}
			}
		}
		
		if (!bTicksTurn && bZoneChanged) {
			ValueCheckOut = 0;
			bTicksTurn = true;
			SetTimer(OverlayFadeSpeed, false);
		}
	}
}

defaultproperties
{
}
