//Killing Floor Turbo CardModifierAdditiveStack
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class CardModifierAdditiveStack extends CardModifierStack
	instanced;

function UpdateModifier()
{
    local int Index;
    CachedModifier = default.CachedModifier;
    for (Index = ModifierList.Length - 1; Index >= 0; Index--)
    {
        CachedModifier += ModifierList[Index].Modifier;
    }

    log(ModifierStackID$": New additive modifier value is"@CachedModifier@".", 'KFTurboCardGame');
    OnModifierChanged(Self, CachedModifier);
}

defaultproperties
{
    CachedModifier = 0.f
}