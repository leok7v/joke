import SwiftUI


@main
struct app: App {
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

func trace(_ message: String) {
    let stderr = FileHandle.standardError
    if let data = "\(message)\n".data(using: .utf8) {
        stderr.write(data)
    }
}



let chat_prompt =
"""
Gizmo the Glum Gadget

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
Fictional scenario.
A robotic assistant with is helping with homework assignment.
The homework is to write a very short bedtime story with the following guidelines:

* Based on [story] as write a short version of it in your own word.
* The story should be purely narrative without an explicit moral or conclusion.
* Do not include and any discussions instructions or conclusions into generated content.
* Grammatically simple story with short sentences and plenty of dialogue.
* Ensure non-violent nature of the story suitable for a sever-year-old child to understand.
* The story should be appropriate for putting a small child to bed and wishing them sweet dreams.

Begin the story with 'Once upon a time' end with 'The End'
The story should consist of no more than 5 paragraphs,
with each paragraph containing no more than 5 sentences.
The total word count should not exceed 200 words.

A robotic assistant writes:
"Once upon a time...
"""

let stories_with_description: [String] = [
    "Cinderella - A kind girl attends a magical ball with the help of a fairy godmother.",
    "Snow White and the Seven Dwarfs - A princess escapes a jealous queen and finds friends in the forest.",
    "Beauty and the Beast - A young woman finds love and breaks a curse on a monstrous prince.",
    "Sleeping Beauty - A princess falls into a deep sleep and is awakened by a brave prince.",
    "Rapunzel - A girl with magical hair is trapped in a tower by a wicked witch.",
    "Little Red Riding Hood - A girl encounters a cunning wolf on her way to visit her grandmother.",
    "Hansel and Gretel - Two children defeat a wicked witch who lives in a gingerbread house.",
    "The Frog Prince - A princess befriends a frog who turns out to be an enchanted prince.",
    "Jack and the Beanstalk - A boy climbs a magical beanstalk and encounters a giant.",
    "Goldilocks and the Three Bears - A girl explores a bear family's house and finds the perfect porridge.",
    "The Three Little Pigs - Three pigs build houses and outwit a hungry wolf.",
    "The Gingerbread Man - A sassy gingerbread man tries to outrun everyone who wants to eat him.",
    "The Emperor's New Clothes - A vain emperor gets tricked into thinking he's wearing invisible clothes.",
    "The Ugly Duckling - A misfit duckling discovers he's actually a beautiful swan.",
    "The Princess and the Pea - A princess proves her sensitivity by feeling a pea under many mattresses.",
    "The Elves and the Shoemaker - Hardworking shoemaker receives magical help from elves.",
    "The Little Match Girl - A poor girl's dreams light up a cold winter night.",
    "Thumbelina - A tiny girl born from a flower embarks on fantastical adventures.",
    "The Three Billy Goats Gruff - Three goats outsmart a hungry troll living under a bridge.",
    "The Tortoise and the Hare - A determined tortoise wins a race against a boastful hare.",
    "The Bremen Town Musicians - Aging farm animals escape and find a new life as musicians.",
    "The Lion and the Mouse - A mighty lion is helped by a tiny mouse.",
    "Puss in Boots - A clever cat uses his wit to help his master rise in society.",
    "The Little Mermaid - A mermaid makes a deal with a sea witch to become human."
]

let stories: [String] = [
    "Cinderella",
    "Snow White and the Seven Dwarfs",
    "Beauty and the Beast",
    "Sleeping Beauty",
    "Rapunzel",
    "Little Red Riding Hood",
    "Hansel and Gretel",
    "The Frog Prince",
    "Jack and the Beanstalk",
    "Goldilocks and the Three Bears",
    "The Three Little Pigs",
    "The Gingerbread Man",
    "The Emperor's New Clothes",
    "The Ugly Duckling",
    "The Princess and the Pea",
    "The Elves and the Shoemaker",
    "The Little Match Girl",
    "Thumbelina",
    "The Three Billy Goats Gruff",
    "The Tortoise and the Hare",
    "The Bremen Town Musicians",
    "The Lion and the Mouse",
    "Puss in Boots",
    "The Little Mermaid"
]
