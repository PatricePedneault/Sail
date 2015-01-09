class SailCamera extends Camera placeable;

var int         IsoCamAngle;
var Robot	    robotReference;
var SailBateau  bateauReference;

var float       distanceCameraPlayer;

var float       distCameraPlayerDefault;

var vector      vectorMilieuDistance;

var int         distPlayerRobotCameraStartZoomOut;

var float       distanceRobotPlayerPasse;

var bool        boolGoEasyDefault;

var float       rotationCamera;

var rotator     rotatorCamera;

var bool        rotationLock;

var float       rotationEasy;

var float       vitesseRotation;

var float       lastRotationDistance;

var float       cameraDistMax;

// si le variable direction = 1 = rotation à gauche
// si le variable direction = 2 = rotation à droite
var int         rotationDirection;

var bool        rotationNow;
var bool        rotationStateCamera;

var float       rotationToGo;
var Vector      positionToGo;

var float       angleToGo;

var float       vitesseAngleUpdate;

var bool        customCamera;

simulated event PostBeginPlay()
{
	boolGoEasyDefault = false;
	rotationEasy =  1;
	rotationToGo = -1;

	customCamera = false;

	rotationStateCamera = false;
	distanceCameraPlayer = distCameraPlayerDefault;
	super.PostBeginPlay();
}

// Méthode permettant de donner les valeurs aux variables qui font référence au bateau et au robot
function setReference(SailBateau pawnRecu,Robot robotReferenceRecu)
{
	bateauReference =   pawnRecu;
	robotReference  =   robotReferenceRecu;
}

// Méthode qui est permet de mettre à jour tout ce qui entour la caméra de jeu (rotation, position)
function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{	
	
	local float     angle;
	local vector    newLocation;
	local vector    vectorTempo;
	
if(customCamera)
	{
	updateRotation(Outvt.POV.Location);	
	updateAngle();
	
	if(boolGoEasyDefault)
	{
		GoEasyDefault();
	}
	else
	{
		updateDistanceCamera();
	}
	
	// On calcul la position(x,y,z) milieu entre le robot et le bateau, ce qui sera la position que la caméra pointera
	vectorMilieuDistance.X = bateauReference.Location.X  + (robotReference.Location.X - bateauReference.Location.X) / 2;
	vectorMilieuDistance.Y = bateauReference.Location.Y  + (robotReference.Location.Y - bateauReference.Location.Y) / 2;
	vectorMilieuDistance.Z = bateauReference.Location.Z;


	// On calcul la position Z que la caméra sera, en fonction de la variable "distanceCameraPlayer" (calcul de droite)
	if(OutVT.POV.Location.Z + 50 < vectorMilieuDistance.Z + (4 * distanceCameraPlayer))
	{
		OutVT.POV.Location.Z += 5;
	}
	else if (OutVT.POV.Location.Z - 50 > vectorMilieuDistance.Z + (4 * distanceCameraPlayer))
	{
		OutVT.POV.Location.Z -= 5;
	}
	else
	{
		OutVT.POV.Location.Z = vectorMilieuDistance.Z + (4 * distanceCameraPlayer);
	}
		


	// Produit croisé qui permet de transformer l'échelle de calcul de rotation de UDK dans un intervale 0-360
	angle = ((90*rotationCamera)/16384);	
	
	// On calcul l'angle que la caméra a en fonction de sa rotation
	angle = (angle * pi) / 180;

	// Calcul la position X,Y de la caméra (Calcul de cercle)
	// r = distanceCameraPlayer
	// a = vectorMilieuDistance.X
	// b = vectorMilieuDistance.Y
	

	newLocation.X = vectorMilieuDistance.X - getRayonCamera() * (Cos(angle));
	newLocation.Y = vectorMilieuDistance.Y - getRayonCamera() * (Sin(angle));
	newLocation.Z = 0;

	vectorTempo = OutVT.POV.Location;
	vectorTempo.Z = 0;
	
	if(Vsize(newLocation - vectorTempo) > 2000)
	{
		OutVT.POV.Location.X = newLocation.X;
		OutVT.POV.Location.Y = newLocation.Y;
		OutVT.POV.Location.Z = vectorMilieuDistance.Z + (4 * distanceCameraPlayer);
	}
	
	//`log("1");

	if(Vsize(newLocation - vectorTempo) > 100)
	{
		
		//`log("2");
		if(newLocation.Y > OutVT.POV.Location.Y + 10)
		{	
			OutVT.POV.Location.Y +=6; 
		}
		else if (newLocation.Y < OutVT.POV.Location.Y - 10)
		{
			OutVT.POV.Location.Y -=6; 	
		}

		if(newLocation.X > OutVT.POV.Location.X + 10)
		{	
			OutVT.POV.Location.X +=6; 
		}
		else if (newLocation.X < OutVT.POV.Location.X - 10)
		{
			OutVT.POV.Location.X -=6; 	
		}
	}
	else 
	{   
		//`log("3");
		OutVT.POV.Location.X = newLocation.X;
		OutVT.POV.Location.Y = newLocation.Y;
	}
	
	Outvt.POV.Rotation.Pitch = -1 * IsoCamAngle;

	Outvt.POV.Rotation.Yaw = rotationCamera;

	Outvt.POV.Rotation.Roll =0;
	
	rotatorCamera = Outvt.POV.Rotation;
	}
	else
	{
		super.UpdateViewTarget(outVT,DeltaTime);
	}
}



function updateAngle()
{
	if(angleToGo != 0)
	{
		if(angleToGo < IsoCamAngle)
		{
			if((IsoCamAngle - vitesseAngleUpdate) > angleToGo)
			{
				IsoCamAngle -= vitesseAngleUpdate;
			}
			else
			{
				IsoCamAngle = angleToGo;
				angleToGo = 0;
			}
		}
		else if(angleToGo > IsoCamAngle)
		{
			if((IsoCamAngle + vitesseAngleUpdate) < angleToGo)
			{
				IsoCamAngle += vitesseAngleUpdate;
			}
			else
			{
				IsoCamAngle = angleToGo;
				angleToGo = 0;
			}
		}
	}
}

// Méthode qui permet de donner la bonne distance à la caméra en fonction de la distance entre le robot et le bateau
function updateDistanceCamera()
{
		Local float distance;
		Local float distCameraFutur;

		if(distanceCameraPlayer > cameraDistMax)
		{
			distanceCameraPlayer -= 2;
		}
		else
		{		
			distance = Vsize(robotReference.Location - bateauReference.Location);
			if(distance > distPlayerRobotCameraStartZoomOut)
			{
				distCameraFutur = distance/3;

				if(distanceCameraPlayer + 30 < distCameraFutur)
				{
					if((distanceCameraPlayer + 2 ) < cameraDistMax)
					{
						distanceCameraPlayer += 2;			
					}
					else
					{
						distanceCameraPlayer = cameraDistMax;
					}
				}
				else if(distCameraFutur < cameraDistMax)
				{			
					distanceCameraPlayer = distCameraFutur;
				}
			}
		}
		

}

function updateRotation(vector locationOutVT)
{
	local vector        vectorTempo;

	// If qui permet de regarder si une rotation de la caméra est effectué
	// Si rotationNow = true, oui il y a rotation et on ne fait pas la méthode "cameraRotationEasy"
	// Si rotationNow = false, Aucune rotation n'a lieu donc l'on doit appeler la méthode "cameraRotationEasy"
	if(!rotationNow)
	{
		// Appelle de la méthode qui permet de diminuer de façon easy rotation la caméra lors qu'un fin de rotation
		cameraRotationEasy();
	}

	if(rotationToGo != -1)
	{
		vectorTempo.X = (Cos(((((90*(rotationCamera))/16384)) * pi) / 180));
		vectorTempo.Y = (Sin(((((90*(rotationCamera))/16384)) * pi) / 180));
		vectorTempo.Z = 0;
		
		if(lastRotationDistance == 0)
		{
			lastRotationDistance = VSize(positionToGo -  vectorTempo) +10;
		}

		if(VSize(positionToGo -  vectorTempo) <= lastRotationDistance)
		{
			lastRotationDistance = VSize(positionToGo -  vectorTempo);
			if(rotationDirection == 1)
			{		
					leftRotation();
			}
			else
			{
					rightRotation();			
			}
		}
		else
		{
			lastRotationDistance = 0;
			rotationToGo = -1;
			setRotationLock(false);
			rotationStateCamera = false;
		}
	}
}


function int getRayonCamera()
{
	local float rayon;
	local float multi;

	multi = (((9000 - IsoCamAngle) * 3) / 3641) + 3;

	rayon = distanceCameraPlayer * multi;

	return rayon;
}

function setCustomCamera(bool valeurRecu)
{
	customCamera = valeurRecu;
}


function goEasyDefault()
{
	Local float distance;
	distance = Vsize(robotReference.Location - bateauReference.Location);

	if(distanceCameraPlayer > distCameraPlayerDefault)
	{
		if(distanceCameraPlayer > distance/3)
		{
			distanceCameraPlayer -= 2;
		}
		else
		{
			boolGoEasyDefault = false;
		}
	}
	else
	{
		boolGoEasyDefault = false;
	}
}

// Méthode appelé pour une fin de rotation de façon "easy", si la variable "rotationEasyRight" ou "rotationEasyLeft" ne sont pas égale à 1 donc une rotation
// a eu lieu dernièrement et l'on appelle la méthode convenu qui s'occupera de faire un fin de rotation "easy"
function cameraRotationEasy()
{
	if(rotationStateCamera == false && rotationEasy > 1)
	{
		triggerRotationCamera(rotationDirection);
	}
}

function setBoolGoEasyDefault(bool boolRecu)
{
	boolGoEasyDefault = boolRecu;
}

function setCameraAngle(int angle)
{
	if(angle <= 60 && angle >= 10)
	{
		angleToGo = (angle * 65536)/360;
	}
}


// Méthode qui permet de donner la bonne valeur à la variable "rightRotationStat" en fonction du paramètre, 
// si elle recois true donc une rotation right a lieu  
// si elle recois False donc la rotation right est terminé
function rotationState(bool triggerRotationStatRecu)
{
	if(!rotationLock)
	{
		rotationStateCamera = triggerRotationStatRecu;

		if(triggerRotationStatRecu)
		{
			rotationNow = true;
			rotationEasy = 1;
		}
		else
		{
			rotationNow = false;
		}
	}
}

// Méthode qui permet de rotationner la caméra dans une direction
// si le paramètre direction = 1 = rotation à gauche
// si le paramètre direction = 2 = rotation à droite
function triggerRotationCamera(int direction)
{
	if(!rotationLock)
	{
		if(direction == 1)
		{
			rotationDirection = direction;
		}
		else
		{
			rotationDirection = direction;
		}

	
		if(direction == 1)
		{
			leftRotation();
		}
		else
		{
			rightRotation();
		}
	}
}

function leftRotation()
{
	setRotationEasy();

	if(rotationCamera + (vitesseRotation*rotationEasy) > 65536)
	{
		rotationCamera =(rotationCamera + (vitesseRotation*rotationEasy)) - 65536;
	}
	else
	{		
		rotationCamera += (vitesseRotation*rotationEasy);
	}
}

function rightRotation()
{
	setRotationEasy();
	if(rotationCamera - (vitesseRotation*rotationEasy) < 0 )
	{
		rotationCamera =(rotationCamera - (vitesseRotation*rotationEasy)) + 65536;
	}
	else
	{			
		rotationCamera -= (vitesseRotation*rotationEasy);
	}

}
// Permet qui permet de locker ou de delocker la caméra
function setRotationLock(bool boolRecu)
{
	rotationLock = boolRecu;
}


function setCameraDistMax(int distance)
{
	cameraDistMax = distance;	
}

// Méthode qui permet de donner une valeur de rotation de la caméra autour du joueur
function setRotationCamera(float rotationRecu)
{
	local vector        vectorLieuLeft;
	local vector        vectorLieuRight;
	
	if(rotationRecu <= 65536 && rotationRecu >= 0)
	{
		rotationToGo = rotationRecu;
		setRotationLock(true);
		rotationStateCamera = true;

		vectorLieuLeft.X = (Cos(((((90*(rotationCamera + 1000))/16384)) * pi) / 180));
		vectorLieuLeft.Y = (Sin(((((90*(rotationCamera + 1000))/16384)) * pi) / 180));
		vectorLieuLeft.Z = 0;

		vectorLieuRight.X = (Cos(((((90*(rotationCamera - 1000))/16384)) * pi) / 180));
		vectorLieuRight.Y = (Sin(((((90*(rotationCamera - 1000))/16384)) * pi) / 180));
		vectorLieuRight.Z = 0;
		
		positionToGo.X = (Cos(((((90*(rotationToGo))/16384)) * pi) / 180));
		positionToGo.Y = (Sin(((((90*(rotationToGo))/16384)) * pi) / 180));
		positionToGo.Z = 0;

		if(VSize(positionToGo - vectorLieuLeft) >= VSize(positionToGo - vectorLieuRight))
		{
			rotationDirection = 2;
		}
		else
		{
			rotationDirection = 1;
		}
	}
}

// If, else if qui permet un "Easy in" et "Easy out" de la caméra
function setRotationEasy()
{
	if(rotationStateCamera == true && rotationEasy <= 10)
	{			
		rotationEasy += 0.2;			
	}
	else if(rotationStateCamera == false && rotationEasy > 1)
	{
		rotationEasy -= 0.4;
	}
}
	

function setDistanceCamera(int distanceRecu)
{
	distanceCameraPlayer = distanceRecu;
}


function resetStartDistCamera()
{
	distanceCameraPlayer = distCameraPlayerDefault;
}

defaultproperties
{
	//0 - 360 to 0 - 65536
	//normalement = 6420             Complétement par dessus =16508
   	IsoCamAngle=10922   //  10922 = 60    9000 = 50   5461 = 30   1820 = 10              - 25

	vitesseAngleUpdate = 35

	vitesseRotation = 15

	distPlayerRobotCameraStartZoomOut = 300
	
	distCameraPlayerDefault = 101 // ATTENTION IMPORTANT

	cameraDistMax = 570

	rotationLock = false
}
