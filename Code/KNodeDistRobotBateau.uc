// Node de kismet permettant de modifier la distance max possible entre le robot et le bateau
class KNodeDistRobotBateau extends SequenceAction;

var float   distRobotBateauMaxRecu;

var  Robot robotReference;

function Activated()
{
	local WorldInfo WorldInfo;
	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	if(distRobotBateauMaxRecu != 0)
	{
		foreach WorldInfo.AllActors(Class 'Robot',robotReference)
		{
			break;
		}
		robotReference.distRobotBateauMax = distRobotBateauMaxRecu;
	}

}

DefaultProperties
{

	ObjColor=(R=255,G=0,B=255,A=255)
	ObjName="Distance Robot Player Max"
	ObjCategory="Sail"
	bCallHandler=false

	VariableLinks(0) = (ExpectedType = class'SeqVar_Float', LinkDesc = "DistanceRobotPlayerMax", PropertyName = distRobotBateauMaxRecu)
}
