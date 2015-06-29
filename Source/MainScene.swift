import Foundation

class Obstacle: CCNode {
    weak var topCarrot: CCNode!
    weak var bottomCarrot: CCNode!
    
    let topCarrotMinimumPositionY : CGFloat = 128
    let bottomCarrotMaximumPositionY : CGFloat = 440
    let carrotDistance : CGFloat = 142
    
    func setupRandomPosition() {
        let randomPrecision: UInt32 = 100
        let random = CGFloat(arc4random_uniform(randomPrecision)) / CGFloat(randomPrecision)
        let range = bottomCarrotMaximumPositionY - carrotDistance - topCarrotMinimumPositionY
        if let topCarrot = topCarrot, let bottomCarrot = bottomCarrot {
            topCarrot.position = ccp(topCarrot.position.x, topCarrotMinimumPositionY + (random * range));
            bottomCarrot.position = ccp(bottomCarrot.position.x, topCarrot.position.y + carrotDistance);
            println("It got here")
        }
    }
    
    
}
class MainScene: CCNode {
    
    weak var hero: CCSprite!
        //creates the hero
    
    weak var gamePhysicsNode: CCPhysicsNode!
        //sets up a variable for things only within the physics node
    
    var sinceTouch : CCTime = 0
        // defines a timer to use to measure time since last screen touch
    
    var scrollSpeed : CGFloat = 80
    
    
    weak var ground1 : CCSprite!
    weak var ground2 : CCSprite!
    var grounds = [CCSprite]()  // initializes an empty array
    
    var obstacles : [CCNode] = []
    let firstObstaclePosition : CGFloat = 280
    let distanceBetweenObstacles : CGFloat = 160
    
    weak var obstaclesLayer : CCNode!
    
    func didLoadFromCCB() {
        //enables touch to be used
        userInteractionEnabled = true
        
        //adds both grounds to the list of grounds
        grounds.append(ground1)
        grounds.append(ground2)
        
        //spawns three objects initially
        for i in 0...2 {
            spawnNewObstacle()
        }

    }
 //   println ("wfh")
    
    func spawnNewObstacle() {
        var prevObstaclePos = firstObstaclePosition
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle // the as treats Obstacle.ccb an instance of the Obstacle class
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition() //called after loading obstacle
        //gamePhysicsNode.addChild(obstacle)
        obstaclesLayer.addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        //gives impulse on touch
        hero.physicsBody.applyImpulse(ccp(0, 400))
        hero.physicsBody.applyAngularImpulse(10000)
        sinceTouch = 0
    }
    override func update(delta: CCTime) {
        //limits velocity
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        //gets time since last touch
        sinceTouch += delta
        // limits the rotation
        hero.rotation = clampf(hero.rotation, -30, 90)
        //checks if rotation is allowed
        if (hero.physicsBody.allowsRotation) {
            //clamps angular velocity if it exceeds value range
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
            //applies new angular velocity
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        //checks if .3 seconds have passed since last touch and applies strong rotation acc if so
        if (sinceTouch > 0.3) {
            let impulse = -18000.0 * delta
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        // updates hero's position
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        
        // moves physics node based on position of hero
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
        
        // loop the ground whenever a ground image was moved entirely outside the screen
        for ground in grounds {
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
        }
        for obstacle in obstacles.reverse() {
            let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(find(obstacles, obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
            }
        }
    }
    
  


}
