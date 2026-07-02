#+build js, wasm32
package tracy

import "core:c"
import "core:mem"

ProfiledAllocatorData :: struct {
	backing_allocator:  mem.Allocator,
	profiled_allocator: mem.Allocator,
	callstack_size:     i32,
	secure:             b32,
}

MakeProfiledAllocator :: proc(
	self: ^ProfiledAllocatorData,
	callstack_size: i32 = TRACY_CALLSTACK,
	secure: b32 = false,
	backing_allocator := context.allocator) -> mem.Allocator {
	
	self.callstack_size = callstack_size
	self.secure = secure
	self.backing_allocator = backing_allocator
	
	// Profiler is disabled for WASM, just yield the backing allocator directly
	return backing_allocator
}
