//Common Core CorePlayerReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class CorePlayerReplicationInfo extends KFStoryGame.KF_StoryPRI;

var array<SparsePlayerReplicationInfo> SparseReplicationInfoList;
delegate OnReceiveSparseReplicationInfo(CorePlayerReplicationInfo PlayerReplicationInfo, SparsePlayerReplicationInfo ReplicationInfo);

simulated function SparsePlayerReplicationInfo GetSparseInfo(class<SparsePlayerReplicationInfo> SparsePRIClass)
{
    local int Index;
    for (Index = SparseReplicationInfoList.Length - 1; Index >= 0; Index--)
	{
		if (ClassIsChildOf(SparseReplicationInfoList[Index].Class, SparsePRIClass))
		{
			return SparseReplicationInfoList[Index];
		}
	}

	return None;
}

simulated function RegisterSparseInfo(SparsePlayerReplicationInfo SPRI)
{
    SparseReplicationInfoList[SparseReplicationInfoList.Length] = SPRI;
    OnReceiveSparseReplicationInfo(Self, SPRI);
}

simulated function UnregisterSparseInfo(SparsePlayerReplicationInfo SPRI)
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

simulated function Destroyed()
{
    local int Index;
    for (Index = SparseReplicationInfoList.Length - 1; Index >= 0; Index--)
    {
        if (SparseReplicationInfoList[Index] == None)
        {
			continue;
        }

		SparseReplicationInfoList[Index].OnOwnerDestroyed();
    }

	Super.Destroyed();
}