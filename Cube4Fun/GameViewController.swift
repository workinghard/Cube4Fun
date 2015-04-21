//
//  GameViewController.swift
//  Cube4Fun
//
//  Created by Nik on 27.03.15.
//  Copyright (c) 2015 DerNik. All rights reserved.
//

import SceneKit
import QuartzCore

/*
var myFrameCount: UInt32 = 1;
var myMaxFrameCount: UInt32 = 1;
var myFrames: NSMutableData = NSMutableData() // == byte[] array
var _emptyAnimation: NSMutableDictionary = ["AnimName": "Animation1", "AnimKey": "1=anim1", "AnimDur": 1, "AnimSpeed": 500, "AnimFrames": 1, "AnimData": myFrames]

let emptyFrame: [Byte] = [
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255,
    255,255,255,255]

let _minSendDelay: NSTimeInterval = 0.200 // 200 milliseconds
let _frameSendDelay: NSTimeInterval = 0.2 // one second
var _playSendDelay: NSTimeInterval = 0.5 // 500 milliseconds as default
*/

var _previousUpdateTime: NSTimeInterval = NSTimeInterval()
var _deltaTime: NSTimeInterval = NSTimeInterval()
var _playAllFrames = false
var _gameView: GameView = GameView();

class GameViewController: NSViewController { // SCNSceneRendererDelegate
    
    @IBOutlet weak var gameView: GameView!

    
    /*
    func renderer(aRenderer: SCNSceneRenderer, updateAtTime time: NSTimeInterval) {
        //sendFrame(time)
        sendFrame(NSDate.timeIntervalSinceReferenceDate())
        //println("This will be called before each frame draw")
    }

    override func viewDidLoad() {
        self.gameView!.delegate = self
        
        super.viewDidLoad()
    }
    */
    

    //func sendFrame() {
    //    sendFrame(NSDate.timeIntervalSinceReferenceDate())
    //}
    
    /*
    func sendFrame(time: NSTimeInterval) {
        //println(time)
        
        if (_previousUpdateTime == 0.0) {
            _previousUpdateTime = time;
        }
        _deltaTime = time - _previousUpdateTime;
        
        //var ms = Int((time % 1) * 1000)
        if ( _playAllFrames ) {
            if ( _deltaTime >= __animations.animationSpeedFloat() ){
                if (__animations.getAnimationFrameID() >= __animations.getAnimationFrameCount()) {
                    self.gameView!.firstButtonPressed()
                }else{
                    self.gameView!.nextButtonPressed()
                }
                CubeNetworkObj.updateFrame(__animations.getAnimDataSelected(), count: UInt32(__animations.getAnimationFrameID()))
                _previousUpdateTime = time;
            }
        }else{
            if ( _deltaTime >= __animations.getMinSendDelay() ) {
                CubeNetworkObj.updateFrame(__animations.getAnimDataSelected(), count: UInt32(__animations.getAnimationFrameID()))
                //println("SendFrame: \(_deltaTime)")
                _previousUpdateTime = time;
            }
        }    
        //CubeNetworkObj.updateFrame(UnsafePointer<UInt8>(myFrames.bytes), count: myFrameCount)
    }

*/
    
    override func awakeFromNib(){

        _gameView = gameView;
        //NSTimer.scheduledTimerWithTimeInterval(_frameSendDelay, invocation: CubeNetworkObj.initObjects(), repeats: true)
//        CubeNetworkObj.initObjects();
        
        // Init first frame
        
//        myFrames = NSMutableData(bytes: emptyFrame, length: 64)
//        myFrameCount = 1
        // Open connection to the LED cube
        let established = CubeNetworkObj.openConnection(__prefData.ipAddr(), port: UInt32(__prefData.portNR()))
        if established {
            println("connection established")
        }else{
            println("connection failed")
        }
        __animations.sendFrame()

        // Fallback timer if nothing render at the moment
    //    NSTimer.scheduledTimerWithTimeInterval(__animations.getMinSendDelay(), target: self, selector: Selector("sendFrame"), userInfo: nil, repeats: true)
        

     
        
        // create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.dae")!
        let scene = PrimitivesScene();
        
        
        // create and add a camera to the scene
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 15
        camera.zNear = 0
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.name = "myCamera"
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        var newAngle = (CGFloat)(20.0)*(CGFloat)(M_PI)/180.0
        //newAngle += currentAngle

//        cameraNode.transform = SCNMatrix4MakeRotation(-0.5, 0, 0, 1)

        cameraNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 1, 0)
        cameraNode.transform = SCNMatrix4MakeRotation(-0.4, 1, 0, 0)
        cameraNode.position = SCNVector3(x: 0, y: 13, z: 30)
        //cameraNode.eulerAngles = SCNVector3(x: 1.0, y: 0.0, z: 0.0)


  /*
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 9
        camera.zNear = 0
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 20)
        cameraNode.camera = camera
        let cameraOrbit = SCNNode()
        cameraOrbit.name = "myCamera"
        cameraOrbit.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
*/

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeDirectional
        lightNode.light!.color = NSColor.grayColor()
        lightNode.position = SCNVector3(x: 20, y: 40, z: 20)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = NSColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
  
        
        // Background image
        scene.background.contents = NSImage(named: "Background.jpg")
        
        
        /*
        // retrieve the ship node
        let ship = scene.rootNode.childNodeWithName("ship", recursively: true)!
        
        // animate the 3d object
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.toValue = NSValue(SCNVector4: SCNVector4(x: CGFloat(0), y: CGFloat(1), z: CGFloat(0), w: CGFloat(M_PI)*2))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT //repeat forever
        ship.addAnimation(animation, forKey: nil)
        */

        scene.paused = false
        
        // set the scene to the view
        self.gameView!.scene = scene
        

        // allows the user to manipulate the camera
        //self.gameView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        //self.gameView!.showsStatistics = true
        
        // configure the view
        self.gameView!.backgroundColor = NSColor.blackColor()
    }

}
