# BS-Odin
A stupidly simple game. Where you either kill or die. A game focused on performance, resource utilisation and being cool!

This game was made during the [Horizons](https://horizons.hackclub.com/) event by [Hackclub](https://hackclub.com). If you are 18 or under, you have join hackclub and have fun!!!!!!!

<img width="960" height="540" alt="Frame 1" src="https://github.com/user-attachments/assets/0254c3e5-eae3-4d10-9979-c4f6b1c8fae4" />

https://github.com/user-attachments/assets/e6a52292-9994-4728-8318-c3a1fb2e6908

## Controls
- `C` to sprint
- `X` to attack
- `WASD or UP/Down/Left/Right`  to move
- Mouse to navigate around

## Journal
The entire process of making this game has been journal-ed in [JOURNAL.md](https://github.com/aroyx/bs-odin/blob/main/JOURNAL.md), all the resources used to make this game has been documented in [ATTRIBUTION.md](https://github.com/aroyx/bs-odin/blob/main/ATTRIBUTION.md) 

## Features Added

- Terrain Generation
    - Terrain Rendering
    - Marching Squares
    - Linear Interpolation
    - Chunking
- Character
    - Keyboard inputs
    - Animations
    - Customisation
- Enemies
    - Randomly generate their skin
    - Enemy AI
- Performant (The desktop version always stays under 5ms in a pretty washed laptop)
- Resource efficient (Under 120mb ram usage)
- Foliage
- Touch Screen Inputs for Android and IOS (Multi Touch doesn't work)
- Automatic building for MacOS, Linux and ~~Windows~~

## Features to be added
- Progression
- Modifiers related to the weapons, and other wardrobe
- Persistent Foliage removal
- Slide
- Arrows (ARCHER enemies!!!)
- Bombs - high priority when the game is stable

## Running The Game

The game works perfectly fine in the Web for Desktop devices and is hosted [here](bs-odin.onkush.dev). I also have added smart phone support, but multi-touch doesn't work yet. So you won't be able to run and atack at the same time. You have to stop before attacking. Also the terrain shakes in weaker Android phones (I have no idea in the entire world why).

If you are from Linux or MacOS you can also download the auto compiled binaries from releases section. Unzip the archive and run the binary.

Odin tries its best to statically link all the files, still please open an issue if you get an error like this:
```
error while loading shared libraries...
```

## Building

Follow these steps to build this game. On Linux or MacOS. I am not a Windows user and such I do not know how things are there, I tried to build it in Windows but with no avail. Feel free to contribute windows instructions if you think you know about it.

> [!NOTE] 
> You won't be able to build this for Web (WASM), because I for WASM to build I had to make some changes to the Box2D library that is bundled with Odin.

> [!WARNING]
> This has been only tested to be working in Linux, if you face problems building this application in your device lemme know in issues, and I'll defo fix it!

1. Get source

```bash
git clone --depth=1 https://github.com/aroyx/bs-odin && cd bs-odin
```

2. Install Dependencies

- [Odin vdev-2026-05 installation](https://github.com/odin-lang/Odin/releases/tag/dev-2026-05), [Odin Install Help](https://odin-lang.org/docs/install/)
- [Raylib v5.5](https://github.com/raysan5/raylib/releases#release-5.5)
- [Python 3](https://www.python.org/downloads/) - Required for imgui bindings

Make sure they are in your **PATH**!

3. Build Dependency (ImGui & box2d)

```bash
cd thirdparty/imgui/ && python3 build.py
sh $(odin root)/vendor/box2d/build_box2d.sh
```

4. Build Game

```bash
./build.sh
```

and tbh, that should be it, lemme know if you face any problems

## Known Issues
1. Terrain (not camera) shakes when moving in some Android devices (specifically on slower devices) on Web Build
2. Multi-Touch doesn't work in WASM (Library issue, I am pretty sure I am doing everything alr, I spent like more 3hrs trying to fix this on 2nd Aug)
3. In WASM the audio doesn't start until you press the screen once. (This is a wasm limitation can't do anything)

## Libraries used
- Odin Core Library (`linalg`, `math`, `fmt`, etc)
- Odin Vendor Libraries
    - [Raylib](https://github.com/raysan5/raylib) [Zlib]
    - [Box2D](https://github.com/erincatto/box2d/) [MIT]
- Thirdparty Libraries
    - [Tracy](https://github.com/wolfpld/tracy) [BSD]
        - Modified [Bindings](https://github.com/oskarnp/odin-tracy) [BSD]
    - [ImGui](https://github.com/ocornut/imgui) [MIT]
        - Modified [Bindings](https://gitlab.com/L-4/odin-imgui) [MIT]
    - [orui](https://github.com/andzdroid/orui)
        - This has been modified to work under WASM, ie I just changed the Virtual mem Arena Allocator to mem Arena Allocator. I've opened a pull request. Hopefully they accept :pray:

## Development

All work is done in main branch but I will move work to another branch till the project isn't reviewed in horizons.

## LICENSE

The entire repos is under the `MIT` license, excluding the `res` directory. See ATTRIBUTION.md if you would like to use the assets used in this game. All the assets are free but most of them can't be redistributed.

pls don't come after me if you use my code and it blows up your entire tech stack

### AI Usage
I've used AI to find myself topics that may help solve particular solution. AI did write some code and all of that is documented below.

One Example: 
> I: "The FPS and Frame Time fluctuate a lot, I want to calculate avg FPS/Frame Time of my game, but only for the last 20-30 frames...I don't want to create an circular buffer to do it...too much memory, there must be some mathematical formula right?"

> AI responds with a big text. I read the headings and find "Moving average". I open it up in wiki, read the page, try to understand the derivation. Later I found "Exponential Moving average" and then implement it in my game since it felt like the perfect solution to my problem

All AI usage:
1. I generated the islands, but I required some way to prevent the user from going into the water. After long battle with "idk why this won't work". I gave up and straight up copied the code from AI. [code](https://github.com/aroyx/bs-odin/blob/21f2515877c875cf0531055e2a7e51a06eabe9b7/src/physics/gen_islands.odin#L73-L147)
2. I was generating foliage on the fly when a chunk is visible. But due to that, if a player left the chunk and re-enter-ed it all the foliage would be in a totally new positions. So AI helped me with this deterministic randomness. [code](https://github.com/aroyx/bs-odin/blob/65f8b387a26fbff4dad00f925f302c24942da3d9/src/playing/foliage.odin#L104-L111)
3. I required a way to transform(pos, angle, scale, etc) children of a bone for my animations. This required math that was just not clicking my brain. I used AI to generate the function that combines the transform respecting the parents transform. [code](https://github.com/aroyx/bs-odin/blob/069fb1487444fde81edd05683fd5e0fb25693918/src/animations/engine.odin#L119-L134)
4. AI also helped me with the state machine of Player. I had instructed it to not change the logic. Just make the code more readable and mantainable. It did that and later I worked on it later and slowly introduced more features to it. [code](https://github.com/aroyx/bs-odin/blob/15115510f2f49299d05b24fd576bbc303c84b5f5/src/playing/player.odin#L26)
5. Other than those, I sometimes used AI to find answers to some questions like "is my game fully statically linked", "how do I publish my wasm game built using odin and raylib in my website that uses cloudflare?".
6. I also asked it questions to some problems but it's answers didn't satisfy my needs/my game architecture so I never used its outputted code. Example: "audio delay in WASM Raylib how to fix", "multi-touch not working in wasm raylib, src/playing/controls.odin: <insert file contents>"

**AI has not written a single word in this readme or any other markdown files in this repo.** The journal is very personal and written to the best of my capabilities.
In my game of about 7k lines as of writing, I'd doubt AI wrote any more than 300 lines.
