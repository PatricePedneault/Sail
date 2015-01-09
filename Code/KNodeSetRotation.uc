// Node permettant de donner la rotation de la camera
class KNodeSetRotation extends SequenceAction;

var float   rotationCameraRecu;

var  SailCamera cameraReference;


function Activated()
{
	local WorldInfo WorldInfo;
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();
	
	if(rotationCameraRecu != 0)
	{
		foreach WorldInfo.AllActors(Class 'SailCamera',cameraReference)
		{
			break;
		}
		cameraReference.setRotationCamera((rotationCameraRecu * 65536)/360);
	}

}

defaultproperties
{
 
	ObjColor=(R=255,G=0,B=255,A=255)
	ObjName="Set Rotation"
	ObjCategory="Sail"
	bCallHandler=false

	VariableLinks(0) = (ExpectedType = class'SeqVar_Float', LinkDesc = "RotationCamera", PropertyName = rotationCameraRecu)
}
