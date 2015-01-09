// Kismet pour matinee camera controle
class KNodeCustomCamera  extends SequenceAction;

var bool   customCameraBool;

var  SailCamera cameraReference;

function Activated()
{
	local WorldInfo WorldInfo;
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	foreach WorldInfo.AllActors(Class 'SailCamera',cameraReference)
	{
		break;
	}

	cameraReference.setCustomCamera(customCameraBool);
}

DefaultProperties
{
	ObjColor=(R=255,G=0,B=255,A=255)
	ObjName="Camera Custom On"
	ObjCategory="Sail"
	bCallHandler=false

	VariableLinks(0) = (ExpectedType = class'SeqVar_Bool', LinkDesc = "CustomCamera", PropertyName = customCameraBool)
	
}
