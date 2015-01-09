class Robot extends Pawn placeable;

var robotLight robotLight;

var SailBateau bateauReference;
var SailCamera cameraReference;


var float   vitesseRobot;
var float   vitesseRobotMax;
var float   vitesseRobotAcceleration;

var bool    lightActivate;

var int     distRobotBateauMax;

var vector positionRobotFuture;

var vector axeXUnitaire;
var vector axeYUnitaire;
var vector axeZUnitaire;

var vector lastDirection;;

var float  failSaveDistance;

var SoundCue soundRobotOn;
var SoundCue soundRobotOff;
var SoundCue soundCallPosei;

var AudioComponent soundRobotMove;
var AudioComponent soundRobotIdle;

var bool robotIsMoving;

var int cpt;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	//////// SPAWN la lumière du robot //////	
	robotLight = Spawn(class'robotLight',,, vect(34,1186,86190), rot(0, 0, 0), ,true );
	setBrightness(5);
	setColorLight(255, 36, 41, 5);
	setRadius(400);

	vitesseRobot = 1;
	cpt=0;
	lightActivate = false;

	SetPhysics(PHYS_Falling);

}

// Fonction permettant d'initialiser les références 
function setReference(SailBateau pawnRecu,SailCamera cameraRecu)
{
	bateauReference = pawnRecu;
	cameraReference = cameraRecu;
}

// Fonction utilisé pour donner la position du robot mais aussi celle de la lumière du robot
function setLocationRobot(vector locationRecu)
{							
	SetLocation(locationRecu);

	robotLight.SetLocation(locationRecu);
}
	
// Fonction qui est utilisé pour la gestion des déplacements du Robot
function updateDeplacement(PlayerInput playerInputRecu )     
{

	Local float distance;
	local float opposer;
	local float adjacent;
	local float angle;

	local float multiplicateurCadranX;
	local float multiplicateurCadranY;

	local vector vectorTempo1;
	local vector vectorTempo2;
	playRobotSound();

	/*if(!bateauReference.robotInFall)
	{	*/
		if(playerInputRecu.RawJoyLookUp != 0.0 || playerInputRecu.RawJoyLookRight != 0.0)
		{
		/*`log("_____");	
		`log("Up"@playerInputRecu.RawJoyLookUp);	
		`log("_____");	
		`log("left"@playerInputRecu.RawJoyLookRight);*/

			if(vitesseRobot < vitesseRobotMax)
			{
				vitesseRobot += vitesseRobotAcceleration;
			}
			if(cpt == 5)
			{
				lastDirection.X = playerInputRecu.RawJoyLookUp;
				lastDirection.Y = playerInputRecu.RawJoyLookRight;
				cpt=0;
			}
			else
			{
				cpt++;
			}

			robotIsMoving = true;
		}
		else
		{			
			
			if(vitesseRobot > 1)
			{
				if((lastDirection.X < 0.2 && lastDirection.X > -0.2)&&(lastDirection.Y < 0.1 && lastDirection.Y > -0.1))
				{
					lastDirection.X = lastDirection.X * 1.2;
					lastDirection.Y = lastDirection.Y * 1.2;
				}
				vitesseRobot -= vitesseRobotAcceleration;

		
			}
			else
			{
				vitesseRobot = 1;
				lastDirection.X = 0;
				lastDirection.Y = 0;

				robotIsMoving = false;


			}

			
		}
		
	
		//`log("test"@cameraReference.distanceCameraPlayer);
		// Permet de retourner dans les variables "axeXUnitaire" "axeYUnitaire" les axes en fonction de la caméra
		GetAxes(cameraReference.rotatorCamera,axeXUnitaire,axeYUnitaire,axeZUnitaire);
		axeXUnitaire.Z = 0;
		axeYUnitaire.Z = 0;	
				
		// Calcule de la position future du robot
		positionRobotFuture = Location + ((-(axeXUnitaire * (lastDirection.X)*1.2) + (axeYUnitaire * (lastDirection.Y)*0.65)) * vitesseRobot);	
		
		vectorTempo1 = positionRobotFuture;
		vectorTempo1.Z = 0;

		vectorTempo2 = bateauReference.Location;
		vectorTempo2.Z = 0;


		// Calcul de la distance entre le robot et le bateau
		//distance = Sqrt(((int(bateauReference.Location.X - positionRobotFuture.X))**2 + (int(bateauReference.Location.Y - positionRobotFuture.Y))**2));
		distance = Vsize( vectorTempo1 - vectorTempo2);

		// Regarde si la distance actuel du robot est plus petite que la distance max possible

		if(distance < distRobotBateauMax )
		{
			setLocationRobot(positionRobotFuture);
		}
		else
		{
			// .......... demander à Patrice ......... pour les prochaines ligne
			adjacent = abs(positionRobotFuture.X - bateauReference.Location.X );
			opposer = abs(positionRobotFuture.Y - bateauReference.Location.Y ); 	

			angle = Atan2(opposer,adjacent)*RadToDeg;

			if(((positionRobotFuture.Y - bateauReference.Location.Y) < 0)&&((positionRobotFuture.X - bateauReference.Location.X) < 0))
			{
				multiplicateurCadranX = -1;
				multiplicateurCadranY = -1;
			}
			if(((positionRobotFuture.Y - bateauReference.Location.Y) < 0)&&((positionRobotFuture.X - bateauReference.Location.X) > 0))
			{
				multiplicateurCadranX = 1;
				multiplicateurCadranY = -1;
			}
			if(((positionRobotFuture.Y - bateauReference.Location.Y) > 0)&&((positionRobotFuture.X - bateauReference.Location.X) > 0))
			{
				multiplicateurCadranX = 1;
				multiplicateurCadranY = 1;
			}
			if(((positionRobotFuture.Y - bateauReference.Location.Y) > 0)&&((positionRobotFuture.X - bateauReference.Location.X) < 0))
			{
				multiplicateurCadranX = -1;
				multiplicateurCadranY = 1;
			}
			
			//`log("______________");
			//`log("PositonNow - "@bateauReference.Location);

			

			positionRobotFuture.X = bateauReference.Location.X + multiplicateurCadranX*(distRobotBateauMax *(Cos((angle * pi) / 180)));
			positionRobotFuture.Y = bateauReference.Location.Y + multiplicateurCadranY*(distRobotBateauMax *(Sin((angle * pi) / 180)));
			positionRobotFuture.Z = Location.Z;
			
			//`log("PositonNEW - "@positionRobotFuture);
			
			setLocationRobot(positionRobotFuture);
		}
		

	/*}
	else
	{
		setLocationRobot(bateauReference.Location);
	}*/

	failSave();
}

event TakeDamage (int Damage, Controller InstigatedBy, Object.Vector HitLocation, Object.Vector Momentum, class<DamageType> DamageType, optional Actor.TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	return;
}

function failSave()
{
	local vector locationPawnSave;
	if(Vsize(Location - bateauReference.Location) > failSaveDistance)
	{		
		locationPawnSave = bateauReference.Location;
		locationPawnSave.X += 10;
		locationPawnSave.Y += 10;
		SetLocation(locationPawnSave);
		cameraReference.setBoolGoEasyDefault(true);
	}
}

// Permet de donner une couleur à la lumière du robot
function setColorLight(byte iRouge, byte iVert, byte iBleu, byte ia)
{
	robotLight.setColor(iRouge,iVert,iBleu,ia);
}

// Permet de donner le Radius de la lumière du robot
function setRadius(float RadiusRecu)
{
	robotLight.setRadius(RadiusRecu);		
}

// Permet de donner le Brightness de la lumère du robot
function setBrightness(float brightnessREcu)
{
	robotLight.setBrightness(brightnessREcu);
}

// Permet d'activer la lumière du robot en augmentant le Brightness
function setLightActivate()
{
	robotLight.setBrightness(20);
	lightActivate = true;
	PlaySound(soundRobotOn);
	PlaySound(soundCallPosei);
}

// Permet de désactiver la lumière du robot en diminuant le Brightness
function setLightInactivate()
{
	robotLight.setBrightness(5);
	lightActivate = false;
	PlaySound(soundRobotOff);
}

// Méthode qui permet de retourner si la lumière est activé ou non
function bool getIsLightActive()
{
	return lightActivate;
}

//En attendant les soundcue

function playRobotSound()
{
	if(robotIsMoving==true  && !soundRobotMove.IsPlaying())
	{
		soundRobotMove.Play();
		
	}
	
	if (robotIsMoving== false && soundRobotMove.IsPlaying())
	
	{
		soundRobotMove.Stop();
		
	}
}

DefaultProperties
{
	 Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
		PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
		AnimSets(0)=AnimSet'Sail_Drone.Sail_Drone_As'
		AnimTreeTemplate=AnimTree'Sail_Drone.Sail_Drone_AT'
		SkeletalMesh=SkeletalMesh'Sail_Drone.Sail_Drone_Sk'
		Scale3D=(X=6.0f,Y=6.0f,Z=6.0f)
	End Object

	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);

	CollisionType=COLLIDE_BlockAll
	bCanStepUpOn=false

	//SkeletalMesh'Sail_Drone.Sail_Drone_Sk'
//SkeletalMesh'Sail_Drone.Sail_Drone_Sk'
	//Mesh=MyStaticMeshComponent
	//Components.Add(MyStaticMeshComponent)
	//CollisionComponent=MyStaticMeshComponent

	bEdShouldSnap=false
    bCollideActors=false
    bBlockActors=false

	// Variable qui permet de donner une vitesse au robot

	vitesseRobotMax = 20.5;
	vitesseRobotAcceleration = 20.1;

	// Valeur Max que le robot pourra s'éloigner du bateau
	distRobotBateauMax = 1700;

	failSaveDistance = 2000;

	soundRobotOn=SoundCue'sail_sounds_pck.Drone_Powered_On_Cue'
	soundRobotOff=SoundCue'sail_sounds_pck.Drone_Powered_Off_Cue'
	soundCallPosei=SoundCue'sail_sounds_pck.Fae_Calls_Posei_Cue'

	Begin Object Class=AudioComponent Name=SrobotMove
		SoundCue=SoundCue'sail_sounds_pck.Drone_Full_Speed_Cue'
	End Object
	Components.Add(SrobotMove)
	soundRobotMove=SrobotMove

	/*Begin Object Class=AudioComponent Name=SrobotIdle
		SoundCue=
	End Object
	Components.Add(SrobotIdle)
	soundRobotIdle=SrobotIdle*/
}
