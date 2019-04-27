/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return(CGPoint(x: left.x + right.x, y: left.y + right.y))
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return(CGPoint(x: left.x - right.x, y: left.y - right.y))
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return(CGPoint(x: point.x * scalar, y: point.y * scalar))
}
func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return(CGPoint(x: point.x / scalar, y: point.y / scalar))
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat{
    return CGFloat(sqrtf(Float(a)))
  }
  #endif

extension CGPoint {
  func length() -> CGFloat {    //floating point value for graphics
    return sqrt(x*x + y*y)
  }
  func normalized() -> CGPoint {
    return self / length()
  }
  
}

struct PhysicsCategory{
  static let none: UInt32 = 0;
  static let all: UInt32 = UInt32.max;
  static let monster: UInt32 = 0b1;
  static let projectile: UInt32 = 0b10;
  
}

class GameScene: SKScene {
  let player = SKSpriteNode(imageNamed: "player"); //ties the asset to this variable
  let darkman = SKSpriteNode(imageNamed: "DarkMan");
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.white;          //CGPoint is cartesian plain
    player.position = CGPoint(x: 220, y: 8); // spritekit origin bottom right, in UIkit its top right
    addChild(player); // what actually makes it go to screen
    darkman.position = CGPoint(x: 220, y: 650); // spritekit origin bottom right, in UIkit its top right
    addChild(darkman); // what actually makes it go to screen
    
    run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster), SKAction.wait(forDuration: 0.5)])))
    
    physicsWorld.gravity = CGVector(dx: 0, dy: -1.2);
    physicsWorld.contactDelegate = self;  // GameScene self can implement the physics
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf");
    backgroundMusic.autoplayLooped = true;
    addChild(backgroundMusic);
    
  }
  
  
  
  
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min: CGFloat, max: CGFloat)-> CGFloat {
    return random() * (max - min) + min; // create position between bounds
  }
  
  func addMonster() {
    let monster = SKSpriteNode(imageNamed: "monster") //creates monster object
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
    monster.physicsBody?.isDynamic = true; // physics body can be interacted with
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster;
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile;
    monster.physicsBody?.collisionBitMask = PhysicsCategory.projectile;
    monster.physicsBody?.restitution = 0.3
    monster.physicsBody?.friction=0
     //Determine y-axis
   // let actualY = random(min: monster.size.height/2,
              //           max: size.height - monster.size.height / 2); //nodes view ancohed to center
    let actualX = random(min: monster.size.width/2, max: size.width - monster.size.width / 2);
    //position monster off screen along the Y axis
    //monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
    monster.position = CGPoint(x: actualX, y: 999)
    addChild(monster) //actually adds to screen
    darkman.position = CGPoint(x: monster.position.x, y: 550)
    
   // let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
    //let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),duration: TimeInterval(actualDuration))
   // let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.height/2),duration: TimeInterval(actualDuration))
    let actionMoveBoss=SKAction.move(to: CGPoint(x: monster.position.x, y: 550), duration: 0.5)
   // let actionMoveDone = SKAction.removeFromParent();
    
  //  monster.run(SKAction.sequence([actionMove,actionMoveDone]))
    darkman.run(actionMoveBoss)
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else{
      return
    }
    
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    //important section
     let touchLocation = touch.location(in: self);  // moves player along axis don't remove
    player.position = CGPoint(x: touchLocation.x, y: player.position.y);
    //important section
    
    
    let projectile = SKSpriteNode(imageNamed: "projectile");
    projectile.position = player.position;
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true; // physics body can be interacted with
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile;
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster;
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none;
    projectile.physicsBody?.usesPreciseCollisionDetection = true;
    projectile.physicsBody?.restitution = 4.3;
    let offset = touchLocation - projectile.position;
    
    if offset.x < 0 { return }
    addChild(projectile)
    
    let direction = offset.normalized();
    
    let shootAmount = direction * 1000;
    let realDest = shootAmount + projectile.position;
    
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    let actionSpin = SKAction.rotate(byAngle: CGFloat(15), duration: 1.0);
    let actionStar = SKAction.group([actionMove, actionSpin])
    let actionMoveDone = SKAction.removeFromParent();
    projectile.run(SKAction.sequence([actionStar, actionMoveDone]))
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode){
    
    projectile.removeFromParent();
    //monster.removeFromParent();
    
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    }else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)){
      if let monster = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
    
  }
  
}

extension GameScene: SKPhysicsContactDelegate {
  
}

