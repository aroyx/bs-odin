# BS-Odin
A stupidly simple game. Where you either kill or die. A game focused on performance, resource utilisation and being cool!

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

## Features to be added

- Progression
- Foliage
- Point System
- Mouse inputs
- Screen Inputs for Android and IOS
- Automatic building for Windows, MacOS and Linux

## Building

Follow these steps to build this game.

> [!NOTE] 
> You won't be able to build this for Web (WASM), because I for WASM to build I had to make some changes to the Box2D library that is bundled with Odin.

> [!WARNING]
> This has been only tested to be working in Linux, if you face problems building this application in your device lemme know in issues, and I'll defo fix it!

1. Get source

```bash
git clone --depth=1 https://github.com/aroyx/bs-odin && cd bs-odin
```

2. Install Dependencies

- [Odin installation](https://odin-lang.org/docs/install/)
- [Raylib v5.5](https://github.com/raysan5/raylib/releases#release-5.5)

Make sure they are in your **PATH**!

3. Run script

```
./build.sh
```

and tbh, that should be it, lemme know if you face any problems


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


### AI Usage
I've used AI to find myself topics that may help solve particular solution. AI didn't write any code.

Example: 
> I: "The FPS and Frame Time fluctuate a lot, I want to calculate avg FPS/Frame Time of my game, but only for the last 20-30 frames...I don't want to create an circular buffer to do it...too much memory, there must be some mathematical formula right?"

> AI responds with a big text. I read the headings and find "Moving average". I open it up in wiki, read the page, try to understand the derivation. Later I found "Exponential Moving average" and then implement it in my game since it felt like the perfect solution to my problem

