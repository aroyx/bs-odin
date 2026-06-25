package client

import "thirdparty:imgui"
import "thirdparty:imgui/imgui_impl_sdl3"
import "thirdparty:imgui/imgui_impl_sdlrenderer3"
import "vendor:sdl3"

when IMGUI_ENABLE {
	ImGuiInit :: proc() {
		imgui.CHECKVERSION()
		imgui.CreateContext()
		io := imgui.GetIO()

		io.ConfigFlags += {.DockingEnable, .NavEnableGamepad}

		imgui.StyleColorsDark()

		imgui_impl_sdl3.InitForSDLRenderer(window, renderer)
		imgui_impl_sdlrenderer3.Init(renderer)
	}

	ImGuiClose :: proc() {
		imgui_impl_sdlrenderer3.Shutdown()
		imgui_impl_sdl3.Shutdown()
		imgui.DestroyContext()
	}

	ImGuiProcessEvent :: proc(event: ^sdl3.Event) {
		imgui_impl_sdl3.ProcessEvent(event)
	}

	ImGuiNewFrame :: proc() {
		imgui_impl_sdl3.NewFrame()
		imgui_impl_sdl3.NewFrame()
		imgui.NewFrame()

		// imgui.DockSpaceOverViewport()
	}

    ImGuiRender :: proc() {
		imgui.Render()
		imgui_impl_sdlrenderer3.RenderDrawData(imgui.GetDrawData(), renderer)
	}
} else {
	ImGuiInit :: proc() {}
	ImGuiClose :: proc() {}
	ImGuiProcessEvent :: proc(event: ^sdl3.Event) {}
	ImGuiNewFrame :: proc() {}
	ImGuiRender :: proc() {}
}
