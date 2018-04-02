import Foundation

public class AnimalRelationship {
    public static var prey: [AnimalType: [AnimalType]] = [.bear: [.walrus],
                                                          .walrus: [.fish],
                                                          .fish: [],
                                                          .penguin: [.fish],
                                                          .seal: [.penguin]]
    
    public static func can(_ animal1: AnimalType, beWith animal2: AnimalType) -> Bool {
        return self.prey[animal1]!.contains(animal2)
    }
    
    public static func testAnimals(_ animals: [AnimalNode]) -> (AnimalType, AnimalType)? {
        for i in 0..<animals.count {
            let animal = animals[i]
            var tmp = animals
            tmp.remove(at: i)
            tmp = tmp.filter { self.can(animal.type, beWith: $0.type) }
            
            if let enemy = tmp.first {
                return (animal.type, enemy.type)
            }
        }
        
        return nil
    }
}
