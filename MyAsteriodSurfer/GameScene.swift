//
//  GameScene.swift
//  MyAsteriodSurfer
//
//  Created by Bobby Bah on 7/6/19.
//  Copyright © 2019 Bobby Bah. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    
    // Extensions
    var backgroundMusic: SKAudioNode! //Background Music
    var logo: SKSpriteNode! // Starting Logo
    
    // Part 5 - Setting up the score
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    // Part 7 - Keep track of time since last score updated
    var lastScoreUpdateTime: TimeInterval = 0.0
    
    // Part 8 - Create a boolean property named isPlaying
    // to keep track of whether or not we are playing.
    var isPlaying: Bool = false
    
    override func didMove(to view: SKView) {
        createPlayer()
        createBackground()
        createGround()
        //Part 8 - remove startRocks()
        createScore()
        createLogo() //Extension - Adding Logo
        // Part 6 - Setting the gravity for the physics world and make the GameScene the contact delegate.
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -3.0)
        physicsWorld.contactDelegate = self
        // Extension - Background Music
        if let musicURL = Bundle.main.url(forResource: "backgroundmusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        } else {
            print("could not load file")
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Part 8 - updated to control actions based on whether game play has started or not.
        if isPlaying == false {
            // Extension - Adding Logo
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let sequence = SKAction.sequence([fadeOut, remove, wait])
            logo.run(sequence)
            
            startRocks()
            isPlaying = true
            player.physicsBody?.isDynamic = true
            
        } else {
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
        }
    }
    // Part 7 - Handling collisions
    func didBegin(_ contact: SKPhysicsContact) {
        // Explosion Extension
        let explosionTexture = SKTexture(imageNamed: "explosion")
        let explosion = SKSpriteNode(texture: explosionTexture)
        explosion.position = player.position
        addChild(explosion)
        let sound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
        run(sound)
        player.removeFromParent()
        speed = 0
        // Part 8 - Change isPlaying back to false because the game
        // is over and we need to call restartGame.
        isPlaying = false
        restartGame()
    }
    
    // Part 7 & 8 - Update method
    override func update(_ currentTime: TimeInterval) {
        if isPlaying == true {
            updateScore(withCurrentTime: currentTime)
        }
    }
    
    // Part 2 - Create the Player Sprite
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "dog-walking0")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        player.position = CGPoint(x: frame.width/6, y: frame.height*0.75)
        addChild(player)
        
        // Part 6 - Add physics and detect collisions/contact for the player sprite
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size())
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        // Part 8 - Change isDynamic from true to false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.collisionBitMask = 0
        
        //Setup the animation of the sprite so it looks like it's running
        let frame2 = SKTexture(imageNamed: "dog-walking1")
        let frame3 = SKTexture(imageNamed: "dog-walking2")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.1)
        let runForever = SKAction.repeatForever((animation))
        
        //Run the SKActions on the player sprite
        player.run(runForever)
    }
    
    // Part 3 - Create the Background Method
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "space_background2")
        
        for i in 0...1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: (backgroundTexture.size().width*CGFloat(i))-CGFloat(1*i), y:0)
            addChild(background)
            
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            background.run(moveForever)
        }
    }
    
    // Part 3 - Create the Ground Method
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0...1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width/2.0+(groundTexture.size().width*CGFloat(i))), y: groundTexture.size().height/2)
            
            // Part 6 - Creating PhysicsBody for ground
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            ground.physicsBody?.isDynamic = false
            
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            ground.run(moveForever)
        }
    }
    
    // Part 4 - Create the Rocks Method.
    func createRocks() {
        let rockTexture = SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        // Part 6 add physics body
        topRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        topRock.physicsBody?.isDynamic = false
        topRock.zPosition = -20
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        // Part 6 add physics body
        bottomRock.physicsBody = SKPhysicsBody(texture: rockTexture, size: rockTexture.size())
        bottomRock.physicsBody?.isDynamic = false
        bottomRock.zPosition = -20
        
        addChild(topRock)
        addChild(bottomRock)
        
        let xPosition = frame.width+topRock.frame.width
        let max = CGFloat(frame.height/3)
        let yPosition = CGFloat.random(in: -50...max)
        let rockDistance: CGFloat = 70
        
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height*1.5 + rockDistance)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition)
        
        let endPosition = frame.width + (topRock.frame.width*2)
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
    }
    
    
    // Part 4 - Create the startRocks method
    func startRocks() {
        let create = SKAction.run { [unowned self] in
            self.createRocks()
        }
        
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create,wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    // Part 5 - Create the createScore Method
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.white
        
        addChild(scoreLabel)
    }
    // Part 7 - Update the Score
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        let elapsedTime = currentTime - lastScoreUpdateTime
        if elapsedTime > 1.0 {
            score += 1
            lastScoreUpdateTime = currentTime
        }
    }
    
    // Part 8 - Restarting the Game
    func restartGame() {
        let scene = GameScene(fileNamed: "GameScene")!
        let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 2)
        self.view?.presentScene(scene, transition: transition)
    }
    
    // Extension - Creating Starting Logo
    func createLogo() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x:frame.midX, y: frame.midY)
        addChild(logo)
    }
}
