//Node de kismet permettant de locker/unlock la caméra
class KNodeRotationLock extends SequenceAction;

var bool   rotationCameraLockRecu;

var  SailCamera cameraReference;


function Activated()
{
	local WorldInfo WorldInfo;
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	foreach WorldInfo.AllActors(Class 'SailCamera',cameraReference)
	{
		break;
	}
	cameraReference.setRotationLock(rotationCameraLockRecu);
	

}

defaultproperties
{
	ObjColor=(R=255,G=0,B=255,A=255)
	ObjName="Lock Rotation"
	ObjCategory="Sail"
	bCallHandler=false

	VariableLinks(0) = (ExpectedType = class'SeqVar_Bool', LinkDesc = "RotationCameraLock", PropertyName = rotationCameraLockRecu)
}
