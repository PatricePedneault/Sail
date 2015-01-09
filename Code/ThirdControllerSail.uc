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

	// M�thode qui permet d'initialiser les r�f�rences 
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
			// Lors de la premi�re entrer on fait l'initialisation des r�f�rences
			if(initialisation == true)
			{
				initialisationReference();
			}
		
			// On appelle les m�thodes qui permettent le d�placement du robot et du bateau
			SailBateau(pawn).updateDeplacement(PlayerInput);
			robotReference.updateDeplacement(PlayerInput);
			//SailBateau(pawn).addForce(vect(-5000000.0,0.0,0.0));
			boutonPush();
		}
	}
	
	function boutonPush()
	{
		// Si la variable "boolLeftTriggerPush" a comme valeur "true" alors la m�thode "leftRotationCamera" est appel� pour effectuer la rotation de la cam�ra
		if(boolLeftTriggerPush == true)
		{
			SailCamera(PlayerCamera).triggerRotationCamera(1);
		}

		// Si la variable "boolRightTriggerPush" a comme valeur "true" alors la m�thode "rightRotationCamera" est appel� pour effectuer la rotation de la cam�ra
		if(boolRightTriggerPush == true)
		{
			SailCamera(PlayerCamera).triggerRotationCamera(2);
		}

	}


	// Fonction push lorsque le Thumb du right stick est appuy�
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

	// Fonction appel� lorsque Thumb du left stick est appuy�
	exec function leftThumbstickPush()
	{
		//boolLeftThumbstickPush = true;
	}
	
	// Fonction appel� lorsque Thumb du left stick est rel�ch�
	exec function leftThumbStickRelease()
	{
		//boolLeftThumbstickPush = false;			
	}

	// Fonction appel� lorsque la gachette gauche est appuy�
	exec function leftTriggerPush()
	{	
		SailCamera(PlayerCamera).rotationState(true);
		boolRightTriggerPush = true;
		boolLeftTriggerPush = false;
	}
	
	// Fonction appel� lorsque la gachette gauche est rel�ch�
	exec function leftTriggerRelease()
	{		
		if(boolRightTriggerPush != false)
		{
			SailCamera(PlayerCamera).rotationState(false);
			boolRightTriggerPush = false;	
		}
	}

	// Fonction appel� lorsque la gachette droite est appuy�
	exec function rightTriggerPush()
	{
		SailCamera(PlayerCamera).rotationState(true);
		boolLeftTriggerPush = true;	
		boolRightTriggerPush = false;
	}

	// Fonction appel� lorsque la gachette droite est rel�ch�
	exec function rightTriggerRelease()
	{
		if(boolLeftTriggerPush != false)
		{
			SailCamera(PlayerCamera).rotationState(false);
			boolLeftTriggerPush = false;	
		}
	}

	// Fonction appel� lorsque le bouton start est appuy�
	exec function buttonStartPush()
	{
	}
	
	// Fonction appel� lorsque le bouton start est rel�ch�
	exec function buttonStartRelease()
	{
	}

	// Fonction appel� lorsque le bouton shoulder droite est appuy�
	exec function buttonRightShoulderPush()
	{
	}
	
	// Fonction appel� lorsque le bouton shoulder droite est rel�ch�
	exec function buttonRightShoulderRelease()
	{	
	}

	// Fonction appel� lorsque le bouton shoulder gauche est appuy�
	exec function buttonLeftShoulderPush()
	{
	}
		
	// Fonction appel� lorsque le bouton shoulder gauche est rel�ch�
	exec function buttonLeftShoulderRelease()
	{
	}

	// Fonction appel� lorsque le bouton A est appuy�
	exec function buttonAPush()
	{	
		//SailCamera(PlayerCamera).setRotationLock(true);
	}
	
	// Fonction appel� lorsque le bouton A est rel�ch�
	exec function buttonARelease()
	{
	}

	// Fonction appel� lorsque le bouton B est appuy�
	exec function buttonBPush()
	{	
		//SailCamera(PlayerCamera).setRotationLock(false);
	}
	
	// Fonction appel� lorsque le bouton B est rel�ch�
	exec function buttonBRelease()
	{
	}

	// Fonction appel� lorsque le bouton Y est appuy�
	exec function buttonYPush()
	{
		//SailCamera(PlayerCamera).setRotationCamera(16000);
	}
	
	// Fonction appel� lorsque le bouton Y est rel�ch�
	exec function buttonYRelease()
	{
		
	}

	// Fonction appel� lorsque le bouton X est appuy�
	exec function buttonXPush()
	{
		//SailCamera(PlayerCamera).setRotationCamera(1);
	}
	
	// Fonction appel� lorsque le bouton X est rel�ch�
	exec function buttonXRelease()
	{	
	}

	// Fonction appel� lorsque le bouton Back est appuy�
	exec function buttonBackPush()
	{
	}
	
	// Fonction appel� lorsque le bouton Back est rel�ch�
	exec function buttonBackRelease()
	{	
	}

	// Fonction appel� lorsque le bouton Up du DPad est appuy�
	exec function buttonUpDPadPush()
	{
	}
	
	// Fonction appel� lorsque le bouton Up du DPad est rel�ch�
	exec function buttonUpDPadRelease()
	{	
	}

	// Fonction appel� lorsque le bouton Down du DPad est appuy�
	exec function buttonDownDPadPush()
	{
	}
	
	// Fonction appel� lorsque le bouton Down du DPad est rel�ch�
	exec function buttonDownDPadRelease()
	{	
	}

	// Fonction appel� lorsque le bouton Left du DPad est appuy�
	exec function buttonLeftDPadPush()
	{
	}
	
	// Fonction appel� lorsque le bouton Left du DPad est rel�ch�
	exec function buttonLeftDPadRelease()
	{	
	}

	// Fonction appel� lorsque le bouton Right du DPad est appuy�
	exec function buttonRightDPadPush()
	{	
	}
	
	// Fonction appel� lorsque le bouton Right du DPad est rel�ch�
	exec function buttonRightDPadRelease()
	{	
	}


Defaultproperties
{
	CameraClass=class'SailGame.SailCamera'

}
