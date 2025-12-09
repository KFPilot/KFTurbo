//Common Core CorePlayerReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class CoreGameReplicationInfo extends KFGameReplicationInfo;

var class<ServerTimeActor> ServerTimeActorClass;
var ServerTimeActor ServerTimeActor;

var array<SparseGameReplicationInfo> SparseReplicationInfoList;
var array<SparseGameReplicationInfo> SparseReplicationInfoMonsterEventList;
delegate OnReceiveSparseReplicationInfo(CoreGameReplicationInfo GRI, SparseGameReplicationInfo ReplicationInfo);

simulated function PostBeginPlay()
{
    if (Role == ROLE_Authority && ServerTimeActor == None)
    {
        if (ServerTimeActorClass == None)
        {
            ServerTimeActorClass = class'ServerTimeActor';
        }

        ServerTimeActor = Spawn(ServerTimeActorClass, Self);
    }

    Super.PostBeginPlay();
}

simulated function SparseGameReplicationInfo GetSparseInfo(class<SparseGameReplicationInfo> SparseGameClass)
{
	local int Index;
    for (Index = SparseReplicationInfoList.Length - 1; Index >= 0; Index--)
	{
		if (ClassIsChildOf(SparseReplicationInfoList[Index].Class, SparseGameClass))
		{
			return SparseReplicationInfoList[Index];
		}
	}

	return None;
}

simulated function RegisterSparseInfo(SparseGameReplicationInfo SPRI)
{
    SparseReplicationInfoList[SparseReplicationInfoList.Length] = SPRI;

    if (SPRI.bReceiveModifyMonster)
    {
        SparseReplicationInfoMonsterEventList[SparseReplicationInfoMonsterEventList.Length] = SPRI;
    }

	OnReceiveSparseReplicationInfo(Self, SPRI);
}

simulated function UnregisterSparseInfo(SparseGameReplicationInfo SPRI)
{
    local int Index;
    for (Index = SparseReplicationInfoList.Length - 1; Index >= 0; Index--)
    {
        if (SparseReplicationInfoList[Index] == SPRI)
        {
            SparseReplicationInfoList.Remove(Index, 1);
            return;
        }
    }
}