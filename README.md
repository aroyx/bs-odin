# BS-Odin
A stupidly simple game. Where you either kill or die. A game focused on performance, resource utilisation and being cool!

<img width="960" height="540" alt="Frame 1" src="https://github.com/user-attachments/assets/0254c3e5-eae3-4d10-9979-c4f6b1c8fae4" />

## Features Added

- Terrain Generation
    - Terrain Rendering
    - Marching Squares
    - Linear Interpolation
    - Chunking
- Character
    - Keyboard inputs
- Animations
- Character Selector
- Enemies
    - Randomly generate their skin
    - Enemy AI
- Performant
- Resource efficient
- Foliage
- Mouse inputs
- Point System
- Screen Inputs for Android and IOS
- Automatic building for MacOS, Linux and ~~Windows~~

## Features to be added
- Progression
- Modifiers related to the weapons, and other wardrobe
- Persistent Foliage removal
- Slide
- Arrows
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

## LICENSE

The entire repos is under the `MIT` license, excluding the `res` directory. See ATTRIBUTION.md if you would like to use the assets used in this game. All the assets are free but most of them can't be redistributed.

pls don't come after me if you use my code and it blows up your entire tech stack

### AI Usage
I've used AI to find myself topics that may help solve particular solution. AI did write some code. Another AI_USAGE.md will drop soon to disclose all AI usage

One Example: 
> I: "The FPS and Frame Time fluctuate a lot, I want to calculate avg FPS/Frame Time of my game, but only for the last 20-30 frames...I don't want to create an circular buffer to do it...too much memory, there must be some mathematical formula right?"

> AI responds with a big text. I read the headings and find "Moving average". I open it up in wiki, read the page, try to understand the derivation. Later I found "Exponential Moving average" and then implement it in my game since it felt like the perfect solution to my problem

