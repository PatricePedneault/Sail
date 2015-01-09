class SailBateau extends Pawn ;

var vector axeXUnitaire;
var vector axeYUnitaire;
var vector axeZUnitaire;

var Robot  robotReference; 

var SailCamera cameraReference;

var SailPoseiBotPawn poseiReference;

var Vector  lastVelocity;

var float   deceleration;

var Rotator lastRotationBateau;

var bool bBlockZVelocity;
var float zVelocity;

var bool bBlockXVelocity;
var float xVelocity;

var bool bBlockYVelocity;
var float yVelocity;

var float angleStock;

var Rotator rotationDeplacement;

var int rotationVitesse;

var AudioComponent SoundBoatMove;
var AudioComponent SoundWavesHitBoat;
var AudioComponent SoundConstant;
var SoundCue SoundFaeScream;

var bool    robotInFall;

var bool boatIsMoving;

var DynamicLightEnvironmentComponent LightEnvironment;

var Vector additionnalForce;

var AnimNodeBlendList waterfallList;

var AnimNodeBlend landToWaterfall;


var SkeletalMeshComponent skeletalMeshFae;

simulated event Tick(float delta) 
{
	super.Tick(delta);
	//AddForce(vect(-1000000,0,0));
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	`log("Init Bateau Anim Tree");
	
	waterfallList = AnimNodeBlendList(Mesh.FindAnimNode('Bateau_Waterfall_list'));

	landToWaterfall = AnimNodeBlend(Mesh.FindAnimNode('Bateau_Land_To_Waterfall'));
	
	`log("Init Bateau Anim Tree Done");

	super.PostInitAnimTree(SkelComp);
	
}

/*function float getWaterfallInTimeLeft()
{
	local float time;
	time = AnimNodeSequence(waterfallList.Children[0].Anim).GetTimeLeft();
	return time;
}*/

function playWaterfallIn()
{
	landToWaterfall.SetBlendTarget(1.0,0.3f);
	waterfallList.SetActiveChild(0,0.0f);
	PlaySound(SoundFaeScream);
}

function playWaterfallMid()
{
	landToWaterfall.SetBlendTarget(1.0,0.1f);
	waterfallList.SetActiveChild(1,0.1f);
}

function playWaterfallOut()
{
	landToWaterfall.SetBlendTarget(1.0,0.3f);
	waterfallList.SetActiveChild(2,0.0f);
	landToWaterfall.SetBlendTarget(0.0,0.1f);
}

simulated event PostBeginPlay()
{
	
	robotInFall = false;
	super.PostBeginPlay();
	boatIsMoving = false;
	SoundWavesHitBoat.Play();
	SoundConstant.Play();
	//Mesh.AttachComponentToSocket(DWD_Spear, Swordhand);
	Mesh.AttachComponentToSocket(skeletalMeshFae,'Fae');
}

function AddForce(Vector force) {
	additionnalForce = force;
	
	//Acceleration += force;
	//`Log(Acceleration);
}


function RemoveAdditionnalForce() {
	additionnalForce = Vect(0.0,0.0,0.0);
}

function UpdateGroundSpeed() {
	local Vector directionP;
	local float angleBetweenToboganAndBoatDirection;

	// Calcul du déplacement du bateau dans les chutes descendantes
	directionP = Vect(00.0, 10.0,0.0) >> rotationDeplacement;
	
	additionnalForce.Z = 0.0;
	directionP.Z = 0.0;

	//DrawDebugLine(Location, Location + directionP*1000, 255,0,0);
	//DrawDebugLine(Location, Location + additionnalForce*1000, 0,255,0);

	if (additionnalForce != Vect(0.0,0.0,0.0)) {
		angleBetweenToboganAndBoatDirection = acos((additionnalForce Dot directionP)/(VSize(additionnalForce)*VSize(directionP)));
		//`log("bbb"@angleBetweenToboganAndBoatDirection);
		GroundSpeed = 765 - angleBetweenToboganAndBoatDirection * (565.0/3.0);
		AccelRate = 765 - angleBetweenToboganAndBoatDirection * (565.0/3.0);
		//`log(angleBetweenToboganAndBoatDirection);
	}
	else {
		GroundSpeed = 400;
		AccelRate = 400.0;
	}
}

// Fonction qui est utilisé pour la gestion des déplacements du bateau
function updateDeplacement(PlayerInput playerInputRecu )
{
	local float angleToGo;
	local vector vectorTestRight;
	local vector vectorTestLeft;
	local vector vectorTestToGo;

	playMovingSound();

	GetAxes(cameraReference.rotatorCamera,axeXUnitaire,axeYUnitaire,axeZUnitaire);	

	// Calcul du déplacement du bateau
	UpdateGroundSpeed();

	Acceleration = additionnalForce + (axeXUnitaire * (playerInputRecu.aForward* 1000) + (axeYUnitaire * (playerInputRecu.aStrafe* 1000)));
	
	// Si le bateau effectu un déplacement (acceleration != 0) alors on met la rotation approprié pour que celui-ci est le nez vers sa direction
	// Sinon on met comme direction du bateau la dernier rotation
	if(Acceleration != vect(0,0,0))
	{	
		angleToGo = getAngle((Rotator(Velocity)).Yaw - 16384);

		vectorTestRight.X   = (15 * (Cos(((angleStock + 10) * pi) / 180))); 
		vectorTestRight.Y   = (15 * (Sin(((angleStock + 10) * pi) / 180)));
		vectorTestRight.Z   = 0;

		vectorTestLeft.X   = (15 * (Cos(((angleStock - 10) * pi) / 180))); 
		vectorTestLeft.Y   = (15 * (Sin(((angleStock - 10) * pi) / 180)));
		vectorTestLeft.Z   = 0;

		vectorTestToGo.X   = (15 * (Cos(((angleToGo) * pi) / 180))); 
		vectorTestToGo.Y   = (15 * (Sin(((angleToGo) * pi) / 180)));
		vectorTestToGo.Z   = 0;
		//`log("Calcul - "@angleToGo - getAngle(lastRotationBateau.Yaw + rotationVitesse));
		if(VSize(vectorTestToGo - vectorTestLeft) >= VSize(vectorTestToGo - vectorTestRight))
		{	
			if((angleToGo > getAngle(lastRotationBateau.Yaw + rotationVitesse))||(abs(angleToGo - getAngle(lastRotationBateau.Yaw + rotationVitesse)) > 180))
			{

				if((angleToGo - getAngle(lastRotationBateau.Yaw + rotationVitesse) > -20) && (angleToGo - getAngle(lastRotationBateau.Yaw + rotationVitesse) < 20))
				{
					rotationDeplacement.Yaw = lastRotationBateau.Yaw + rotationVitesse/4;
				}
				else
				{
					rotationDeplacement.Yaw = lastRotationBateau.Yaw + rotationVitesse;
				}
			}			
		}
		else
		{
			if((angleToGo < getAngle(lastRotationBateau.Yaw - rotationVitesse)) ||(abs(angleToGo - getAngle(lastRotationBateau.Yaw - rotationVitesse)) > 180))
			{
				if((angleToGo - getAngle(lastRotationBateau.Yaw + rotationVitesse) > -20) && (angleToGo - getAngle(lastRotationBateau.Yaw + rotationVitesse) < 20))
				{
					rotationDeplacement.Yaw = lastRotationBateau.Yaw - rotationVitesse/4;	
				}
				else
				{
					rotationDeplacement.Yaw = lastRotationBateau.Yaw - rotationVitesse;	
				}
			}
		}

		angleStock = getAngle(rotationDeplacement.Yaw);

		lastRotationBateau = rotationDeplacement;

		SetRotation(rotationDeplacement);
		
	}
	else
	{
		SetRotation(lastRotationBateau);
	}

	// Si aucun déplacement n'a lieu, alors on prend la dernière Velocity (lastVelocity) comme valeur de Velocity et par la suite on déminu cette valeur
	// Eas in out pour le bateau
	if(Acceleration == vect(0,0,0))
	{
		Velocity.X = lastVelocity.X;
		Velocity.Y = lastVelocity.Y;
		lastVelocity.X = lastVelocity.X / deceleration;	
		lastVelocity.Y = lastVelocity.Y / deceleration;

		
		boatIsMoving = false;
		
	}
	else
	{
		lastVelocity.X = Velocity.X;
		lastVelocity.Y = Velocity.Y;

		boatIsMoving = true;
		
	}

	if(bBlockZVelocity) {
		Velocity.Z = zVelocity;
	}
	
	if(bBlockXVelocity)
	{
		Velocity.X = xVelocity;
	}
	
	if(bBlockYVelocity && bBlockXVelocity)
	{
		Velocity.Y = yVelocity;
	}


	
}

function float getAngle(float valeurRecu)
{
	if((valeurRecu + 16384) > 0)
	{
		return (((valeurRecu + 16384)%65536)*360)/65536;
	}
	else
	{
		return 360 - (((valeurRecu + 16384)%65520)*360)/-65520;
	}
}

// Fonction permettant d'initialiser les références 
function setReference(SailCamera cameraRecu,Robot robotReferenceRecu)
{
	robotReference =  robotReferenceRecu;
	cameraReference = cameraRecu;
}

function setPoseiReference(SailPoseiBotPawn poseiRecu)
{
	poseiReference = poseiRecu;
}

function setEtrangeThing()
{
	cameraReference.resetStartDistCamera();
	cameraReference.setBoolGoEasyDefault(true);
	robotInFall = true;
	
}
function setOutFall()
{
	robotInFall = false;
}

function playMovingSound()
{
	if(boatIsMoving==true  && !SoundBoatMove.IsPlaying())
	{
		SoundBoatMove.FadeIn(1.8, 1.0);
	}
	
	if (boatIsMoving== false  && SoundBoatMove.IsPlaying() && !SoundBoatMove.IsFadingOut())
	
	{
		SoundBoatMove.FadeOut(1.8, 0.0);
	}

}

function TakeFallingDamage(){}

defaultproperties
{
	//0 - 360 to 0 - 65536
   //IsoCamAngle=8192  //35.264 degrees            normalement = 6420             Complétement par dessus =16508
   //CamOffsetDistance= 684 //            normalement 684.0
   Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		//ModShadowFadeoutTime=0.25
		//MinTimeBetweenFullUpdates=0.2
		//AmbientGlow=(R=.01,G=.01,B=.01,A=1)
		//AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
		bIsCharacterLightEnvironment=TRUE
		bSynthesizeSHLight=TRUE
	End Object
	Components.Add(MyLightEnvironment)

    Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
        BlockNonZeroExtent=true
        LightEnvironment=MyLightEnvironment
		PhysicsAsset=PhysicsAsset'SAIL_bateau_pck.PhysicAsset.SAIL_bateau_PA'
		AnimSets(0)=AnimSet'SAIL_bateau_pck.AnimSet.SAIL_Bateau_As'
		AnimTreeTemplate=AnimTree'SAIL_bateau_pck.AnimTree.SAIL_Bateau_At'
		SkeletalMesh=SkeletalMesh'SAIL_bateau_pck.SkeletalMesh.SAIL_Bateau_SK'
		//Materials(0)=MaterialInstanceConstant'SAIL_bateau_pck.Material.SAIL_bateau_MATI'
		bHasPhysicsAssetInstance=true
	End Object

	Begin Object Class=SkeletalMeshComponent Name=FaeSkeletalMesh
		CastShadow=true
		bCastDynamicShadow=true
		bOwnerNoSee=false
		BlockRigidBody=true;
		CollideActors=true;
		BlockZeroExtent=true;
		BlockNonZeroExtent=true
		LightEnvironment=MyLightEnvironment
		AnimSets(0)=AnimSet'SAIL_fae_pck.SAIL_Fae_AS'
		AnimTreeTemplate=AnimTree'SAIL_fae_pck.SAIL_Fae_AT'
		SkeletalMesh=SkeletalMesh'SAIL_fae_pck.SAIL_Fae_SK'
		Scale3D=(X=0.9f,Y=0.9f,Z=0.9f)
	End Object

	skeletalMeshFae = FaeSkeletalMesh
	Components.Add(FaeSkeletalMesh)

	
	Mesh=InitialSkeletalMesh;
	Components.Add(InitialSkeletalMesh);
	CollisionComponent=InitialSkeletalMesh

	CollisionType=COLLIDE_BlockAll
	bCanStepUpOn=false

	Components.Remove(CollisionCylinder)


	// Vitesse d'accélération du bateau
	AccelRate=3200.0
	// Vitesse de décélération du bateau
	deceleration = 1.05
	// Vitesse maximum que le bateau aura
	GroundSpeed=300.0

	zVelocity=0;

	rotationVitesse = 1000

	MaxFallSpeed=0


	//Son du bateau en déplacement

	Begin Object Class=AudioComponent Name=SboatMove
		SoundCue=SoundCue'sail_sounds_pck.Boat_Full_Speed_Cue'
	End Object
	Components.Add(SboatMove)
	SoundBoatMove=SboatMove

	Begin Object Class=AudioComponent Name=SwaveHit
		SoundCue=SoundCue'sail_sounds_pck.Boat_Waves_Cue'
	End Object
	Components.Add(SwaveHit)
	SoundWavesHitBoat=SwaveHit

	Begin Object Class=AudioComponent Name=constantNoise
		SoundCue=SoundCue'sail_sounds_pck.Boat_Constant_Noises_Cue'
	End Object
	Components.Add(constantNoise)
	SoundConstant=constantNoise

	SoundFaeScream=SoundCue'sail_sounds_pck.Fae_Fall_Scream_Cue'
}
