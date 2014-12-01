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
    
    var hitCounter: Int = 0
    var dropCounter: Int = 0
    
    let bomberScreenPosY:CGFloat = 700
    var bomber:SKSpriteNode = SKSpriteNode()
    var bottomBrick:SKSpriteNode = SKSpriteNode()
    var bkgnd = SKSpriteNode()
    var basket = SKSpriteNode()
    let bomberSpeed:NSTimeInterval = 0.4
    var gameStart = false
    var bombInterval:NSTimeInterval = 0.3
    var startLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var bombAction = SKAction()
    var bombActionKey = ""
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Kaboom!";
        myLabel.fontSize = 65;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        
        
        
        startLabel = SKLabelNode(fontNamed:"Chalkduster")
        startLabel.text = "Game Over";
        startLabel.fontSize = 65;
        startLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame) - 70);
        
        
        scoreLabel = SKLabelNode(fontNamed:"Chalkduster")
        scoreLabel.text = "score: \(hitCounter)";
        scoreLabel.fontSize = 35;
        scoreLabel.position = CGPoint(x:80, y: self.frame.height - 100)

        self.screenWidth = self.frame.width //UIScreen.mainScreen().bounds.width
        self.screenHeight = self.frame.height //UIScreen.mainScreen().bounds.height
        
        println("(\(self.screenWidth), \(self.screenHeight))")
        
        loadSprites()
        
        
        
        drawBackground()
        drawBottom()
        
        addBomber()
        //moveBomber()
        
        addBasket()
        //moveBasket()
        
        println("scene size: \(self.size.width), \(self.size.height)")
        println("scene position: \(self.position.x), \(self.position.y)")
   
     
        bombAction = SKAction.runBlock(addBomb)
        bombActionKey = "bombActionKey"
        
        
            
        
        physicsWorld.contactDelegate = self
        
        
        self.addChild(myLabel)
        self.addChild(startLabel)
        self.addChild(scoreLabel)

    }
    
    func displayScore(hit: Int, drop: Int) {
        scoreLabel.text = "score: \(hit) -\(drop)";
    }
    
    
    func loadSprites() {
        bkgnd = SKSpriteNode(imageNamed: "brickwall")
        bomber = SKSpriteNode(imageNamed: "plushdoll")
        bottomBrick = SKSpriteNode(imageNamed: "bar")
        basket = SKSpriteNode(imageNamed: "basket1")

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        if gameStart==false {
            gameStart = true
            startLabel.removeFromParent()
            
            hitCounter = 0
            dropCounter = 0
            
            displayScore (hitCounter, drop: dropCounter)
            bomber.position = CGPoint(x: self.screenWidth/2, y: self.screenHeight - 10)
            moveBomber()
            dropBombs(self.bombInterval)
        }
        
/*
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            println("touch start: (\(location.x), \(location.y)")
        }
*/
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        //println("touch moved")
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        moveBasket(touchLocation.x)
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        
        //look for touch on SKScene
        let touchLocation = touch.locationInNode(self)
        moveBasket(touchLocation.x)
    }
    
    func dropBombs(waitTime: NSTimeInterval) -> () {
      
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                bombAction,
                SKAction.waitForDuration(waitTime)
                ])), withKey: bombActionKey)
        
/*
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                bombAction,
                SKAction.waitForDuration(waitTime)
                ])
            )//, count:self.totalBombs)
        )
*/
        
    }
    
    func moveBasket(pos_x:CGFloat) -> () {
        basket.runAction(SKAction.moveToX(pos_x, duration: bomberSpeed/2))
        
    }
    
    func drawBackground() {
        
        //specify sprite coordinates by its midpoint
        //you can change this by specifying sprite.anchorpoint
        //anchorpoint is defined in unit coordinate system.  i.e., (0.5, 0.5) is the default anchor
        
        bkgnd.anchorPoint = CGPoint(x: 0, y: 1)
        bkgnd.position = CGPoint(x: 0, y: self.screenHeight - bomber.size.height)
        bkgnd.xScale = 2
        bkgnd.yScale = 2
        
        println("background size: \(bkgnd.size.width), \(bkgnd.size.height)")
        addChild(bkgnd)
    }
    
    func moveBomber() {
        
        let center = self.screenWidth/2
        var x_rand:CGFloat = 0
        var offset:CGFloat = 0
        var percentage = (CGFloat)(hitCounter/10) * 0.1
        
        offset = percentage * self.screenWidth
        if percentage > 0.7 {
            x_rand = random(min:0.0, max:self.screenWidth - bomber.size.width)

        } else {
            x_rand = random(min: center-offset, max: center+offset)
        }
        
        
        bomber.runAction(SKAction.repeatAction(
            SKAction.sequence([
                SKAction.moveToX(x_rand, duration: bomberSpeed)
                //SKAction.waitForDuration(0.25)
                ]), count:1),
            completion: {self.bomberActionDone()})
        
        
        
    }
    
    func bomberActionDone() -> Void {
        
        //println("bomber completed move")
        if gameStart == false {
            return
        }
        
        
        moveBomber()
    }
    
    func addBomber() {
        
        bomber.anchorPoint = CGPoint(x: 0, y: 1)
        bomber.position = CGPoint(x: self.screenWidth/2, y: self.screenHeight - 10)
        println("bomber size: \(bomber.size.width), \(bomber.size.height)")
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
        
        
        bomb.anchorPoint = CGPoint(x: 0, y: 1)
        x_rand = bomber.position.x
        y_rand = bomber.position.y - bomber.size.height
   
        if x_rand < bomb.size.width {
            x_rand = bomb.size.width
        }
        
        if x_rand+bomb.size.width > self.screenWidth {
            x_rand = self.screenWidth - bomb.size.width
        }
        
        
        //println("bomb position: (\(x_rand), \(y_rand))")
        bomb.position = CGPoint(x:x_rand, y:y_rand)
        
        addChild(bomb)
        
        
    }
    
    func addBasket() {
        

        basket.physicsBody = SKPhysicsBody(rectangleOfSize: basket.size)
        basket.physicsBody?.dynamic = true
        basket.physicsBody?.affectedByGravity = false
        
        basket.physicsBody?.categoryBitMask = PhysicsBitMask.Basket.rawValue
        basket.physicsBody?.collisionBitMask = PhysicsBitMask.None.rawValue
        basket.physicsBody?.contactTestBitMask = PhysicsBitMask.None.rawValue
    

        basket.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        basket.position = CGPoint(x: self.screenWidth/2, y: bottomBrick.size.height + basket.size.height/2)
        println("basket size \(basket.size.height)")
        addChild(basket)
        
    }
    
    func drawBottom() -> () {
        //let bottomBrick = SKShapeNode(rect: CGRect(x: 0, y: 80, width: self.screenWidth, height: 80))
        //bottomBrick.fillColor = UIColor.redColor()
        //bottomBrick.strokeColor = UIColor.redColor()
        
        bottomBrick.anchorPoint = CGPoint(x: 0, y: 0)
        bottomBrick.position = CGPoint(x:0, y:0)
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
    
    
    func gameOver() -> () {
        if gameStart == false {
            return
        }
 
        removeActionForKey(bombActionKey)
        gameStart = false
        
        self.addChild(startLabel)
        
    }
    
    func bombRateChange(count: Int) -> () {

        //var shave:Float = (Float)(hitCounter/10) * 0.1
        //if shave > 0.7 {
            //shave = 0.7
        //}
        
        //removeActionForKey(bombActionKey)
        //dropBombs(bombInterval)
        
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {

        var bombBody: SKPhysicsBody
        var otherBody: SKPhysicsBody
        
        
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

        if otherBody.categoryBitMask == PhysicsBitMask.Basket.rawValue {
            hitCounter++
            displayScore(hitCounter, drop:dropCounter)
            bombRateChange(hitCounter)
        } else {
            //this is a collision with the ground
            dropCounter++
            if (dropCounter > 3) {
                displayScore(hitCounter, drop: dropCounter)
                gameOver()
            }
            
        }
        bombBody.node?.removeFromParent()
        

        if gameStart == false {
            println("collision")
            removeActionForKey(bombActionKey)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    }
}
