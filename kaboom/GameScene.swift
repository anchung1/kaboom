//
//  GameScene.swift
//  kaboom
//
//  Created by Anthony Chung on 11/28/14.
//  Copyright (c) 2014 Anthony Chung. All rights reserved.
//

import SpriteKit

enum PhysicsBitMask: UInt32 {
    case None = 0
    case Bomb = 1
    case Bomber = 2
    case Basket = 4
    case Ground = 8
    case All = 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var screenWidth:CGFloat = 0;
    var screenHeight:CGFloat = 0;
    var hitCounter = 0
    let totalBombs = 100
    let bomberScreenPosY:CGFloat = 700
    var bomber:SKSpriteNode = SKSpriteNode()
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Kaboom!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.screenWidth = UIScreen.mainScreen().bounds.width
        self.screenHeight = UIScreen.mainScreen().bounds.height
        
        println("(\(self.screenWidth), \(self.screenHeight))")
        
        drawBottom()

        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addBomb),
                SKAction.waitForDuration(0.25)
                ])
            )//, count:self.totalBombs)
        )

//        addBomb()
        
//        physicsWorld.gravity = CGVectorMake(0, 0)
        
        addBomber()
        moveBomber()
        
        addBasket()
        //moveBasket()
        
        physicsWorld.contactDelegate = self
        self.addChild(myLabel)
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            println("(\(location.x), \(location.y)")
        }

    }
    
    func moveBomber() {
        
        var x_rand = random(min:0.0, max:self.screenWidth-1)
        
        
        bomber.runAction(SKAction.repeatAction(
            SKAction.sequence([
                SKAction.moveToX(x_rand, duration: 0.4)
                //SKAction.waitForDuration(0.25)
                ]), count:1),
            completion: {self.bomberActionDone()})
        
        
    }
    
    func bomberActionDone() -> Void {
        
        //println("bomber completed move")
        moveBomber()
    }
    
    func addBomber() {
        bomber = SKSpriteNode(imageNamed: "plushdoll")
/*
        bomber.physicsBody = SKPhysicsBody(rectangleOfSize: bomber.size)
        bomber.physicsBody?.dynamic = true
        bomber.physicsBody?.affectedByGravity = false
        
        bomber.physicsBody?.categoryBitMask = PhysicsBitMask.Bomber.rawValue
        bomber.physicsBody?.collisionBitMask = PhysicsBitMask.None.rawValue
        bomber.physicsBody?.contactTestBitMask = PhysicsBitMask.None.rawValue
 */
        bomber.position = CGPoint(x: 500, y: bomberScreenPosY)
        addChild(bomber)
        
    }
    
    func addBomb() {
        
        let bomb = SKSpriteNode(imageNamed: "bombs")
        bomb.physicsBody = SKPhysicsBody(rectangleOfSize: bomb.size)
        bomb.physicsBody?.dynamic = true;
        bomb.physicsBody?.affectedByGravity = true
        
        //physics collision note:
        //categoryBitMask defines a body's group
        //collisionBitMask defines which body it can collide with
        //contactTestBitMask is used for collision that requires an event callback
        
        bomb.physicsBody?.categoryBitMask = PhysicsBitMask.Bomb.rawValue
        bomb.physicsBody?.collisionBitMask = PhysicsBitMask.Ground.rawValue
        bomb.physicsBody?.contactTestBitMask = PhysicsBitMask.Basket.rawValue | PhysicsBitMask.Ground.rawValue
        bomb.physicsBody?.usesPreciseCollisionDetection = false
        
        var x_rand = random(min:0.0, max:self.screenWidth-1)
        var y_rand = random(min:0.0, max: self.screenHeight/4)
        
        x_rand = bomber.position.x
        y_rand = bomber.position.y - bomber.size.height
        //y_rand = self.screenHeight - y_rand
        //y_rand = 700

        if x_rand < bomb.size.width {
            x_rand = bomb.size.width
        }
        
        if x_rand+bomb.size.width > self.screenWidth {
            x_rand = self.screenWidth - bomb.size.width
        }
        
        
        //println("bomb position: (\(x_rand), \(y_rand))")
        bomb.position = CGPoint(x:x_rand, y:y_rand)
        
        addChild(bomb)
/*
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        let actionMove = SKAction.moveTo(CGPoint(x: x_rand, y: 0), duration:
            NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        bomb.runAction(SKAction.sequence([actionMove, actionMoveDone]))
*/
        
        
    }
    
    func addBasket() {
        let basket = SKSpriteNode(imageNamed: "basket1")

        basket.physicsBody = SKPhysicsBody(rectangleOfSize: basket.size)
        basket.physicsBody?.dynamic = true
        basket.physicsBody?.affectedByGravity = false
        
        basket.physicsBody?.categoryBitMask = PhysicsBitMask.Basket.rawValue
        basket.physicsBody?.collisionBitMask = PhysicsBitMask.None.rawValue
        basket.physicsBody?.contactTestBitMask = PhysicsBitMask.None.rawValue
    

        basket.position = CGPoint(x: 500, y: basket.size.height)
        println("basket size \(basket.size.height)")
        addChild(basket)
        
    }
    
    func drawBottom() -> () {
        //let bottomBrick = SKShapeNode(rect: CGRect(x: 0, y: 80, width: self.screenWidth, height: 80))
        //bottomBrick.fillColor = UIColor.redColor()
        //bottomBrick.strokeColor = UIColor.redColor()
        let bottomBrick = SKSpriteNode(imageNamed: "bar")
        bottomBrick.position = CGPoint(x:0, y:40)
        bottomBrick.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2048, height: 20))
        bottomBrick.physicsBody?.dynamic = false
        bottomBrick.physicsBody?.affectedByGravity = false
        bottomBrick.physicsBody?.allowsRotation = false
        
        bottomBrick.physicsBody?.categoryBitMask = PhysicsBitMask.Ground.rawValue
        bottomBrick.physicsBody?.collisionBitMask = PhysicsBitMask.Bomb.rawValue
        bottomBrick.physicsBody?.contactTestBitMask = PhysicsBitMask.Bomb.rawValue

        
        addChild(bottomBrick)
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xffffffff)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {

        var bombBody: SKPhysicsBody
        var otherBody: SKPhysicsBody
        
        hitCounter++
        //println("\(hitCounter)/\(totalBombs)")
        
        if contact.bodyA.categoryBitMask == PhysicsBitMask.Bomb.rawValue {
            bombBody = contact.bodyA
            otherBody = contact.bodyB
        } else if contact.bodyB.categoryBitMask == PhysicsBitMask.Bomb.rawValue {
            bombBody = contact.bodyB
            otherBody = contact.bodyA
        } else {
            //bail if bomb is not involved
            return
        }

/*
        if secondBody.categoryBitMask != PhysicsBitMask.Ground.rawValue {
            return
        }
*/
//        println("Yes")
        if otherBody.categoryBitMask == PhysicsBitMask.Basket.rawValue {
            hitCounter++
            println("caught: \(hitCounter)")
        }
        bombBody.node?.removeFromParent()

    }
    
    func didEndContact(contact: SKPhysicsContact) {
        //println("end contact")
/*
        var bombBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == PhysicsBitMask.Bomb.rawValue {
            bombBody = contact.bodyA
        } else {
            bombBody = contact.bodyB
        }
        
        bombBody.node?.removeFromParent()
*/
    }
}
