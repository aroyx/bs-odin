#+build !js, !wasm32
package ui

import "thirdparty:imgui"
import "thirdparty:imgui/imgui_impl_raylib"

import "../utils"

when utils.IMGUI {
    @(private)
	ImGuiInit :: proc() {
		imgui.CHECKVERSION()
		imgui.CreateContext()
		io := imgui.GetIO()

		io.ConfigFlags += {.DockingEnable, .NavEnableGamepad}

		imgui.StyleColorsDark()

		imgui_impl_raylib.init()
	}

    @(private)
	ImGuiClose :: proc() {
		imgui_impl_raylib.shutdown()
		imgui.DestroyContext()
	}

    @(private)
	ImGuiProcessEvent :: proc() {
		imgui_impl_raylib.process_events()
	}

    @(private)
	ImGuiNewFrame :: proc() {
		imgui_impl_raylib.new_frame()
		imgui.NewFrame()

		// imgui.DockSpaceOverViewport()
	}

    @(private)
	ImGuiRender :: proc() {
		imgui.Render()
		imgui_impl_raylib.render_draw_data(imgui.GetDrawData())
	}
} else {
    @(private)
	ImGuiInit :: proc() {}
    @(private)
	ImGuiClose :: proc() {}
    @(private)
	ImGuiProcessEvent :: proc() {}
    @(private)
	ImGuiNewFrame :: proc() {}
    @(private)
	ImGuiRender :: proc() {}
}
