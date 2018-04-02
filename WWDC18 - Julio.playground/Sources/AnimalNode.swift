import SpriteKit

public class AnimalNode: SKSpriteNode {
    public static let animalSize: CGSize = CGSize(width: 150, height: 150)
    
    public var type: AnimalType
    
    public init(type: AnimalType) {
        self.type = type
        
        let texture = SKTexture(imageNamed: "\(self.type.rawValue)_Standard")
        
        super.init(texture: texture, color: UIColor.black, size: AnimalNode.animalSize)
        self.name = self.type.rawValue
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startWalking(forever: Bool = false) {
        if var action = self.type.walkAction() {
            if forever {
                action = SKAction.repeatForever(action)
            }
            
            self.run(action)
        }
    }
    
    public func startIdle(forever: Bool = false) {
        if var action = self.type.idleAction() {
            if forever {
                action = SKAction.repeatForever(action)
            }
            
            self.run(action)
        }
    }
    
    public func startIdleAlone(forever: Bool = false) {
        if var action = self.type.idleAlone() {
            if forever {
                action = SKAction.repeatForever(action)
            }
            
            self.run(action)
        }
    }
    
    public func stopAnimating() {
        self.removeAllActions()
    }
}

extension AnimalNode: Comparable {
    public static func <(lhs: AnimalNode, rhs: AnimalNode) -> Bool {
        return lhs.type < rhs.type
    }
}
