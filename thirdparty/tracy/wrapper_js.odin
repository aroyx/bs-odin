#+build js, wasm32
package tracy

import "core:c"

TRACY_ENABLE        :: false
TRACY_CALLSTACK     :: 5
TRACY_HAS_CALLSTACK :: false

SourceLocationData :: ___tracy_source_location_data
ZoneCtx            :: ___tracy_c_zone_context

// Zone markup
@(deferred_out=ZoneEnd) Zone   :: #force_inline proc(active := true, depth: i32 = TRACY_CALLSTACK, loc := #caller_location) -> (ctx: ZoneCtx) { return } 
@(deferred_out=ZoneEnd) ZoneN  :: #force_inline proc(name: string, active := true, depth: i32 = TRACY_CALLSTACK, loc := #caller_location) -> (ctx: ZoneCtx) { return } 
@(deferred_out=ZoneEnd) ZoneC  :: #force_inline proc(color: u32, active := true, depth: i32 = TRACY_CALLSTACK, loc := #caller_location) -> (ctx: ZoneCtx) { return } 
@(deferred_out=ZoneEnd) ZoneNC :: #force_inline proc(name: string, color: u32, active := true, depth: i32 = TRACY_CALLSTACK, loc := #caller_location) -> (ctx: ZoneCtx) { return } 

ZoneS   :: Zone
ZoneNS  :: ZoneN
ZoneCS  :: ZoneC
ZoneNCS :: ZoneNC

ZoneText  :: #force_inline proc(ctx: ZoneCtx, text: string) {}
ZoneName  :: #force_inline proc(ctx: ZoneCtx, name: string) {}
ZoneColor :: #force_inline proc(ctx: ZoneCtx, color: u32)   {}
ZoneValue :: #force_inline proc(ctx: ZoneCtx, value: u64)   {}

ZoneBegin :: proc(active: bool, depth: i32, loc := #caller_location) -> (ctx: ZoneCtx) { return }
ZoneEnd   :: #force_inline proc(ctx: ZoneCtx) {}

// Memory profiling
Alloc        :: #force_inline proc(ptr: rawptr, size: c.size_t, depth: i32 = TRACY_CALLSTACK)                {}
Free         :: #force_inline proc(ptr: rawptr, depth: i32 = TRACY_CALLSTACK)                                {}
SecureAlloc  :: #force_inline proc(ptr: rawptr, size: c.size_t, depth: i32 = TRACY_CALLSTACK)                {}
SecureFree   :: #force_inline proc(ptr: rawptr, depth: i32 = TRACY_CALLSTACK)                                {}
AllocN       :: #force_inline proc(ptr: rawptr, size: c.size_t, name: cstring, depth: i32 = TRACY_CALLSTACK) {}
FreeN        :: #force_inline proc(ptr: rawptr, name: cstring, depth: i32 = TRACY_CALLSTACK)                 {}
SecureAllocN :: #force_inline proc(ptr: rawptr, size: c.size_t, name: cstring, depth: i32 = TRACY_CALLSTACK) {}
SecureFreeN  :: #force_inline proc(ptr: rawptr, name: cstring, depth: i32 = TRACY_CALLSTACK)                 {}

AllocS        :: Alloc
FreeS         :: Free
SecureAllocS  :: SecureAlloc
SecureFreeS   :: SecureFree
AllocNS       :: AllocN
FreeNS        :: FreeN
SecureAllocNS :: SecureAllocN
SecureFreeNS  :: SecureFreeN

// Frame markup
FrameMark      :: #force_inline proc(name: cstring = nil)                             {}
FrameMarkStart :: #force_inline proc(name: cstring)                                   {}
FrameMarkEnd   :: #force_inline proc(name: cstring)                                   {}
FrameImage     :: #force_inline proc(image: rawptr, w, h: u16, offset: u8, flip: i32) {}

// Plots and messages
Plot       :: #force_inline proc(name: cstring, value: f64) {}
PlotF      :: #force_inline proc(name: cstring, value: f32) {}
PlotI      :: #force_inline proc(name: cstring, value: i64) {}
PlotConfig :: #force_inline proc(name: cstring, type: TracyPlotFormatEnum, step, fill: b32, color: u32) {}
Message    :: #force_inline proc(txt: string)               {}
MessageC   :: #force_inline proc(txt: string, color: u32)   {}
AppInfo    :: #force_inline proc(name: string)              {}

SetThreadName :: #force_inline proc(name: cstring) {}

// Connection status
IsConnected :: #force_inline proc() -> bool { return false }

// Fibers
FiberEnter :: #force_inline proc(name: cstring) {}
FiberLeave :: #force_inline proc()              {}
