//Killing Floor Turbo AfflictionBase
//Base class for afflictions. Not replicated. Instanced per zed.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class AfflictionBase extends Object
	instanced
	abstract;

var float CachedMovementSpeedModifier;

simulated function Initialize(KFMonster Monster)
{

}

simulated function OnDeath(KFMonster Monster)
{

}

simulated function PreTick(KFMonster Monster, float DeltaTime)
{

}

simulated function Tick(KFMonster Monster, float DeltaTime)
{

}

simulated function TakeDamage(KFMonster Monster, int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, class<DamageType> DamageType, int HitIndex)
{

}

simulated final function float GetMovementSpeedModifier()
{
	return CachedMovementSpeedModifier;
}

defaultproperties
{
	CachedMovementSpeedModifier=1.f
}