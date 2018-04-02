import SpriteKit

public enum AnimalType: String {
    case bear = "Bear"
    case walrus = "Walrus"
    case fish = "Fish"
    case penguin = "Penguin"
    case seal = "Seal"
}

extension AnimalType {
    public func walkAction() -> SKAction? {
        return SKAction(named: "\(self.rawValue)_Walk")
    }
    
    public func idleAction() -> SKAction? {
        return SKAction(named: "\(self.rawValue)_Idle")
    }
    
    public func idleAlone() -> SKAction? {
        if self == .fish {
            return SKAction(named: "Fish_Idle_Alone")
        } else {
            return SKAction(named: "\(self.rawValue)_Idle")
        }
    }
}

extension AnimalType: Comparable {
    public static func <(lhs: AnimalType, rhs: AnimalType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
