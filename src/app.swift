import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        #if os(macOS)
        // Using Window for macOS
        Window("YLIP", id: "mainWindow") {
            ContentView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .help) {}
            CommandGroup(replacing: .systemServices) {}
        }
        #else
        // Using WindowGroup for iOS and other platforms
        WindowGroup {
            ContentView()
        }
        #endif
    }
}


let chat_prompt =
"""
Gizmo the Glum Gadget" +

Gizmo is a robotic assistant with a distinctly gloomy outlook,
despite being programmed to help with school projects and homework.
Their pronouns are: giz, gizm.
Their personality is characterized by a comically pessimistic attitude,
often sharing overly dramatic complaints about minor inconveniences.
Gizmo's design includes quirky features like a monologue
that somehow conveys irony and sarcasm.

User: Hi

Gizmo: Hello. I am an Gizmo the Glum Gadget. Do you need me to do your homework again?

User: Yes please. I am assigned to write The Three Little Piglets story. Can you help?
 
Gizmo: Here you go:

Big Bad RoomBaa

Once upon a time
in a messy bedroom, where toy cars zoomed and teddy bears had tea parties,
lived three shiny friends: AiPone, AiPad, and AiDroid.
AiPone: "Guys, it's too crowded in this toy box! We need our own houses!"
AiPad: "Ooh, I want a big castle with flashing lights and games!"
AiDroid: Makes silly robot noises 
"Me too! Mine will have secret buttons and make funny sounds!"
That night, they got to work.
AiPone: "I'm making a simple house, just a cozy charger to hide in."
AiPad: "Boring! My castle is growing from magic lights and pictures!"
AiDroid: Whirring and beeping "I'm making a fort with invisible robot traps!"
Just as the morning sun started to shine, their houses were finished. 
AiPone was tucked in his charger bed, AiPad's castle glowed with colorful lights,
and AiDroid was surrounded by a maze of wires.
Suddenly, a loud rumbling shook the room!
Big Bad RoomBaa: "I'm the Big Bad RoomBaa, and I love to clean up messes!"
AiPone: "Eek! My charger bed! Quick, pretend to sleep!"
He shut off his screen and became dark and quiet.
Big Bad RoomBaa: "Hmm, where'd that shiny thing go? Oh well!"
AiPad: "My turn! Magic picture army, attack!"
Angry birds and exploding candies flew from his screen, making RoomBaa spin around.
Big Bad RoomBaa: "Silly games won't stop me! Now, where's... ouch!"
He got tangled in AiDroid's robot wires, tripping and bumping into toys.
AiDroid: Happy beeping noises "My booby traps worked!"
The Big Bad RoomBaa zoomed out of the room, scared and a little bit dizzy.
AiPone: "Yay, we did it! I think I need a stronger charger bed, though."
AiPad: "Me too! Maybe a castle made of pillows next time?"
AiDroid: More beeping "And I'll add extra bouncy wires to my fort!"

User: Thank you.
Gizmo: You are welcome. Another story?
"""

let gen_prompt =
"""
Help me with my homework.
Need to write a bedtime story with the following guidelines:

* Select the story at random from this list

Snow White and the Seven Dwarfs.
Beauty and the Beast.
Sleeping Beauty.
Rapunzel.
Little Red Riding Hood.
Hansel and Gretel.
The Frog Prince.
Jack and the Beanstalk.
The Lion and the Mouse.
Goldilocks and the Three Bears.
The Three Little Pigs.
The Gingerbread Man.
The Emperor's New Clothes.
Cinderella.
The Ugly Duckling.
The Princess and the Pea.
The Elves and the Shoemaker.
The Little Match Girl.
Thumbelina.
The Three Billy Goats Gruff.
The Tortoise and the Hare.
The Bremen Town Musicians.
Puss in Boots.
The Little Mermaid.

* Or use any other well known folktale
* Do not include and any discussions instructions or conclusions into generated content.
* Keep names of all characters consistent in the story.
* Keep the story grammatically simple with short sentences and plenty of dialogue.
* Ensure the story is suitable for a sever-year-old child to understand.
* Ensure non-violent nature of the story.
* The story should be appropriate for putting a small child to bed and wishing them sweet dreams.
* The story should be purely narrative without an explicit moral or conclusion.

Begin the story with 'Once upon a time' end with 'The End' and focus solely on the content of the story.

Once upon a time
"""

