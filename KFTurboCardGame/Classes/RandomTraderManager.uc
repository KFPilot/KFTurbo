//Killing Floor Turbo RandomTraderManager
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class RandomTraderManager extends Engine.Info;

function PostBeginPlay()
{
    Super.PostBeginPlay();

    SetTimer(0.1f + (FRand() * 0.4f), false);
}

function Timer()
{
    SetTimer(0.1f + (FRand() * 0.4f), false);

    if (KFTurboGameType(Level.Game) != None && !KFTurboGameType(Level.Game).bWaveInProgress)
    {
        return;
    }

    KFTurboGameType(Level.Game).SelectShop();
}

defaultproperties
{

}