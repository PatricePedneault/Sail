class ThirdControllerSail extends PlayerController;

var bool    boolLeftTriggerPush;
var bool    boolRightTriggerPush;
var bool    boolRightThumbstickPush;
var bool    boolLeftThumbstickPush;

var bool    initialisation;

var Robot   robotReference; 

var SailPoseiBotPawn baleineReference; 
var SailFishHealerPawn fishReference; 

var vector accelerationResultat;


	simulated event PostBeginPlay()
	{   
		initialisation = true;
		boolLeftTriggerPush = false;
		boolRightTriggerPush = false;
		boolRightThumbstickPush = false;

		Super.PostBeginPlay();

	}

	// Méthode qui permet d'initialiser les références 
	function initialisationReference()
	{

		// On cherche le Robot parmi les Pawns
		foreach WorldInfo.AllPawns(Class 'Robot',robotReference,Pawn.Location)
		{
			robotReference.setReference(SailBateau(Pawn),SailCamera(PlayerCamera));
			SailCamera(PlayerCamera).setReference(SailBateau(Pawn),robotReference);
			SailBateau(Pawn).setReference(SailCamera(PlayerCamera),robotReference);
			break;
		}

		// On cherche Posei parmi les Pawns
		foreach WorldInfo.AllPawns(Class 'SailPoseiBotPawn',baleineReference,Pawn.Location)
		{
			baleineReference.setReference(robotReference);
			SailBateau(Pawn).setPoseiReference(baleineReference);
			break;
		}

		// On cherche les poissons parmi les Pawns
		foreach WorldInfo.AllPawns(Class 'SailFishHealerPawn',fishReference,Pawn.Location)
		{
			fishReference.setReference(robotReference, baleineReference);
		}

		initialisation = false;
	}

	state PlayerWalking
	{
		function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
		{
			// Lors de la première entrer on fait l'initialisation des références
			if(initialisation == true)
			{
				initialisationReference();
			}
		
			// On appelle les méthodes qui permettent le déplacement du robot et du bateau
			SailBateau(pawn).updateDeplacement(PlayerInput);
			robotReference.updateDeplacement(PlayerInput);
			//SailBateau(pawn).addForce(vect(-5000000.0,0.0,0.0));
			boutonPush();
		}
	}
	
	function boutonPush()
	{
		// Si la variable "boolLeftTriggerPush" a comme valeur "true" alors la méthode "leftRotationCamera" est appelé pour effectuer la rotation de la caméra
		if(boolLeftTriggerPush == true)
		{
			SailCamera(PlayerCamera).triggerRotationCamera(1);
		}

		// Si la variable "boolRightTriggerPush" a comme valeur "true" alors la méthode "rightRotationCamera" est appelé pour effectuer la rotation de la caméra
		if(boolRightTriggerPush == true)
		{
			SailCamera(PlayerCamera).triggerRotationCamera(2);
		}

	}


	// Fonction push lorsque le Thumb du right stick est appuyé
	exec function rightThumbStickPush()
	{
		if(boolRightThumbstickPush == false)
		{
			boolRightThumbstickPush = true;
			robotReference.setLightActivate();
		}
		else
		{
			boolRightThumbstickPush = false;
			robotReference.setLightInactivate();
		}
	}

	// Fonction appelé lorsque Thumb du left stick est appuyé
	exec function leftThumbstickPush()
	{
		//boolLeftThumbstickPush = true;
	}
	
	// Fonction appelé lorsque Thumb du left stick est relâché
	exec function leftThumbStickRelease()
	{
		//boolLeftThumbstickPush = false;			
	}

	// Fonction appelé lorsque la gachette gauche est appuyé
	exec function leftTriggerPush()
	{	
		SailCamera(PlayerCamera).rotationState(true);
		boolRightTriggerPush = true;
		boolLeftTriggerPush = false;
	}
	
	// Fonction appelé lorsque la gachette gauche est relâché
	exec function leftTriggerRelease()
	{		
		if(boolRightTriggerPush != false)
		{
			SailCamera(PlayerCamera).rotationState(false);
			boolRightTriggerPush = false;	
		}
	}

	// Fonction appelé lorsque la gachette droite est appuyé
	exec function rightTriggerPush()
	{
		SailCamera(PlayerCamera).rotationState(true);
		boolLeftTriggerPush = true;	
		boolRightTriggerPush = false;
	}

	// Fonction appelé lorsque la gachette droite est relâché
	exec function rightTriggerRelease()
	{
		if(boolLeftTriggerPush != false)
		{
			SailCamera(PlayerCamera).rotationState(false);
			boolLeftTriggerPush = false;	
		}
	}

	// Fonction appelé lorsque le bouton start est appuyé
	exec function buttonStartPush()
	{
	}
	
	// Fonction appelé lorsque le bouton start est relâché
	exec function buttonStartRelease()
	{
	}

	// Fonction appelé lorsque le bouton shoulder droite est appuyé
	exec function buttonRightShoulderPush()
	{
	}
	
	// Fonction appelé lorsque le bouton shoulder droite est relâché
	exec function buttonRightShoulderRelease()
	{	
	}

	// Fonction appelé lorsque le bouton shoulder gauche est appuyé
	exec function buttonLeftShoulderPush()
	{
	}
		
	// Fonction appelé lorsque le bouton shoulder gauche est relâché
	exec function buttonLeftShoulderRelease()
	{
	}

	// Fonction appelé lorsque le bouton A est appuyé
	exec function buttonAPush()
	{	
		//SailCamera(PlayerCamera).setRotationLock(true);
	}
	
	// Fonction appelé lorsque le bouton A est relâché
	exec function buttonARelease()
	{
	}

	// Fonction appelé lorsque le bouton B est appuyé
	exec function buttonBPush()
	{	
		//SailCamera(PlayerCamera).setRotationLock(false);
	}
	
	// Fonction appelé lorsque le bouton B est relâché
	exec function buttonBRelease()
	{
	}

	// Fonction appelé lorsque le bouton Y est appuyé
	exec function buttonYPush()
	{
		//SailCamera(PlayerCamera).setRotationCamera(16000);
	}
	
	// Fonction appelé lorsque le bouton Y est relâché
	exec function buttonYRelease()
	{
		
	}

	// Fonction appelé lorsque le bouton X est appuyé
	exec function buttonXPush()
	{
		//SailCamera(PlayerCamera).setRotationCamera(1);
	}
	
	// Fonction appelé lorsque le bouton X est relâché
	exec function buttonXRelease()
	{	
	}

	// Fonction appelé lorsque le bouton Back est appuyé
	exec function buttonBackPush()
	{
	}
	
	// Fonction appelé lorsque le bouton Back est relâché
	exec function buttonBackRelease()
	{	
	}

	// Fonction appelé lorsque le bouton Up du DPad est appuyé
	exec function buttonUpDPadPush()
	{
	}
	
	// Fonction appelé lorsque le bouton Up du DPad est relâché
	exec function buttonUpDPadRelease()
	{	
	}

	// Fonction appelé lorsque le bouton Down du DPad est appuyé
	exec function buttonDownDPadPush()
	{
	}
	
	// Fonction appelé lorsque le bouton Down du DPad est relâché
	exec function buttonDownDPadRelease()
	{	
	}

	// Fonction appelé lorsque le bouton Left du DPad est appuyé
	exec function buttonLeftDPadPush()
	{
	}
	
	// Fonction appelé lorsque le bouton Left du DPad est relâché
	exec function buttonLeftDPadRelease()
	{	
	}

	// Fonction appelé lorsque le bouton Right du DPad est appuyé
	exec function buttonRightDPadPush()
	{	
	}
	
	// Fonction appelé lorsque le bouton Right du DPad est relâché
	exec function buttonRightDPadRelease()
	{	
	}


Defaultproperties
{
	CameraClass=class'SailGame.SailCamera'

}
