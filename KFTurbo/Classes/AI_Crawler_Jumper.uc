//Killing Floor Turbo AI_Crawler_Jumper
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AI_Crawler_Jumper extends CrawlerController;

function bool IsInPounceDist(actor PTarget)
{
    local KFMonster Monster;
    local float PreviousMeleeRange;
    local bool bResult;

    Monster = KFMonster(Pawn);
    bResult = false;
    if (Monster != None)
    {
        PreviousMeleeRange = Monster.MeleeRange;
        Monster.MeleeRange = PreviousMeleeRange * 5.f;

        bResult = Super.IsInPounceDist(PTarget);
        
        Monster.MeleeRange = PreviousMeleeRange;
    }

    return bResult;
}

defaultproperties
{
}
