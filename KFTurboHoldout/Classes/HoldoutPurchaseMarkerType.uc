//Killing Floor Turbo TurboMarkerType
//Special class that allows for special behaviour for a marked actor.
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class HoldoutPurchaseMarkerType extends TurboMarkerType
    abstract;

static function bool CanMarkActor(Actor MarkedActor)
{
    return MarkedActor.bCollideActors;
}

static function float GetMarkerDuration(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    return 15.f;
}

static function vector GetMarkerOffset(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    return vect(0,0,1) * MarkActorClass.default.CollisionHeight;
}

static function bool ShouldReceiveLocationUpdate(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    return false;
}

static function String GenerateMarkerDisplayString(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    return HoldoutPurchaseTrigger(MarkedActor).GetMarkerName();
}