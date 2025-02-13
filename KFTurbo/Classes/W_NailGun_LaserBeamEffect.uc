//Killing Floor Turbo W_NailGun_LaserBeamEffect
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class W_NailGun_LaserBeamEffect extends LaserBeamEffect;

simulated function Tick(float dt)
{
    local Vector BeamDir;
    local BaseKFWeaponAttachment Attachment;
    local rotator NewRotation;
    local float LaserDist;

    if (Role == ROLE_Authority && (Instigator == None || Instigator.Controller == None))
    {
        Destroy();
        return;
    }
	
    if ( Instigator == None )
    {

    }
    else
    {
        if ( Instigator.IsFirstPerson() && Instigator.Weapon != None )
        {
            bHidden=True;
            if (Spot != None)
            {
                Spot.Destroy();
            }
        }
        else
        {
            bHidden=!bLaserActive;
            if( Level.NetMode != NM_DedicatedServer && Spot == none && bLaserActive)
            {
                Spot = Spawn(class'W_NailGun_LaserDot', self);
            }

            LaserDist = VSize(EndBeamEffect - StartEffect);
            if( LaserDist > 100 )
            {
                LaserDist = 100;
            }
            else
            {
                LaserDist *= 0.5;
            }

            Attachment = BaseKFWeaponAttachment(xPawn(Instigator).WeaponAttachment);
            if (Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1)
            {
                StartEffect= Attachment.GetBoneCoords('FlashLight').Origin;
                NewRotation = Rotator(-Attachment.GetBoneCoords('FlashLight').XAxis);
                SetLocation( StartEffect + Attachment.GetBoneCoords('FlashLight').XAxis * LaserDist );
            }
            else
            {
                StartEffect = Instigator.Location + Instigator.EyeHeight*Vect(0,0,1) + Normal(EndBeamEffect - Instigator.Location) * 25.0;
                SetLocation( StartEffect + Normal(EndBeamEffect - StartEffect) * LaserDist );
                NewRotation = Rotator(Normal(StartEffect - Location));
            }
        }
    }

    BeamDir = Normal(StartEffect - Location);
    SetRotation(NewRotation);

    mSpawnVecA = StartEffect;


    if (Spot != None)
    {
        Spot.SetLocation(EndBeamEffect + BeamDir * SpotProjectorPullback);

        if( EffectHitNormal == vect(0,0,0) )
        {
            Spot.SetRotation(Rotator(-BeamDir));
        }
        else
        {
            Spot.SetRotation(Rotator(-EffectHitNormal));
        }
    }
}

defaultproperties
{
     Skins(0)=Texture'kf_fx_trip_t.Misc.Green_Laser'
}
