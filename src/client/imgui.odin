package client

import "thirdparty:imgui"
import "thirdparty:imgui/imgui_impl_raylib"

IMGUI_ENABLE :: #config(IMGUI_ENABLE, true)

when IMGUI_ENABLE {
	ImGuiInit :: proc() {
		imgui.CHECKVERSION()
		imgui.CreateContext()
		io := imgui.GetIO()

		io.ConfigFlags += {.DockingEnable, .NavEnableGamepad}

		imgui.StyleColorsDark()

		imgui_impl_raylib.init()
	}

	ImGuiClose :: proc() {
		imgui_impl_raylib.shutdown()
		imgui.DestroyContext()
	}

	ImGuiProcessEvent :: proc() {
		imgui_impl_raylib.process_events()
	}

	ImGuiNewFrame :: proc() {
		imgui_impl_raylib.new_frame()
		imgui.NewFrame()

		// imgui.DockSpaceOverViewport()
	}

	ImGuiRender :: proc() {
		imgui.Render()
		imgui_impl_raylib.render_draw_data(imgui.GetDrawData())
	}
} else {
	ImGuiInit :: proc() {}
	ImGuiClose :: proc() {}
	ImGuiProcessEvent :: proc() {}
	ImGuiNewFrame :: proc() {}
	ImGuiRender :: proc() {}
}
