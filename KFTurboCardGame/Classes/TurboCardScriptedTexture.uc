//Killing Floor Turbo TurboCardScriptedTexture
//Distributed under the terms of the MIT License.
//For more information see https://github.com/KFPilot/KFTurbo.
class TurboCardScriptedTexture extends Engine.ScriptedTexture;

var bool bCardReady;

defaultproperties
{
    bCardReady=false

    UClamp=256
    VClamp=512
    
    UClampMode=TC_Clamp
    VClampMode=TC_Clamp
}