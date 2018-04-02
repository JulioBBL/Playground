/*:
 # Polar Crossing
 
 Hey, welcome to my playground, here you will find a simple game of logic built with SpriteKit.
 
 The animals are on an iceberg that is melting due to climate change and they need your help. Since swimming is not an option, you need to help them cross the gap between the icebergs on the boat
 
 But there are some catches:
  1. You cannot leave on the iceberg an animal that fights another, that means that once you tell the boat to cross, the animals will fight, you can't let that happen.
  2. There should be at least one animal in the boat for it to cross, unless it has only one seat, in this case the boat can cross ampty.
  3. Animals only fight when the boat leaves.
  4. Once in the boat, the animals will not fight.
 
 ## This is how the animals interact
![Depiction of the food chain, Bear eats Walrus, Walrus eats the Fish, Fish is eaten by the Penguin and the Penguin is eaten by the Seal](FoodChain.png)
 This means that a animal will fight the other animal that the red arrow poitns, if there is no arrow between two animals, they can be toghether. In other words, the Bear will fight the Walrus, the Walrus will fight the Fish and so on. The Bear will **not** fight the Penguin or the other animals, his grudge is only with the Walrus
 
 The animals will fight only on the iceberg, you can put two enemy animals on the boat without any problem.
 
 ## On a more serious note
 Climate change is a real problem, that affects us all. If we do not take action, we may live a day in which we might not have the pleasure of wondering about which animals will attack each other, because they might not be around anymore.
 
 ## Are you ready to play?
 Here you can choose which animals are in the game and how many animals the boat can carry at once.
 
 Bare in mind that some animal combination will need a bigger boat to make the game solvable. If you program a boat too big, the game will resize the boat to the max amount of animals. And you should have at least one animal, so the game will fix that too.

 */

//#-hidden-code
import PlaygroundSupport
import SpriteKit

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))

if let scene = GameScene(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFit
    
    var boatSize = -1
    var animals: [AnimalType] = []
//#-end-hidden-code
    
    boatSize = /*#-editable-code Number of animals that the boat can carry*/2/*#-end-editable-code*/
    animals = /*#-editable-code Animals in the game*/[.bear, .walrus, .fish, .penguin, .seal]/*#-end-editable-code*/

//#-hidden-code
    if boatSize < 1 {
        boatSize = 1
    } else if boatSize > animals.count {
        boatSize = animals.count
    }
    if animals == [] {
        animals = [.bear, .walrus, .fish]
    }
    
    scene.boatSize = boatSize
    scene.animals = animals
    
    if let endScene = SKScene(fileNamed: "EndScene") {
        endScene.scaleMode = .aspectFit
        
        scene.nextScene = endScene
    }
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
//#-end-hidden-code

/*:
 Combinations guaranteed to be fun are:
 * 1 single space in the boat. A Bear, a Walrus and a Fish for animals.
 * 2 seats, Bear, Walrus, Fish, Penguin and the Seal
 */
