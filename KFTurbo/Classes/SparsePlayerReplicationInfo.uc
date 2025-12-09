//Common Core SparsePlayerReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class SparsePlayerReplicationInfo extends SparseReplicationInfo;

var CorePlayerReplicationInfo OwningPRI;

static function SparseReplicationInfo Find(Actor InSparseOwningActor)
{
    local CorePlayerReplicationInfo PlayerReplicationInfo;

    if (InSparseOwningActor == None)
    {
        return None;
    }

    PlayerReplicationInfo = CorePlayerReplicationInfo(InSparseOwningActor);
    if (PlayerReplicationInfo == None)
    {
        Warn("Find: " $ default.Class $ " was subclassed from SparsePlayerReplicationInfo but InSparseOwningActor is not a CorePlayerReplicationInfo (was a " $ InSparseOwningActor $ ").");
        return None;
    }

    return PlayerReplicationInfo.GetSparseInfo(default.Class);
}

protected simulated function bool AttemptRegister()
{
    if (SparseOwningActor == None)
    {
        return false;
    }

    OwningPRI = CorePlayerReplicationInfo(SparseOwningActor);
    if (OwningPRI == None)
    {
        Warn("AttemptRegister: " $ Class $" was subclassed from SparsePlayerReplicationInfo but SparseOwningActor is not a CorePlayerReplicationInfo (was a " $ SparseOwningActor $ ").");
        return false;
    }

    OwningPRI.RegisterSparseInfo(Self);
    return true;
}

simulated function Unregister()
{
    if (OwningPRI == None)
    {
        return;
    }

    OwningPRI.UnregisterSparseInfo(Self);
    return;
}

defaultproperties
{

}