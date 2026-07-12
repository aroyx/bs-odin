# BS-Odin
A stupidly simple game, where you go right

I will probably change the name of this game. This is such a lazy ass name.

Features:
- [ ] Terrain Generation
    - [x] Simple Terrain generation and rendering
    - [ ] Other stuff like trees and shit
- [ ] Character
    - [x] Character controller
        - [x] Keyboard inputs
        - [ ] Mouse inputs
    - [x] Animations
    - [x] Character Selector
- [ ] Enemies
    - [ ] Randomly generate their skin
    - [ ] Enemy AI

### AI Usage
I've used AI to find myself topics that may help solve particular solution. AI didn't write any code.

Example: 
> I: "The FPS and Frame Time fluctuate a lot, I want to calculate avg FPS/Frame Time of my game, but only for the last 20-30 frames...I don't want to create an circular buffer to do it...too much memory, there must be some mathematical formula right?"

> AI responds with a big text. I read the headings and find "Moving average". I open it up in wiki, read the page, try to understand the derivation. Later I found "Exponential Moving average" and then implement it in my game since it felt like the perfect solution to my problem

