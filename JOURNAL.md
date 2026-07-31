---
title: "BS-Odin"
author: "Ankush Roy"
desc: BS-Odin is a multiplayer game in the making using Odin language. This is the first devlog of it where major work has been done.
start-date: "2026-05-28"
---

# Devlog #1


|                |                 |
| -------------- | --------------- |
| Time           | 18h 17m 21s     |
| Total Time     | 18h 17m 21s     |
| Date           | 19th June 2026  |


Multiplayer setup done! Server and client work flawlessly!

I spent a night and a morning to write this first devlog, I am spent...and no AI wasn't at all used to write this up

## First Day 
> [#86f274e](https://github.com/aroyx/bs-odin/commit/86f274e961158b66afa1f7e153f3ae916c5b5730) -- these are the commits for this day

Now the first day, I already had a working window. I was using `SDL` library for window opening...but it had a problem, over all my desktop environments the opening of the window caused a lot of jitter and glitch effect...I googled a bit and found out that a simple flag fixes it! `SDL` stops the compositer running for performance reasons, which caused the problems.

```odin
sdl3.SetHint(sdl3.HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR, "0")
```


## Day 2 
> [#99546c](https://github.com/aroyx/bs-odin/commit/99546cf82264fbc19097c222003e6819bfaa2495), [#cfe70b](https://github.com/aroyx/bs-odin/commit/cfe70b28d13581f07646a4ff4706fc711265f07a)

This is my first time doing any **networking**, so I do not know where to go, neither do I know how to start.

I spent the whole day making everything from **Window management, networking, rendering and some state management**. I decided that I will have different directories for both the `client` and `server`. But will have a `common` dir for the *common* data that will be passed b/w the two.

A lot of work was done today, a lot of googling and a lot of copy-pasting. The end result was surprisingly very satisfactory!

The `enet` library is very easy to use. But I had one problem that I unable to overcome - **identifying** and **differentiating** the different `packets` sent over the network. I had to ask AI for some help in this regarding. The answer was very simple! I just have a single `enum` in the top of the packet and check it to match my required one!


```odin
PacketType :: enum u8 {
	NEW_JOIN,
	PLAYER_INPUT,
	SERVER_OUTPUT,
}

PlayerInput :: struct {
	type:   PacketType, // this is always PacketType.PLAYER_INPUT
	x_axis: f32,
	y_axis: f32,
}

ServerOutput :: struct {
    type: PacketType, // this is always PacketType.SERVER_OUTPUT

    player_count: u8,
	states: [MAX_PLAYERS]PlayerState,
}
```

https://github.com/user-attachments/assets/54dfcdc9-ac1d-4c93-93ff-5dcf3223ebba

### Day 3
> [#2935e7](https://github.com/aroyx/bs-odin/commit/2935e735b4397a11322ccf060dfa4fe42450d206)

Today I implemented text drawing, it was really simple with `SDL_ttf3`, but still a tedious job to do. Not fun. btw, I decided to use **Supercell**'s font cause I like that font!

I made different **states of screens** to! This is just a placeholder for something great! Right now for each state it shows different colours and some text centered. I also have a permanent fps shower in the top left of the screen.


Currently the frame is capped at **60fps** but the fps text fluctuates a lot. I have to deal with this later!


I also took some time to **make the code more modular**. I like to keep things separate.

https://github.com/user-attachments/assets/244b2fb0-58e4-49fc-b253-8ef9c67d65e6

### Day 4
> [#ad60de](https://github.com/aroyx/bs-odin/commit/ad60deeb17dcfe272767b30238213f7412b1cb67)

Today was a light day, nothing special, I just **fixed the fluctuation of the FPS** using [exponential moving avg](https://en.wikipedia.org/wiki/Exponential_smoothing). While researching for this I also found out about **cumulative moving average** with which we can calculate avg without needing to store any of the previous data. We only need the new data and the calculated avg from the previous frame! (This will definitely come in handy some day)

In the mean time(pun intended), I also **setup a frame time** below the fps, because frame time is much more easier metric to measure performance of a program than fps is. 

https://github.com/user-attachments/assets/aa2887aa-8a08-4874-b171-42d9625f5d06

### Day 5 
> [#38c73a](https://github.com/aroyx/bs-odin/commit/38c73a735f8ccf346b57e5763a3ea794b1d13041), [#2848b0](https://github.com/aroyx/bs-odin/commit/2848b0ea4bfe52885eca7ca659a14adc64189324)


Today was also a peaceful day I **implemented [Tracy](https://github.com/wolfpld/tracy)** support for my game! This is very crutial for performance. Odin didn't have official bindings for this library. So I forked one un-official bindings that wasn't updated for more than 2 years iirc and made it work with the latest Tracy!

<img src="https://cdn.hackclub.com/019ede5f-5f2f-796e-9b29-89eacc5316ec/screenshot_20260619_084352.png" alt="screenshot of my application workign with tracy profiler" width="100%"/>

### Day 6
> [#30e975](https://github.com/aroyx/bs-odin/commit/30e975d6a75e510a4871e099955a2247789bb9c9)

Today I spent most of the day trying to optimize the text generation and rendering. I saved a total of *2 micro seconds*! I've made a [blog](https://home.onkush.dev/blog/posts/FailedOptimisation) discussing this more.


### Day 7 
> [#b3ae5c](https://github.com/aroyx/bs-odin/commit/b3ae5cebae90c1fa5b97e7d4c65df569a2270b02), [#53ddbf](https://github.com/aroyx/bs-odin/commit/53ddbfaced2f311ab2401ac049869948f5745e77), [#41a7f0](https://github.com/aroyx/bs-odin/commit/41a7f09126205756f0a5209a574fcce75bedaa3a)


Up until now I was using different scripts (`hmh.sh` and `hmh_server.sh`) for building the client and server. Today I decided to change that because editing both the scripts individually was very tiring and error prone. I decided to merge the two scripts into `build.sh` and build server or client based on the arguments passed.

I also spent some time **abstracting away the networking library (ENet)** so that I can always swap with other networking library if I needed to and I think this was the most stupid and useless thing I ever did in this project, it was really not required.

### Day 8 
> [3ac356](https://github.com/aroyx/bs-odin/commit/3ac3567f0215e2e5057fe606107e1b24518cdd0e)


Today I was monitoring the ram and cpu usage of my server. I found that when I run the server the ram **usage got up by 400-500mb** ram! I was devastated! But that wasn't my server that was using ram!


It was the **odin compiler** that was holding my ram hostage! I asked in the Odin discord if this is a bug, they kindly explained that odin compiler does that so that when a programme exits successfully it deletes the binary created!


So now I no longer use `odin run` command in my build script. Rather I build the binary usign `odin build` and run the binary from the script itself. That way my server only uses **1-2mb** ram :)


This is great! I slept happy today.

### Day 9
> [#4c5cb1](https://github.com/aroyx/bs-odin/commit/4c5cb1d1e1e81dde23e5ca216221676fc172304e), [#076c60](https://github.com/aroyx/bs-odin/commit/076c60466a5a837f9762cbedc95cb3cb044e6442)


**I spent the whole day trying to connect my server over the internet using Hackclub's #nest facilities!** But alas! I still do not have the ability to do that.

Apart from that I made a `config.ini` file that currently has the  host and port data. Later it will have more stuff. I also **put all my state inside of a global struct** named `global`.


```odin
GlobalState :: struct {
	quit:         bool,
	net:          Network,
	time:         Time,
	input:        common.PlayerInput,
	client_state: ClientState,
	render_state: common.ServerOutput,
}

Time :: struct {
	fps:        f64,
	frame_time: f64,
	dt:         f64,
	show_fps:   bool,
	countdown:  common.CountDownOutput,
}

Network :: struct {
	port: u16,
	host: cstring,
}

global: GlobalState = {}

```

### For future me
I really need to stop working on these useless things and actually work on the project. Yes! from tmrw I will lock in! 


I will add mouse input and use that to rotate a rectangle/sprite around the player, like the player is holding a stick or smth...


# Devlog #2

|                |                 |
| -------------- | --------------- |
| Time           | 5h 29m 18s      |
| Total Time     | 23h 46m 39s     |
| Date           | 20th June 2026  |


Procedural Terrain Generation is working now!

## Maths
I kinda learnt a lot of maths for `Perlin` and `simplex` noise generations! Watched a lot of tutorials to get an idea of how it is generally implemented to generate terrain. It is very easy when you don't have to code the noise functions yourselves...

Resources: [1](https://youtu.be/J1OdPrO7GD0?t=655), [2](https://www.youtube.com/watch?v=cLs3CGNV120)

## Opensource helping
while at it I also added imgui as a dependency. When imgui was building I saw a two big libraries (the actual imgui and sdl3 repos) clone. They were more than 100mb each. I made some simple code changes `build.py` of the original repo which brought it down to 1-2mb each.


I made an [issue](https://gitlab.com/L-4/odin-imgui/-/boards?show=eyJpaWQiOiIyNSIsImZ1bGxfcGF0aCI6IkwtNC9vZGluLWltZ3VpIiwiaWQiOjE5MjkyMjMyMH0%3D) in the original bindings repo. Let's hope it goes well.


## Rendering

I changed the rendering technique of the tiles of the generated terrain twice. It was real hard work. This probably took most of the time. There were many errors in maths and logic during the making of terrain renderer.

<p align="center">
  <img src="https://github.com/user-attachments/assets/c2a6550b-62d6-461f-8ae4-9c045a996aec" alt="read the bottom desc" /><br>
  <b>A collage of images of my terrain generation working</b>
</p>

# Devlog #3

|                |                 |
| -------------- | --------------- |
| Time           | 3h 50m 43s      |
| Total Time     | 27h 37m 22s     |
| Date           | 21st June 2026  |


**Made rendering more than 4000% faster**!

> Premature optimisation is the root... 

So initially my renderer drew all the cells, even when not in view. There were only 64x64 cells so it was no problem for my lappy at all! But when I increased it to 512x512 my laptop took huge load (45ms rendering time)! Currently after implementing a camera thingy it is now not an issue. 

The terrain is generated once and only the visible part (80x45 cells) is rendered in the screen!

This change lead to render times go below 1ms again :)

The maths behind camera thing was really logical error prone, and took a lot of time + I had a rough time working with dynamic arrays of Odin. Apparently you got to use `raw_data(array)` function to get the underlying data from the array. This is not documented anywhere neither did LSP find me this function when I **did** try to find it!

# Other stuff

I also changed the colours of the terrain. 

Added background to the fps and frame_time texts

<p align="center">
  <img src="https://github.com/user-attachments/assets/4376a46c-7a3b-4084-b686-2570b5b41a86" alt="read the bottom desc" /><br>
  <b>Terrain with new colors</b>
</p>

# Devlog #4

|                |                 |
| -------------- | --------------- |
| Time           | 3h 19m 15s      |
| Total Time     | 30h 56m 37s     |
| Date           | 23st June 2026  |


Implemented Marching Squares!

## Brief intro to marching squares

This is a technique commonly used in 2d terrain generation models. It converts the rigid 'blocky' tiling of squares to smth more organic by adding triangles to the mix. The end result is even more good looking when you add linear interpolation!

## The implementation

Took everything from me. I feel exhausted and tired, I need sleep. The implementation took a lot of hand written logic, [here](https://github.com/aroyx/bs-odin/blob/b66529b451304cceae60e87bb6d5bb798d2e9f20/src/client/render_terrain.odin#L150-L166) and [here](https://github.com/aroyx/bs-odin/blob/b66529b451304cceae60e87bb6d5bb798d2e9f20/src/client/render_terrain.odin#L169). But idk how but the [lookup table](https://github.com/aroyx/bs-odin/blob/b66529b451304cceae60e87bb6d5bb798d2e9f20/src/client/render_terrain.odin#L150) was perfect, and required no changes! Sure took some time to make it but the results speak for themselves I think.


What was indeed the problem...

[this code in github](https://github.com/aroyx/bs-odin/blob/b66529b451304cceae60e87bb6d5bb798d2e9f20/src/client/render_terrain.odin#L178-L179)

```odin
	_bl := bl > threshold ? 0b0010 : 0
	_br := br > threshold ? 0b0001 : 0
```
The fix?
```odin
	_bl := bl > threshold ? 0b0001 : 0
	_br := br > threshold ? 0b0010 : 0
```

I had these two swapped from what the standard says! Oh my gawd, this took forever to debug.

## Performance

The current implementation is using `Painter's Algorithm`, this works but there is a heck ton of overdraw! I hate it and probably will try to find a fix to it soon!

<p align="center">
  <img src="https://github.com/user-attachments/assets/f70a0dec-deed-4cf5-b77c-cdbc0dcb2f55" alt="read the bottom desc" /><br>
  <b>Probably the best image explaining Marching squares</b>
</p>

# Devlog #5

|                |                 |
| -------------- | --------------- |
| Time           | 7h 28m 58s      |
| Total Time     | 38h 25m 35s     |
| Date           | 25th June 2026  |


A massive overhaul of game architecture.

## Architecture
I think it's safe to say that this time I **unscrambled the spaghetti  code**  that I have been writing. These things are hard but very important for a project of this scale. Else, the developer burden piles up and motivation to complete the game is dead. [#883172](https://github.com/aroyx/bs-odin/commit/8831725242e466461f5f601beef7ff50e2ba1758).


### Performance

I implemented a simple performance hack to my terrain generation. This fix gives almost 100% faster terrain generation and rendering! I've documented the fix in the comments of the code [here](https://github.com/aroyx/bs-odin/commit/f2a07aee6715d3cd126ead782515ab8d25e461ba#diff-4b53236fd9f74b14acad89df7dee49e1371a6cc85a47612e9bc40163f1c4e5fbR166-R175). [#f2a07a](https://github.com/aroyx/bs-odin/commit/f2a07aee6715d3cd126ead782515ab8d25e461ba)

### Camera
Till now the camera didn't follow the player, but now it does. The math again, wasn't easy. I introduced another bug that I [caught](https://github.com/aroyx/bs-odin/commit/c17cfd3e121ae4c1f0f6a7e89be5fb830796b005) days later. [#393da8](https://github.com/aroyx/bs-odin/commit/393da8de82347c8c3d8dfc9272b0fead2cdb9924)

### Others

1. Added a feature to ping server at any moment [#da64b7](https://github.com/aroyx/bs-odin/commit/da64b7d7a456c05978f6d6c174831eed52ae59da)
2. Enforced naming convention
3. Out of bounds array access fix

https://github.com/user-attachments/assets/a309a2c8-f3a8-4461-9be0-a39eeac48f03

# Devlog #6

|                |                 |
| -------------- | --------------- |
| Time           | 6h 24m 31s      |
| Total Time     | 44h 50m 6s      |
| Date           | 25th June 2026  |


**Reworked my entire Rendering and Windowing System...**

## Raylib - The unfortunate switch

I wanted to make a game accessible to many people. And the most accessible platform is Web. So I had to compile my application in `WASM`. While my previous renderer, `SDL_Renderer` was able to render in Web it was not meant to be used intensively, it doesn't support `shaders` among many other flaws. So I looked for other rendering libraries to use for my game.

**bgfx** - no bindings for Odin
**sokol** - I never used it, I had to ask myself if the complexity it brings with it is worth it. Very sweet option otherwise.
**Vulkan** - No WASM
**SDL_GPU** - No WASM

Raylib comes with it's own downsides tho - It is slow, just changing to it added 2ms to my render time, it was 1ms with SDL Renderer. But it's simplicity keeps me in awe.

Right now I've decided to settle with my slower Raylib and focus on important stuff like **offline mode**, **bots**, **characters**.

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/c66aa4fb-ea00-4f41-98a9-9c32e94a607c" alt="see the desc below" width="500"/><br>
      <b>Rendering the terrain in new Raylib renderer</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/2388fd75-bbaa-463b-abc4-b2e45a8ad315" alt="see the desc below" width="500"/><br>
      <b>Git diff of some changes</b>
    </td>
  </tr>
</table>

# Devlog #7

|                |                 |
| -------------- | --------------- |
| Time           | 5h 45m 56s      |
| Total Time     | 50h 36m 2s      |
| Date           | 28th June 2026  |



Frame Time so low, we're drawing the future.

Last devlog I said `Raylib` was slow. It is on me, I am dumb. I didn't have to look more into it, `DrawMesh` did the exact thing I required!

Currently, the frame renders in my laptop **under 0.9ms** instead of **3-4ms earlier** and in this devlog I document the changes I made.

## Batch Rendering
Earlier I iterated over all the vertices and rendered them. 
```odin
for v in vertices {
    rlgl.Color4ub(v.color.r, v.color.g, v.color.b, v.color.a)
    rlgl.Vertex2f(v.pos.x, v.pos.y)
}
```

That was very slow, when I profiled it I saw that just iterating over the vertices took about **1.4ms**. Drawing took another **1.5ms**.


So I changed the vertices data:

```odin
// old
vertex :: struct {
    pos: rl.Vector2,
    color: rl.Color,
}
vertices: [dynamic]vertex

// new
vertices_pos: [dynamic]rl.Vector3
vertices_col: [dynamic]rl.Color
```


Then I generate a `terrain_mesh` using these arrays in [this](https://github.com/aroyx/bs-odin/blob/a17082911fa25f6444bd9df4b31eb406caded874/src/client/terrain/render_terrain.odin#L254-L276) function. And use that to render everything at once!


```odin
if mesh_initialised && terrain_mesh.vaoId != 0 {
    rl.DrawMesh(terrain_mesh, default_material, default_transform)
}
```
#### Results
Went from **3-4ms** to **0.5ms**. But when we move we have to generate the vertices at each frame! So if we don' t move it is **0.5ms** but if we move it is **4.0+ms**!!!

## Chunking

Since our terrain doesn't change, we can store the results in GPU memory and render them at will. 
But if we try to render a texture of size `5120x5120`, our gpu will suffer really bad. So we chunk.

We divide the terrain in chunks, load them into gpu and show only the parts that are visible currently.

Sounds easy. But for stupid ppl like me it is hard, took me a long while to fight the memory, logic and silly mistakes. 

But finally, it did work.

#### Results
It renders about **0.8ms** avg and **1ms** in high load, sometimes goes down to **0.6ms** too! That too while moving!

https://github.com/user-attachments/assets/316f124f-01e0-442f-a238-1b96a0476360

# Devlog #8

|                |                 |
| -------------- | --------------- |
| Time           | 10h 32m 48s     |
| Total Time     | 61h 8m 50s      |
| Date           | 30th June 2026  |


Implemented Physics, generated islands form the terrain + Server side Seed generation.

## Performance 

Performance is out of the window, the [algorithm](https://github.com/aroyx/bs-odin/blob/cff215c2d7055f0b42398868d83f599aefcc90f5/src/physics/gen_islands.odin#L75-L126) that generates the islands is **O(n^3)**!! This disgusts me, but I wasn't even able to come up with this solution! AI made the entire function...unfortunately I was not able to come up with the solution by myself...

I understand how the function works, but I don't know how I could improve it anyway. **The one upside to this is that, this function will only run once** - during the game start. 

My beloved physics engine Box2D can easily handle all these complex islands with no problem at all! So that helps :)


## Time

What took 10hrs? Most of the time was trying to generate the islands, another huge chunk of time was spent making the renderer for Box2D [#510535](https://github.com/aroyx/bs-odin/commit/5105357cb56fa15ca8c1b8ad798fe2d855e37179).

IDK how, but the server side seed generation that I though would take less time took about 2hrs...[#4bac51](https://github.com/aroyx/bs-odin/commit/4bac51cec752596949dcc51a98d2f3d682b238d4)

## My state of mind

I am currently disappointed in myself, multiplayer is hard. Server side seed generation taking so much time destroyed my confidence. Not being able to generate the islands broke me... I am having doubts of being competent enough to complete this project.

My current plan is to focus on single player - offline mode. I will handle multiplayer with server later. Currently I will focus on things that are fun and actually have meaning. First I'll make it work fully in web, then I will do character...

https://github.com/user-attachments/assets/4cae9c22-2a36-4432-b20e-ef2c9243b612

# Devlog #9

|                |               |
| -------------- | --------------|
| Time           | 8h 40m 13s    |
| Total Time     | 69h 49m 3s    |
| Date           | 2nd July 2026 |


From bare metals to web. A rough road.

My game is now available to play in [bs-odin.onkush.dev](https://bs-odin.onkush.dev)

I built my application for the Web and it works. Probably the most dirty work I had to do in this project overall. I probably have read all available `Odin`/`WASM` templates.

--- 

## Setting the Sail
I knew what `WASM` is, I once to compile one of my `C++` games to `WASM` too, but seeing **more than 500+ errors** in the first try took a big toll on me and I didn't bother. I don't want this project to end up like that.

I didn't have to search much to find a [template](https://github.com/karl-zylinski/odin-raylib-web/) that builds `Odin` + `raylib` in `WASM`. So I started to implement '**Offline Mode**' for my game. Didn't take much time tbh, easy work. So I went to sleep and assigned `WASM` implementation to future me.

## Thunderstorm
Next morning, I looked at how the {template](https://github.com/karl-zylinski/odin-raylib-web/) works - really simple and straightforward. I copied their code with proper attribution ofc. After fixing some build bugs, I ran my `build.sh` and...It didn't work. But nothing works the first time...

Spoiler, it didn't work in the 69th time either.

## Tsunami
By evening, I was able to make it compile, I won't get into the specifics but it had to do with multiple definition of functions within Odin core libraries.

So, after it compiled. I had a huge sigh of relief, I ran it in my browser and bam! A fully dark screen! Wait...What? NOO

I opened up the console... and Alas! Errors, not 500 errors, only one error `Uncaught (in promise) InternalError: too much recursion`
 
I couldn't find what caused this error, how to fix it, how to narrow it down. Lastly I gave up and went to sleep. After I woke up! I one by one tested each file and their dependency. Lastly I found the culprit...it was `Box2D` :agasp: 

After I dug deeper I found the fix, but it was concerned with changing the source code of Odin...so virtually no one can compile my game to `WASM` but me...

I'll try to find a workaround for it, till then - if it works, it works.

## The arrival to the forbidden Island

After a lot of hardwork, I got the fruits of my labour. This journey was not as much fun, but seeing my game run in my browser is so much worth it!

I fixed  few visual glitches and frame time capture fixes. And then I pushed it into my domain :)

<p align="center">
  <img src="https://github.com/user-attachments/assets/396220fb-1ea3-46fe-b2f1-63330258dace" alt="read the bottom desc" /><br>
  <b>Image of my game working in web</b>
</p>

# Devlog #10

|                |               |
| -------------- | --------------|
| Time           | 6h 8m 5s      |
| Total Time     | 75h 57m 8s    |
| Date           | 4th July 2026 |


Drops and drops together make an ocean. Did nothing major just some small stuff

---
- Added buttons (RayGUI) for navigation [#7608e9](https://github.com/aroyx/bs-odin/commit/7608e96f26c45110a99d244070fe66966847df6e)
---
- Added Loading Screen before match starts. [#76c086](https://github.com/aroyx/bs-odin/commit/76c086970e3850f638627e56e1d6935702f2801c), [#26ddc4](https://github.com/aroyx/bs-odin/commit/26ddc4b9750f27adae45b52f41fb3c9a180bca7e)
---
- Made the game fully self-contained. The game executable requires no dlls, no other libraries or assets either. Everything is bundled together in a single executable! 

For this to work, I used `#load("file_source")` function. It returns `[]u8` or in `C` terms `*uint8_t`.


But this won't work with the `raygui` style loader function `rl.GuiLoadStyle()` that requires the 'filename' and not the data.


So for that reason. I read the source code of raygui an d implemented [their function](https://github.com/raysan5/raylib/blob/master/examples/core/raygui.h#L4844) in Odin since they don't expose the function to the user.

That's about it tho!

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/151a3321-de05-4ada-bfa7-57e41f518b22" alt="see the desc below" width="500"/><br>
      <b>Main Menu UI</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/f61a898c-fba9-45d7-99de-0507a94268a5" alt="see the desc below" width="500"/><br>
      <b>Matchmaking UI</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/37fa2898-8478-4c2a-af74-2a9918b3b21f" alt="see the desc below" width="500"/><br>
      <b>Loading Screen UI</b>
    </td>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/fbe12058-c436-416d-b73d-99a828a18812" alt="see the desc below" width="500"/><br>
      <b>Gameplay UI</b>
    </td>
  </tr>
</table>

# Devlog #11

|                |               |
| -------------- | --------------|
| Time           | 6h 41m 40     |
| Total Time     | 82h 38m 48s   |
| Date           | 6th July 2026 |


Nothing much this time.
- Added options menu
- Added physics collider to the player (finally, phew..)
- Notify mobile users to play in landscape mode.

That's about it. 

All of them were relatively easy. What I did try and haven't pushed to upstream is a failed attempt to detect entry and exit from water bodies by the entities in an economical way.

The code for options menu too looks so horrendous! OMG, I am not touching that again!

https://github.com/user-attachments/assets/d6f73764-3952-4024-96d9-92d376a20499

# Devlog #12

|                |               |
| -------------- | --------------|
| Time           | 11h 40m 22s   |
| Total Time     | 94h 19m 10s   |
| Date           | 6th July 2026 |


## Fully functional animation parser and engine!

The entire thing started by me searching for assets to use for my game, then I found [these super cute chibi characters](https://craftpix.net/s/chibi/) that too FOR FREE!!

I downloaded [one](https://craftpix.net/freebies/chibi-skeleton-warrior-character-sprites/) of the free ones and saw that they use `.scml` file for animations. They do have pre-rendered png images in sequence too, but that is too easy, not fun and doesn't look good!

So, I planned to make a `.scml` parser, my own animation engine. And see how it goes.

In the added video there's the working part and the non-working part, which I found pretty funny. 

## 1. Image loader

First I made a image loader that dynamically loads all the sprites that are in use. Later I will add the abitily to drop the sprites from memory when not in use.

## 2. Mapping the data

This was, tough. Very, very tough that I had originally anticipated. Making this parser included me staring at a file with 9k lines for hours. Trying to figure out what each elements do and how to use them interconnectedly. I first made a `scml_data.odin` where I one by one mapped all the required data to odin structs.

## 3. `.scml` parser

I created a new file `scml_parser.odin` and in it I loaded the `.scml` file with Odin's built in `xml` parser. The parsing took a big chunk of time too, as there are not good docs or examples available out here. But there was one single [forum post](https://forum.odin-lang.org/t/need-some-help-understanding-how-to-utilize-core-encoding-xml/1130/2) that got me going and I never had any problems thereafter. I parse the file and save the values in my global private `data` variable defined in `scml_data.odin`.

I read each elements and added all the necessary ones. I observed all the attributes, data and values very carefully earlier so I had an idea of some repetitive values that I could skip. I think almost 50% of the file was repetition, which ofc I didn't save.

## 4. The engine

Now that I had all the data with me in, the only thing I had to do was use that.

With a given time `t` I have to find the `timeline` that it lands on and interpolate the time, linearly lerp the values and issue a draw command for the single sprite.

I was unable to do two specific things and had to take help from AI:

1. Lerping Angle: angle lerping is different as there can be a case where we have to learp from 350 to 10, normal lerp functions would just lerp it 350->200->10 instead of 350->360->10
2. Using the parent bones to calculate the final position of the child node. The particular function ai generated is [here](https://github.com/aroyx/bs-odin/blob/199956fdee5d212550061b17af7145149ebcd455/src/animations/engine.odin#L105).

## Debugging

After making the engine, we got to fix the engine.

It had bugs, I debugged for a long time and then fixed them. Pretty stupid things like not pushing the timeline keys after initialising them, flipped y-axis, and angle clockwise order.

## Final thoughts

Finally the thing is working now, I still have to polish it and make it play nicely with my entire game. There are other optimisation opportunities available but I'll put that for later.

I will now work on the avatar menu, so user can mix different things. 

Working Animations:

https://github.com/user-attachments/assets/94792b71-f17d-42de-9bea-4ec514864801

Not Working Animations:

https://github.com/user-attachments/assets/431d7916-60ad-49d5-9012-03bcce57edbc

# Devlog #13

|                |               |
| -------------- | --------------|
| Time           | 8h 16m 38s    |
| Total Time     | 102h 35m 48s  |
| Date           | 9th July 2026 |


## Implemented Animation blending + UI library changed


I wanted the player to be rendered in the **main_menu** and in the **avatar menu**. But also wanted the animations to be looping randomly.

When I implemented random looping I found out that, the animations wouldn't behave properly due to **snapping**. So I **implemented animation blending**.

It was **not at all easy**, had to implement another `angle_lerp` function specifically for blending angles.

## Character customisation

Due to me working hard earlier, changing character sprites is a cakewalk. In the attatched video. The head sprite is of **tier 2** while the rest is from **tier 1**


## GUI

I really wanted to like raygui, but it was really bad. A lot of maths required for very simple things! I didn't like it at all. So in search of a new UI library I found this niche library [orui](https://github.com/andzdroid/orui)! 

This fits my needs perfectly:
- Immediate mode
- Super fast
- (Not what I was looking for but a plus) Uses raylib
- Doesn't depend on me to do the maths
- Actually customisable


You can see the updated GUI in the video, looks good right :) it also supports animations and transitions!

https://github.com/user-attachments/assets/4b818731-d6b4-47bb-89ac-5440e0831343

# Devlog #14

|                |                |
| -------------- | -------------- |
| Time           | 7h 5m 46s      |
| Total Time     | 109h 41m 34s   |
| Date           | 10th July 2026 |


## UI Overhaul - Done!

So I **changed the entire UI**, game UI is tough, even more so when you have a lot of moving components.

I never had ever use any library like `orui` so it was fun, but at the same time - confusing at times. Like for example: there are only 2 components for drawing (`container` and `label`). I mean there's also element, but that is just an empty container.

Also I've tried everything but you can't just get hover information for the `container` element. 

I need some color suggestions for the buttons in options menu, they look kinda dull...

All the colors are taken from pallets at [coolors.co](https://coolors.co)!

## Icons!!

So while at it, I wanted to add icons. **This was hell.** A very bad idea. Let me tell you why - `orui` doesn't support icons by default, so you've got to load another font to draw the icons.


Now, Raylib can't draw icon fonts, until you specify all the individual codepoints...here's the code required to load a font with 3 icons:

```odin
icon_codepoints := [?]rune {
    0xe048, // ICON_LUCIDE_ARROW_LEFT
    0xe049, // ICON_LUCIDE_ARROW_RIGHT
    0xe14d, // ICON_LUCIDE_SAVE
    0xe18e, // ICON_LUCIDE_TRASH_2
}

icon_font = rl.LoadFontEx(
    "./res/fonts/lucide.ttf",
    32,
    &icon_codepoints[0],
    len(icon_codepoints),
)
```


## Animation Blending

Made the animation transition buttery smooth!! Look at the video!!

https://github.com/user-attachments/assets/a98bb145-6f67-4636-8808-b12ddc1385d5

# Devlog #15

|                |                |
| -------------- | -------------- |
| Time           | 4h 18m 14s     |
| Total Time     | 113h 59m 48s   |
| Date           | 11th July 2026 |


## Player Customisation Screen!!

RAAH, this is really done! TBH this was easier than expected. I had an 
idea of how this will work out, and implemented just that. The menu 
includes some _smart_ and _fancy_ mathematics too

```odin
// gettin the index
current_index := (int(curr_type) * num_tiers) + int(curr_tier)

// applying the changes, Lets say user pressed right arrow.
new_index := (current_index + 1) % total_options

setPartType(group, anim.CharacterType(new_index / num_tiers))
setPartTier(group, anim.CharacterTier(new_index % num_tiers))
```

I am really proud of the UI. Looks great. Honestly I was really lucky 
with the great reference images I found in the internet :)

[hosted here](https://bs-odin.onkush.dev)

https://github.com/user-attachments/assets/7e03f34f-dd4a-4510-addf-a7e3eafeac5b

# Devlog #16

|                |                |
| -------------- | -------------- |
| Time           | 5h 39m 56s     |
| Total Time     | 119h 39m 44s   |
| Date           | 14th July 2026 |


## Dozens of small features implemented!

1. Migrated the End screen UI to the new UI library
2. Brought back the physics collider with water from previously deleted code.
3. Removed a rouge sleep call in loading phase. (Which was put there for testing :hs: )
4. Instead of drawing rectangles in when playing. We now draw the characters! With randomly generated skins!!
5. Migrated Playing and loading UI to the new library
6. Code cleanup and refactored for better architecture

## Culling [#bd56fa](https://github.com/aroyx/bs-odin/commit/bd56faceae2f909bd0a73a96aae29629f727c8cf)

When adding Culling to player rendering, I got an optimisation of 5ms->2ms.


## Animation while playing

The initial phase was very easy. What I did struggle with was flipping the image. First, I tried flipping the texture themselves. 

It did work but the offset of the bones were not in place. It was fine when going right, but when I turn left. It all turns bad, the 2nd video is a demonstration of that.

It took a lot of tweaks and black magic to find out that I had to also flip the anchor position and angle too 😭 


Now it is working as intented :)

The video of animation working:

https://github.com/user-attachments/assets/62ec643e-d19a-492b-8ba9-57b4cb9beddf

The video of animation **not** working:

https://github.com/user-attachments/assets/bc7a76ce-d2a4-439e-8bdc-663ef1a48b04

# Devlog #17

|                |                |
| -------------- | -------------- |
| Time           | 9h 42m 24s     |
| Total Time     | 129h 22m 8s    |
| Date           | 16th July 2026 |

## Enemy AI done + Tons more!

Other things done this time around:
- Fix: WASM build fixes
- Feature: Added the back button in Avatar Menu (finally)
- Fix: The character scale and position in Main/Avatar Menu acted funny in extreme dimentions (when too small)
- Fix: Physics renderer didn't render polygons with 4 vertices
- Feature: Added physics colliders for all enemies!
- Feature: Y-Sorting enabled
- Performance: Pushed Data Oriented Design for max performance
- Architecture: Moved the files around, where they make more sense
- Feature: Implemented Attacking
- Feature: Player & Enemy State machine
- Feature: Enemy AI (super basic tbh)

### Performance

All of these changes were made keeping performance in mind. As of right now the state machines need work to make them even faster!

### Obstacles

State machine logic is very mind numbing, I won't want to do that.... a lot of edge case problems. A lot of problems I never thought existed. 

Y-Sorting was also in the harder side because I wanted a fast sort while also not needing to change the whole array of entities. I finally decided to use another array `render_list` of type `[]int` this essentially sorts the `id` (or index in this case) of the entities by `entity.pos.y`. When rendering use the ids to render. This proved to be a more efficient way to do it, than sorting the entire array of entities.

### Future Todos

- Implement Enemy attacking
- Implement health system (with regenability?)
- Draw the health bar
- Implement death


After these things are done. We I will think of further things like game win/game end amongst many others like game pause.

https://github.com/user-attachments/assets/6da32bd6-d760-4d2e-b601-7e7b69f3aec3

# Devlog #18

|                |                |
| -------------- | -------------- |
| Time           | 5h 18m 23s     |
| Total Time     | 134h 40m 31s   |
| Date           | 17th July 2026 |


## Health System, Enemy Attack, 15 new Skin!

Summary of Features added:
- Player/Enemy Attacks
- Health System (Damage/Heal)
- Health Bar shown
- 15 new Skins!
-  Avatar Menu "Set" Selector

## Avatar Set Selector 

This took a lot of time than I would like. I first had to scourge through 100s of directories for each Skin (each skin has 3 "tiers") and get the 0th "idle" animation sprite.

The next part was pretty straight forward owing to the time I took to make the architecture great :3 

## Health Bar

This wasn't hard as per say. But it is mad slow. I realised it earlier but never mentioned it. orui library is slow. UI libraries aren't meant to be this slow. Probably it is due to the rendering that makes it this much slower.

How slow? My renderer could render 50 entities under 1ms, now it takes ~5ms to render 20 entities. 

## Future Todos:

- Performance. I will track down where orui is slow. If it is in the logic part, we can't do anything as I am not smart enough to fix logic so complex. But if it is related to rendering, we can work with that.
- Performance. It's been a while since I diagnosed the slow parts in my code. I will deep dive into the code. Find out what is slow and try to fix them


The next few days, I will work on to squeeze as much performance as **I can** from this game.

https://github.com/user-attachments/assets/fccee486-b38c-4694-a9dd-6709939d3fea

# Devlog #19

|                |                |
| -------------- | -------------- |
| Time           | 6h 18m 30s     |
| Total Time     | 140h 59m 1s    |
| Date           | 20th July 2026 |

## Preformance Checkup + Audio System

Things I did:
- I stress tested my game to work with **512 & 1024** entities. Ran under **3ms** and **5ms**. The difference maker was the number of entities currently in the screen (rendering).
- **Profiled** all the "slow" parts
- Implemented **sound system**, for menu and game
- **Recorded the sounds myself!!** (both in-game and ui)!


## Performance

I tried my best to find ways to increase speed in my game. Unfortunately, all the things that I thought were "slow" weren't actually slow. 
- Orui UI build was like under **50micro seconds**.
- Orui Rendering was under **250micro seconds**.
- Animation system ran under **50micro** for all entities combined iirc

So, for now, there has been done no performance improvements this devlog

## Sound System

First I made the sound system simple, for the menu. It worked and I was happy. I made 6 different similar sounds for the hover and click actions, and I play one of them randomly when clicked.

```odin
menu_hover_sounds: [6]rl.Sound
loadMenuSounds :: proc() {
	for i in 0 ..< len(menu_hover_sounds) {
		path := fmt.ctprintf("res/audio/menu/menu_click_%d.wav", i + 1)
		menu_click_sounds[i] = rl.LoadSound(path)
	}
}

playMenuHoveredSound :: proc() {
	i := rand.int_max(len(menu_hover_sounds))
	rl.PlaySound(menu_hover_sounds[i])
}
```

When I went on to make the Player sounds, I noticed that I am unable to the same sound twice simultaneously. I needed that so that I can simulate multiple enemies and other stuff.


So I googled a bit, found [this](https://www.raylib.com/examples/audio/loader.html?name=audio_sound_multi) raylib example. And implemented it. For both menu and entities.


```odin
TOTAL_ALIASES :: 4
Sound :: struct {
	aliases: [TOTAL_ALIASES]rl.Sound,
	index:   int,
}

loadSound :: proc(path: cstring) -> Sound {
	sound: Sound
	sound.aliases[0] = rl.LoadSound(path)

	for i in 1 ..< TOTAL_ALIASES {
		sound.aliases[i] = rl.LoadSoundAlias(sound.aliases[0])
	}

	sound.index = 0
	return sound
}

playSound :: proc(sound: ^Sound) {
	rl.PlaySound(sound.aliases[sound.index])
	sound.index = (sound.index + 1) % TOTAL_ALIASES
}

playMenuClickedSound :: proc() {
	i := rand.int_max(len(menu_click_sounds))
	playSound(&menu_click_sounds[i])
}
```


I also ~~stole~~ borrowed :evilrondo: [this](https://github.com/raysan5/raylib/blob/master/examples/audio/resources/country.mp3) really great background music from raylib source.

https://github.com/user-attachments/assets/4df32170-1f60-4343-a496-f5bf5b777282


# Devlog #20

|                |                |
| -------------- | -------------- |
| Time           | 5h 57m         |
| Total Time     | 146h 56m 1s    |
| Date           | 20th July 2026 |


First `2h 40mins` was spent working on changing the `Entities`'s container from a *fixed array* to a [handle map](https://pkg.odin-lang.org/core/container/handle_map/). The fix doesn't improve speed, but adds the feature of adding and removing entity at will which the fixed array did not.

The rest of the time porting this journal from stardance devlogs. It took a long time, and was a real headache.

Why was it a pain:
0. I am stupid and I did all of them one by one instead of 1 task at a time like copying all the devlogs at once, then copying the time and rest.
1. There were 19 Devlogs to port
2. The Stardance website shows the devlog rendered so if I copy it, I won't get the formatting like ** for **bolds**, __ for _this_, links and all.
    1. Solution was to go to edit page and copy from there
3. Adding up the hours. Copying the hours was easy, adding is tuff so I asked AI to do it, one by one
4. The date, hardest part
    1. The date isn't displayed as `19th July`, it is displayed as `8 days ago`.
    2. This is even more problematic when the dates are displayed as `1 month ago`.
    3. The solution was to open the debug window, pick the element selector and click on the `1 month ago` text. I found out all the elements which display this property have a `title` tag to them which consists of the exact timestamp of the creation of the devlog

From now on, the devlogs will be done in a daily basis, or atleast I'll try to.

Now todos for the next day:
- Foliage (Generative)
- Point system

# Devlog #21

|                |                |
| -------------- | -------------- |
| Time           | 5h 10m         |
| Total Time     | 152h 6m 1s     |
| Date           | 28th July 2026 |

I am so disappointed in myself, I worked hard this time, to try to include some beautiful shaders... they looked ugly. I definitely think that this time (5hrs 33mins) should not be added. As the things I tried to do didn't add up. The results were not good looking at all and I scrapped it all by the end.

The unfortunate thing was that I had to take help from an AI to even get my shader up and running, I was having so much problems due to the defaults that Raylib sets.

After the shader was working I went on my own to add some changes, it looks horrible. It is bad and I feel so bad at myself for wasting so much time doing this...

I have saved the code in commits in this repo so I can copy the boilerplate code if I need them again, but damn 5hrs for nothing...

<table>
  <tr>
    <td align="center" colspan="2">
      <img src="https://github.com/user-attachments/assets/29c51fca-e7dc-419a-b3b6-bee20a58776b" alt="see the desc below" width="500"/><br>
      <b>Rendering Artifact due to huge scaling of texture with bilinear filter</b>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/50c8f610-baef-48e7-a7d5-4fb9e5ff81fa" alt="see the desc below" width="500"/><br>
      <b>Ugly shader at work</b>
    </td>
	<td align="center">
      <img src="https://github.com/user-attachments/assets/0859a93b-6853-4438-9a62-16bef0629205" alt="see the desc below" width="500"/><br>
      <b>Ugly shader again at work</b>
    </td>
  </tr>
</table>

I plan on sticking to my old plan now, 
- Foliage (Generative)
- Point system

I have an idea of how I want to do these things and I think it'll be easier for me to do so!

# Devlog #22

|                |                |
| -------------- | -------------- |
| Time           | 4h 27m         |
| Total Time     | 156h 33m 1s    |
| Date           | 29th July 2026 |


Terrain now has foliage!

Things done this devlog:
- Made the `handle_map` I was using **dynamic**
- Foliage has 16 types
- Stole the 16 types of sprites from screenshot of paid art asset, I will pay them later I swear!
- Made the state updates of the entities faster
- Foliage automatically generates and destroys with chunks
- You can beat down the foliage
- Updated the web version - after 11 long days!
- Fixed README build instructions

AI helped me this time with deterministic randomness. That is [this](https://github.com/aroyx/bs-odin/blob/b45e82cda8cf0f1323be4b21e6e043ba226dd9a7/src/playing/foliage.odin#L112-L115) part of the code:

```odin
seed := (u64(u32(i)) << 32) | u64(u32(j))
r := rand.create(seed)
gen := rand.default_random_generator(&r)

x := rand.float32(gen) // given the same i and j; x will always give thes same output!
```


<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/1cd77740-1397-4dc4-933f-327ea678bbf6" alt="see the desc below" width="500"/><br>
      <b>Foliage bug, cluttered</b>
    </td>
	<td align="center">
      <img src="https://github.com/user-attachments/assets/9647a305-2290-4bd8-9c7f-2ea0bbff45f4" alt="see the desc below" width="500"/><br>
      <b>A lotta foliage :)</b>
    </td>
  </tr>
<tr>
    <td align="center" colspan="2">
      <img src="https://github.com/user-attachments/assets/25f0cedf-bfbc-40be-96ca-9cfd3286a8cd" alt="see the desc below" width="500"/><br>
      <b>A lotta foliage, but on land only</b>
    </td>
  </tr>
</table>

# Devlog #23

|                |                |
| -------------- | -------------- |
| Time           | 4h 32m         |
| Total Time     | 161h 05m 1s    |
| Date           | 30th July 2026 |


Attack button and boundary waters!

So the edges of the screen have been bothering me for a long while now! I've wanted to change them for a long time. Today I changed them, it was a very simple change tho! For the edge tiles, I just made their heights lower the further as they went back.

<table>
  <tr>
    <td align="center">
      <img src="https://github.com/user-attachments/assets/15af666b-16e9-4596-83d6-fff2eddd0903" alt="see the desc below" width="500"/><br>
      <b>No boundary water :(</b>
    </td>
	<td align="center">
      <img src="https://github.com/user-attachments/assets/596fe535-232d-4ae8-a9aa-82144d00b65c" alt="see the desc below" width="500"/><br>
      <b>Yes boundary water! :)</b>
    </td>
  </tr>
</table>

And added the attack button! The attack button was supposed to be here because I wanted to provide a visual clue to the player that the attack is on "cool down" now. Plus it helps as a helpful button for players with touch inputs!

<p align="center">
  <img src="https://github.com/user-attachments/assets/ca49dad0-898c-4627-bf5c-35fb2f637c60" alt="read the bottom desc" /><br>
  <b>A loota trees/plans + buttons!</b>
</p>

Summary of things I did:
- Made the Boundary All Water!
- Normalised player movement
- Implemented the Attack button
- Fixed a Segfault when restarting, this was due to the unrequired deletion of a dynamic array.
- Increased foliage amount 3 times
- Made visual Joystick (non-functional!)

Plan for tmrw:
- Make the Joystick functional
- Sound effects for enemy and players!
- Pause Menu
- add journal #22 pics

# Devlog #24

|                |                |
| -------------- | -------------- |
| Time           | 3h 50m         |
| Total Time     | 164h 55m 1s    |
| Date           | 31th July 2026 |


Foliage, joystick, touch event improvements.

Summary:
- Made the joystick functional
- Fixed issues that came with touch controls (multi touch)
- Fixed small health bar on mobile devices
- Changed the foliage from the one illegaly stolen from a screeshot of a ad about foliage sprites. Now I use [Kenny's foliage](https://kenney.nl/assets/foliage-pack) pack! It is free, beautiful and most importantly fits my theme a lot more than what the other one did!
- Added proper bounding box calculation for all trees, bushes and entities. The prev solution involved setting a single big bounding box for all entities
- Added transparancy for the bushes that are infront of player

### A huge bother
One thing that puzzles me a lot is Android support... yk the web version works awesome in android and ios. When I tried my game in my android it felt like the game was having a seizure! I absolutely hated it. I searched for long while, without any good understanding of the issue.

That is going to stay here until I can know the source of the problem.

Anyway, my friend tried it out in his IPad and it worked flawlessly in his :) so that's a plus :D

Plan for tmrw:
- Pause Menu
- Sounds for players and enemies, maybe bushes too

