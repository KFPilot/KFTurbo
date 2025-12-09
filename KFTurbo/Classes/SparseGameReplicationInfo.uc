//Common Core SparseGameReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/CommonCore.
class SparseGameReplicationInfo extends SparseReplicationInfo;

var CoreGameReplicationInfo OwningGRI;

//If true, this SGRI wants to receive ModifyMonster.
var const bool bReceiveModifyMonster; 

static function SparseReplicationInfo Find(Actor InSparseOwningActor)
{
    local CoreGameReplicationInfo GRI;

    if (InSparseOwningActor == None)
    {
        return None;
    }

    GRI = CoreGameReplicationInfo(InSparseOwningActor);
    if (GRI == None)
    {
        GRI = CoreGameReplicationInfo(InSparseOwningActor.Level.GRI);
        if (GRI == None)
        {
            Warn("Find: " $ default.Class $ " was subclassed from SparseGameReplicationInfo but InSparseOwningActor is not the CoreGameReplicationInfo (was a " $ InSparseOwningActor $ ").");
        }

        return None;
    }

    return GRI.GetSparseInfo(default.Class);
}

protected simulated function bool AttemptRegister()
{
    if (SparseOwningActor == None)
    {
        return false;
    }

    OwningGRI = CoreGameReplicationInfo(SparseOwningActor);
    if (OwningGRI == None)
    {
        Warn("AttemptRegister: " $ Class $" was subclassed from SparseGameReplicationInfo but SparseOwningActor is not the CoreGameReplicationInfo (was a " $ SparseOwningActor $ ").");
        return false;
    }

    OwningGRI.RegisterSparseInfo(Self);
    return true;
}

protected simulated function Unregister()
{
    if (OwningGRI == None)
    {
        return;
    }

    OwningGRI.UnregisterSparseInfo(Self);
}

defaultproperties
{
    bReceiveModifyMonster=false
}