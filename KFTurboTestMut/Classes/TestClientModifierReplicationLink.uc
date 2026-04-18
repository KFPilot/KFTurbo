//Killing Floor Turbo TestClientModifierReplicationLink
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TestClientModifierReplicationLink extends TurboClientModifierReplicationLink;

var protected bool bDisplayCollision;

simulated function ModifyMonster(KFMonster Monster)
{
    Super.ModifyMonster(Monster);
    
    if (Monster.Health <= 0)
    {
        return;
    }

    ApplyCollisionDebug(Monster);
}

simulated function SetDisplayCollision(bool bEnabled)
{
    local KFMonster Monster;
    local TestDebugCylinder Cylinder;
    if (bDisplayCollision == bEnabled)
    {
        return;
    }

    bDisplayCollision = bEnabled;
    if (bEnabled)
    {
        foreach DynamicActors(class'KFMonster', Monster)
        {
            if (Monster.Health <= 0)
            {
                continue;    
            }

            ApplyCollisionDebug(Monster);
        }
    }
    else
    {
        foreach DynamicActors(class'TestDebugCylinder', Cylinder)
        {
            Cylinder.Destroy();
        }
    }
}

simulated function ApplyCollisionDebug(KFMonster Monster)
{
    local TestDebugCylinder Cylinder;
    local Vector Scale3D;

    Cylinder = Spawn(class'TestDebugCylinder', Monster,, Monster.Location);

    Scale3D.X = Monster.CollisionRadius;
    Scale3D.Y = Monster.CollisionRadius;
    Scale3D.Z = Monster.CollisionHeight;
    Cylinder.SetDrawScale3D(Scale3D);
    Cylinder.SetBase(Monster);

    if (Monster.MyExtCollision != None)
    {
        Cylinder = Spawn(class'TestDebugCylinderExtended', Monster,, Monster.MyExtCollision.Location);

        Scale3D.X = Monster.ColRadius;
        Scale3D.Y = Monster.ColRadius;
        Scale3D.Z = Monster.ColHeight;
        Cylinder.SetDrawScale3D(Scale3D);
        Cylinder.SetBase(Monster.MyExtCollision);
    }
}

defaultproperties
{
    bDisplayCollision=false
}