//Killing Floor Turbo CardGamePlayerReplicationInfo
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardGamePlayerReplicationInfo extends Engine.LinkedReplicationInfo
    dependson(Interactions);

var KFPlayerReplicationInfo OwningReplicationInfo;
var TurboCardReplicationInfo TurboCardReplicationInfo;
var int VoteIndex;

var array< class<TurboCard> > SelectedCardList;

var class<CriticalHitEffect> HitEffectList[4];

replication
{
	reliable if ( bNetDirty && Role == ROLE_Authority )
		OwningReplicationInfo, TurboCardReplicationInfo, VoteIndex;
	reliable if ( Role < ROLE_Authority )
        SetVoteIndex;

	reliable if ( Role == ROLE_Authority )
        OnCriticalHit;
}

static simulated final function CardGamePlayerReplicationInfo GetCardGameLRI(PlayerReplicationInfo PRI)
{
    local LinkedReplicationInfo LRI;

    if (PRI == None)
    {
        return None;
    }

    for (LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
    {
        if (CardGamePlayerReplicationInfo(LRI) != None)
        {
            return CardGamePlayerReplicationInfo(LRI);
        }
    }
    
    return None;
}

simulated function bool ProcessVoteKeyPressEvent(Interactions.EInputKey Key)
{
    local float KeyVoteIndex;
    local Interactions.EInputKey Offset;

	if (!TurboCardReplicationInfo.bCurrentlyVoting)
    {
        return false;
    }

    if (Key <= IK_0 || Key > IK_9)
    {
        return false;
    }
    else
    {
        Offset = IK_0;
        KeyVoteIndex = int(Key) - int(Offset);

        if (class'TurboCardReplicationInfo'.static.ResolveCard(TurboCardReplicationInfo.SelectableCardList[KeyVoteIndex - 1]) == None)
        {
            KeyVoteIndex = 0;
        }
    }

    SetVoteIndex(KeyVoteIndex);
    return true;
}

function SetVoteIndex(int Index)
{
	if (!TurboCardReplicationInfo.bCurrentlyVoting)
    {
        return;
    }

    if (Index <= 0 || Index > 9 || class'TurboCardReplicationInfo'.static.ResolveCard(TurboCardReplicationInfo.SelectableCardList[Index - 1]) == None)
    {
        Index = 0;
    }

    VoteIndex = Index;
    ForceNetUpdate();
}

function ResetVote()
{
    VoteIndex = 0;
    ForceNetUpdate();
}

simulated function OnCriticalHit(Vector Location, int CriticalHitCount)
{
    if (Level.NetMode == NM_DedicatedServer || CriticalHitCount <= 0)
    {
        return;
    }

    Spawn(HitEffectList[Min(CriticalHitCount - 1, ArrayCount(HitEffectList) - 1)], OwningReplicationInfo.Owner,, Location);
}

//Make NetUpdateTime want to update now.
simulated function ForceNetUpdate()
{
    NetUpdateTime = Max(Level.TimeSeconds - ((1.f / NetUpdateFrequency) + 1.f), 0.1f);
}

defaultproperties
{
    VoteIndex = 0
    NetUpdateFrequency=0.1
    
    HitEffectList(0)=class'CriticalHitEffect'
    HitEffectList(1)=class'CriticalHitEffectDouble'
    HitEffectList(2)=class'CriticalHitEffectTriple'
    HitEffectList(3)=class'CriticalHitEffectMax'
}
