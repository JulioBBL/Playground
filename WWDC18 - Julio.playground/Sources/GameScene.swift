import SpriteKit
import AVFoundation

public class GameScene: SKScene {
    var boat: SKSpriteNode!
    var insideBoat: SKSpriteNode!
    var button: SKSpriteNode!
    var cover: SKSpriteNode!
    var helpPane: SKSpriteNode!
    var slot1: SKSpriteNode!
    var slot2: SKSpriteNode!
    var cloud: SKSpriteNode!
    
    public var nextScene: SKScene!
    public var animals = [AnimalType]()
    public var animalNodes = [AnimalNode]()
    public var boatSize = 2
    
    var bounceIn: SKAction!
    var bounceOut: SKAction!
    
    // arrays to keep track of where the animals are
    var lhsAnimals = [AnimalNode]()
    var rhsAnimals = [AnimalNode]()
    var boatAnimals = [AnimalNode]() {
        didSet {
            for i in 0..<self.boatSize {
                if self.boatAnimals.indices.contains(i) {
                    self.boatSlots[i].texture = SKTexture(imageNamed: "\(self.boatAnimals[i].type.rawValue) Button")
                } else {
                    self.boatSlots[i].texture = SKTexture(imageNamed: "Empty Button")
                }
            }
        }
    }
    var boatSlots = [SKSpriteNode]()
    
    // to keep track of the state of the boat
    var boatState: BoatState = .onTheLeft {
        didSet {
            if self.boatState == .onTheLeft {
                self.button.xScale = 1
            } else if self.boatState == .onTheRight {
                self.button.xScale = -1
            }
        }
    }
    
    // to keep track of the position of stuff
    var lhsIcebergPosition = CGPoint()
    var rhsIcebergPosition = CGPoint()
    
    var won = false
    var soundNode: SKNode!
    
    override public func didMove(to view: SKView) {
        self.boat = self.childNode(withName: "Boat")! as! SKSpriteNode
        self.insideBoat = self.boat.childNode(withName: "Inside Boat")! as! SKSpriteNode
        self.button  = self.childNode(withName: "Cross Button")! as! SKSpriteNode
        self.cover = self.childNode(withName: "Cover")! as! SKSpriteNode
        self.helpPane = self.childNode(withName: "Help Pane")! as! SKSpriteNode
        self.slot1 = self.helpPane.childNode(withName: "Slot1")! as! SKSpriteNode
        self.slot2 = self.helpPane.childNode(withName: "Slot2")! as! SKSpriteNode
        self.cloud = self.helpPane.childNode(withName: "cloud")! as! SKSpriteNode
        
        self.cover.isHidden = true
        self.helpPane.position.y = 800
        
        self.lhsIcebergPosition = self.childNode(withName: "iceberg L")!.position
        self.rhsIcebergPosition = self.childNode(withName: "iceberg R")!.position
        
        //        self.animals = [.bear, .walrus, .fish, .penguin, .seal]
        // create animals from the specifications providade
        self.animalNodes = self.animals.map { (type) -> AnimalNode in
            let animal = AnimalNode(type: type)
            
            animal.startIdle(forever: true)
            self.addChild(animal)
            
            return animal
            }.sorted()
        self.lhsAnimals = animalNodes
        
        // calculate the Y offset for the animal's position
        let dist = Int(AnimalNode.animalSize.height) // distance between animals
        let yOffset = dist/2 * (self.animalNodes.count - 1) // the highest position
        
        // set the position of the animals
        for i in 0..<self.animalNodes.count {
            let y = CGFloat(yOffset) - CGFloat(dist * i) // index * the distance betwwen animals to bring the animal down
            self.animalNodes[i].position = CGPoint(x: self.lhsIcebergPosition.x, y: y)
        }
        
        // calculate the position of the slots on the boat
        let size = self.boatSize
        let slot = self.insideBoat.childNode(withName: "Slot")! as! SKSpriteNode
        if size > 1 {
            let rows = ceil(Double(size)/2)
            self.insideBoat.size = CGSize(width: 200, height: 100 * rows)
            self.insideBoat.position.y = self.insideBoat.position.y + CGFloat((rows - 1) * 50)
            
            for i in 0..<self.boatSize {
                let newSlot = slot.copy() as! SKSpriteNode
                self.boatSlots.append(newSlot)
                self.insideBoat.addChild(newSlot)
                
                if i % 2 == 1 {
                    newSlot.position.x = CGFloat(50)
                } else {
                    newSlot.position.x = CGFloat(-50)
                }
                
                let line = floor(Double(i) / 2)
                newSlot.position.y = CGFloat(50 * ((rows - 1) - (2 * line)))
            }
            slot.isHidden = true
        } else {
            self.boatSlots.append(slot)
        }
        
        
        // start doing stuff
        let movement = SKAction.moveBy(x: CGFloat(0), y: CGFloat(-800), duration: 0.3)
        movement.timingMode = .easeOut
        let bounce = SKAction.moveBy(x: CGFloat(0), y: CGFloat(25), duration: 0.033)
        bounce.timingMode = .easeIn
        
        self.bounceIn = SKAction.sequence([movement, bounce])
        self.bounceOut = self.bounceIn.reversed()
        
        self.boat!.run(SKAction.repeatForever(SKAction(named: "Bob")!))
        self.cloud.run(SKAction.repeatForever(SKAction(named: "Cloud")!))
        
        //DEVELOPMENT STUFF
        let soundNode = SKNode()
        self.scene?.addChild(soundNode)
        soundNode.run(SKAction.repeatForever(SKAction.playSoundFileNamed("Background_Music.wav", waitForCompletion: true)))
    }
    
    func canMoveBoat() -> Bool {
        var boatPilot: Bool
        if self.boatSize < 2 {
            boatPilot = true
        } else {
            boatPilot = !self.boatAnimals.isEmpty
        }
        
        if self.boatState != .travelling && boatPilot {
            switch self.boatState {
            case .onTheLeft:
                if let enemies = AnimalRelationship.testAnimals(self.lhsAnimals) {
                    self.showDenialMessage(enemies)
                    return false
                }
            case .onTheRight:
                if let enemies = AnimalRelationship.testAnimals(self.rhsAnimals) {
                    self.showDenialMessage(enemies)
                    return false
                }
            default:
                print("wait, where is the boat then?")
                return false
            }
            return true
        } else {
            return false
        }
    }
    
    func canMoveToBoat(animal: AnimalNode) -> Bool{
        return ((self.boatState == .onTheLeft && self.lhsAnimals.contains(animal)) || (self.boatState == .onTheRight && self.rhsAnimals.contains(animal))) && self.boatAnimals.count < self.boatSize
    }
    
    func moveToBoat(animal: AnimalNode) {
        switch self.boatState {
        case .onTheLeft:
            self.lhsAnimals = self.lhsAnimals.filter { $0 != animal }
        case .onTheRight:
            self.rhsAnimals = self.rhsAnimals.filter { $0 != animal }
        default:
            print("whuat?")
        }
        
        animal.alpha = 0
        
        self.boatAnimals.append(animal)
        animal.run(SKAction.playSoundFileNamed("Pop_In.wav", waitForCompletion: false))
        
        //TODO: animation of the animal entering the boat
    }
    
    func removeFromBoat(animal: AnimalNode) {
        switch self.boatState {
        case .onTheLeft:
            self.lhsAnimals.append(animal)
            animal.position.x = self.lhsIcebergPosition.x
            animal.xScale = 1
            animal.alpha = 1
        case .onTheRight:
            self.rhsAnimals.append(animal)
            animal.position.x = self.rhsIcebergPosition.x
            animal.xScale = -1
            animal.alpha = 1
        default:
            print("the boat is travelling")
            return
        }
        
        
        self.boatAnimals = self.boatAnimals.filter {$0 != animal}
        animal.run(SKAction.playSoundFileNamed("Pop_Out.wav", waitForCompletion: false))
        
        //TODO: animation of the animal exiting the boat, and move the test so it occurs when the animation ends
        
        if self.hasCompleted() && !self.won {
            self.won = true
            self.view?.presentScene(self.nextScene)
        }
    }
    
    func removeAllAnimalsFromBoat() {
        self.boatAnimals.forEach{ self.removeFromBoat(animal: $0) }
    }
    
    func hasCompleted() -> Bool {
        return self.lhsAnimals.isEmpty && self.rhsAnimals.sorted() == self.animalNodes
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let node = nodes(at: pos).first {
            if let animal = node as? AnimalNode {
                if self.canMoveToBoat(animal: animal) {
                    moveToBoat(animal: animal)
                }
            } else {
                if node.name == "Cross Button" && self.canMoveBoat() {
                    if self.boatState == .onTheLeft {
                        self.boatState = .travelling
                        
                        let action = SKAction.sequence([SKAction(named: "Move right")!,
                                                        SKAction.run({ self.boatState = .onTheRight }),
                                                        SKAction.run { self.removeAllAnimalsFromBoat() }])
                        self.boat?.run(action)
                    } else if self.boatState == .onTheRight {
                        self.boatState = .travelling
                        
                        let action = SKAction.sequence([SKAction(named: "Move left")!,
                                                        SKAction.run({ self.boatState = .onTheLeft }),
                                                        SKAction.run { self.removeAllAnimalsFromBoat() }])
                        self.boat?.run(action)
                    }
                } else if node.name == "Slot" {
                    if let index = self.boatSlots.index(of: node as! SKSpriteNode), index < self.boatAnimals.count{
                        self.removeFromBoat(animal: self.boatAnimals[index])
                    }
                }
            }
        }
    }
    
    func showDenialMessage(_ animals: (AnimalType, AnimalType)) {
        let animal1 = AnimalNode(type: animals.0)
        let animal2 = AnimalNode(type: animals.1)
        
        self.helpPane.addChild(animal1)
        self.helpPane.addChild(animal2)
        
        animal1.position = self.slot1.position
        animal1.size = self.slot1.size
        animal2.position = self.slot2.position
        animal2.size = self.slot2.size
        animal2.xScale = -1
        
        animal1.startIdleAlone(forever: true)
        animal2.startIdleAlone(forever: true)
        
        let movement = SKAction.group([
            SKAction.run({ animal1.startWalking() }),
            SKAction.move(to: animal2.position, duration: 0.6)
            ])
        movement.timingMode = .easeIn
        
        let fight = SKAction.group([
            SKAction.run {
                animal1.run(movement)
            },
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run({ self.cloud.isHidden = false })
                ])
            ])
        
        let action = SKAction.sequence([
            // show cover
            SKAction.run({ self.cover.isHidden = false }),
            // put the pane on the screen
            self.bounceIn,
            // wait a little so the user can see what is happening
            SKAction.wait(forDuration: 1),
            // make the animal move to the other and show the cloud just as it arrives
            fight,
            // wait a little more so the cloud can at least be seen
            SKAction.wait(forDuration: 1),
            // remove the pane from the screen
            self.bounceOut,
            // remove the animals from the pane
            SKAction.run({
                animal1.removeFromParent()
                animal2.removeFromParent()
            }),
            // hide cover and the cloud
            SKAction.run({ self.cover.isHidden = true; self.cloud.isHidden = true })
            ])
        
        self.helpPane.run(action)
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchDown(atPoint: t.location(in: self)) }
    }
    
    override public func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

