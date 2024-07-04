class AI_Crawler_Raptor extends CrawlerController;

function bool IsInPounceDist(actor PTarget)
{
  local vector DistVec;
  local float time;

  local float HeightMoved;
  local float EndHeight;

  //work out time needed to reach target

  DistVec = pawn.location - PTarget.location;
  DistVec.Z=0;

  time = vsize(DistVec)/ZombieCrawler(pawn).PounceSpeed;

  // vertical change in that time

  //assumes downward grav only
  HeightMoved = Pawn.JumpZ*time + 0.5*pawn.PhysicsVolume.Gravity.z*time*time;

  EndHeight = pawn.Location.z +HeightMoved;

  //log(Vsize(Pawn.Location - PTarget.Location));


  if((abs(EndHeight - PTarget.Location.Z) < Pawn.CollisionHeight + PTarget.CollisionHeight) &&
  VSize(pawn.Location - PTarget.Location) < KFMonster(pawn).MeleeRange * 20)
    return true;
  else
    return false;
}

defaultproperties
{
}