
---
title: "BS-Odin"
author: "Ankush Roy"
desc: BS-Odin is a multiplayer game in the making using Odin language. This is the first devlog of it where major work has been done.
start-date: "2026-05-28"
---

2h 40mins - coding

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
