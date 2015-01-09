// Kismet node qui permet de changer la distance maximum que la camera peut aller 

class KNodeCameraDistMax extends SequenceAction;

var float   distLimit;

var  SailCamera cameraReference;

function Activated()
{
	local WorldInfo WorldInfo;
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	foreach WorldInfo.AllActors(Class 'SailCamera',cameraReference)
	{
		break;
	}

	cameraReference.setCameraDistMax(distLimit);
}

DefaultProperties
{
	ObjColor=(R=255,G=0,B=255,A=255)
	ObjName="Camera Distance Max"
	ObjCategory="Sail"
	bCallHandler=false

	VariableLinks(0) = (ExpectedType = class'SeqVar_Float', LinkDesc = "Distance Max", PropertyName = distLimit)
	
}
