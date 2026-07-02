#+build js, wasm32
package tracy

import "core:c"

TracyPlotFormatEnum :: enum i32 {
	TracyPlotFormatNumber,
	TracyPlotFormatMemory,
	TracyPlotFormatPercentage,
	TracyPlotFormatWatt,
}

___tracy_source_location_data :: struct {
	name:     cstring,
	function: cstring,
	file:     cstring,
	line:     u32,
	color:    u32,
}

___tracy_c_zone_context :: struct {
	id:     u32,
	active: b32,
}

___tracy_gpu_time_data :: struct {
	gpuTime:  i64,
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_zone_begin_data :: struct {
	srcloc:   u64,
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_zone_begin_callstack_data :: struct {
	srcloc:   u64,
	depth:    i32,
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_zone_end_data :: struct {
	queryId:  u16,
	_context: u8,
}

___tracy_gpu_new_context_data :: struct {
	gpuTime:  i64,
	period:   f32,
	_context: u8,
	flags:    u8,
	type:     u8,
}

___tracy_gpu_context_name_data :: struct {
	_context: u8,
	name:     cstring,
	len:      u16,
}

___tracy_gpu_calibration_data :: struct {
	gpuTime:   i64,
	cpuDelta:  i64,
	_context:  u8,
}
