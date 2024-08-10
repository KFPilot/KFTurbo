class P_Clot_Undead extends P_Clot_HAL;

var float RespawnFallbackDistance;
var bool bIsReviving;

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    local Actor NewActor; // Spawned Actor
    local vector FallbackLocation; // Location if the original spawn is blocked (melee kill and or other zed walked in)
    local vector DirectionVector; // The line drawn between the killer's location and the zed's location
    local vector KillerLocation; // Killer's location

    super(ZombieClot).Died(Killer, damageType, HitLocation);

	if( !(bDecapitated || class<KFWeaponDamageType>(damageType).default.bIsExplosive)) // if the death wasnt by headshot or explosive, begin respawn process
	{
        NewActor = Spawn(class'KFTurbo.P_Clot_Undead_Spawn',,, Location,Rotation); // respawn attempt #1, HitLocation can be changed to OriginalLocation/self.Location , but this is more reliable
        
        if(NewActor == None) // if failed to respawn, try again a bit further back and up
        {   
            KillerLocation = Killer.Pawn.Location;
            DirectionVector = Normal(Location - KillerLocation);
            FallbackLocation = Location + (DirectionVector * RespawnFallbackDistance) + vect(0,0,100);

            NewActor = Spawn(class'KFTurbo.P_Clot_Undead_Spawn',,, FallbackLocation,Rotation);
        }

        if(NewActor != None)
        {
            NewActor.SetPhysics(PHYS_Walking); //set newly spawned zed to walking anim
            NewActor.TakeDamage(1,Killer.Pawn,Location,vect(0,0,0),None);
        }

        Destroy(); // remove the corpse if respawned
	}
}


defaultproperties
{
    GroundSpeed=95.000000
    WaterSpeed=95.000000
    MenuName="Revenant"
    RespawnFallbackDistance=200.0
}