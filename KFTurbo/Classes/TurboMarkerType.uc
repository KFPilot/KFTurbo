class TurboMarkerType extends Object
    abstract;


static function float GetMarkerDuration(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    return 10.f;
}

static function bool ShouldReceiveLocationUpdate(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    return true;
}

static function String GenerateMarkerDisplayString(Actor MarkedActor, class<Actor> MarkActorClass, Object DataObject, class<Object> DataClass, int MarkerData)
{
    return "";
}