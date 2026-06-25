package client

import "core:fmt"
import "vendor:sdl3"
import "vendor:sdl3/ttf"

engine: ^ttf.TextEngine = nil
font: ^ttf.Font = nil

welcome_text: ^ttf.Text = nil
match_making_text: ^ttf.Text = nil
end_screen_text: ^ttf.Text = nil

initFonts :: proc() -> int {
	if ttf.Init() != true {
		fmt.printf("Failed to initialise SDL_TTF!\n%s\n", sdl3.GetError())
		return 1
	}

	font = ttf.OpenFont("./res/fonts/supercell.otf", 20.0)
	if font == nil {
		fmt.printf("Failed to create window!\n%s\n", sdl3.GetError())
		return 1
	}
	ttf.SetFontWrapAlignment(font, .CENTER)

	engine = ttf.CreateRendererTextEngine(renderer)
	if engine == nil {
		fmt.printf("Failed to create window!\n%s\n", sdl3.GetError())
		ttf.CloseFont(font)
		return 1
	}

	t: cstring : "Welcome To BS Brawl Starts!\nPress 'C' to connect\nPress 'Q' to quit\n\nHope you enjoy playing!"

	if createText(&welcome_text, t) != 0 {return 1}
	if createText(&match_making_text, "Match-Making!") != 0 {return 1}
	if createText(&end_screen_text, "Game End!\nIf you want to start again, press 'R'!") != 0 {
		return 1
	}

	return 0
}

closeFont :: proc() {
	if engine != nil do ttf.DestroyRendererTextEngine(engine)
	if font != nil do ttf.CloseFont(font)
	if welcome_text != nil do ttf.DestroyText(welcome_text)
	if match_making_text != nil do ttf.DestroyText(match_making_text)
	ttf.Quit()
}

createText :: proc(text: ^^ttf.Text, str: cstring) -> int {
	text^ = ttf.CreateText(engine, font, str, 0)

	if text^ == nil {
		fmt.printf("Failed to create match_making_text!\n%s\n", sdl3.GetError())
		ttf.DestroyRendererTextEngine(engine)
		ttf.CloseFont(font)
		return 1
	}

	ttf.SetTextColor(text^, 255, 255, 255, 255)

	return 0
}
