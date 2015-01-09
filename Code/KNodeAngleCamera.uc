//Kismet Node permettant de modifier l'angle de la camera
class KNodeAngleCamera extends SequenceAction;

var float   angleCamera;

var  SailCamera cameraReference;

function Activated()
{
	local WorldInfo WorldInfo;
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	foreach WorldInfo.AllActors(Class 'SailCamera',cameraReference)
	{
		break;
	}

	cameraReference.setCameraAngle(angleCamera);
}

DefaultProperties
{
	ObjColor=(R=255,G=0,B=255,A=255)
	ObjName="Camera Angle"
	ObjCategory="Sail"
	bCallHandler=false

	VariableLinks(0) = (ExpectedType = class'SeqVar_Float', LinkDesc = "AngleCamera", PropertyName = angleCamera)
	
}
