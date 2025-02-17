//Handles a purchaseable room.
class HoldoutRoomManager extends Info
	hidecategories(Advanced,Collision,Display,Force,Karma,LightColor,Lighting,Sound)
	placeable;

var(RoomManager) int PurchasePrice;
var(RoomManager) string RoomName;
var(RoomManager) Name PurchaseTriggerTag;
var(RoomManager) array<Name> DoorTagList;
var(RoomManager) Name ZombieVolumeTag;
var(RoomManager) Name DoorNodeTag;

var bool bIsPurchased;
var bool bIsInitialized;
var array<HoldoutPurchaseRoomTrigger> PurchaseTriggerList;
var array<HoldoutDoor> DoorList;
var array<HoldoutZombieVolume> ZombieVolumeList;
var array<HoldoutDoorPathNode> DoorNodeList;

simulated function Setup()
{
	local HoldoutPurchaseRoomTrigger RoomTrigger;
	local int Index;
	local HoldoutDoor Door;
	local HoldoutDoorPathNode DoorNode;
	local HoldoutZombieVolume ZombieVolume;

	if (bIsInitialized)
	{
		return;
	}

	bIsInitialized = true;
	
	foreach AllActors(class'HoldoutPurchaseRoomTrigger', RoomTrigger, PurchaseTriggerTag)
	{
		PurchaseTriggerList[PurchaseTriggerList.Length] = RoomTrigger;
		RoomTrigger.RegisterManager(Self);
	}

	for (Index = 0; Index < DoorTagList.Length; Index++)
	{
		foreach AllActors(class'HoldoutDoor', Door, DoorTagList[Index])
		{
			DoorList[DoorList.Length] = Door;
		}
	}

	foreach AllActors(class'HoldoutDoorPathNode', DoorNode, DoorNodeTag)
	{
		DoorNodeList[DoorNodeList.Length] = DoorNode;
	}

	foreach AllActors(class'HoldoutZombieVolume', ZombieVolume, ZombieVolumeTag)
	{
		ZombieVolume.bVolumeIsEnabled = false;
		ZombieVolumeList[ZombieVolumeList.Length] = ZombieVolume;
	}
}

simulated function int GetPurchasePrice()
{
	return PurchasePrice;
}

simulated function string GetRoomName()
{
	return RoomName;
}

function bool PurchaseRoom(Pawn EventInstigator)
{
	local int Index;

	if (bIsPurchased)
	{
		return false;
	}

	if (EventInstigator.PlayerReplicationInfo == None)
	{
		return false;
	}

	if (EventInstigator.PlayerReplicationInfo.Score < PurchasePrice)
	{
		return false;
	}

	EventInstigator.PlayerReplicationInfo.Score -= PurchasePrice;
	
	for (Index = 0; Index < PurchaseTriggerList.Length; Index++)
	{
		PurchaseTriggerList[Index].OnPurchase();
	}
	
	for (Index = 0; Index < DoorList.Length; Index++)
	{
		DoorList[Index].DoOpen();
	}
	
	for (Index = 0; Index < DoorNodeList.Length; Index++)
	{
		DoorNodeList[Index].MoverOpened();
	}
	
	for (Index = 0; Index < ZombieVolumeList.Length; Index++)
	{
		ZombieVolumeList[Index].bVolumeIsEnabled = true;
	}

	return true;
}

defaultproperties
{
	bStatic=true

	bIsPurchased=false
	Texture=Texture'Engine.SubActionGameSpeed'
	DrawScale=3.f
}
