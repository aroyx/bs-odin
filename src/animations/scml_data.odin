package animation

// Data map for future me.
// SpriterData will have animation data for all the entities: idk what they will be
// Currently there is only 1 entity: the character
// the character may have multiple different 'skins' but as I saw all my skins have the exact same animations.
// so we'll reuse the same animation for all character, but we'll swap the
// skins as required. The animation engine will only provide the position and
// rotation of the bones.

// `SpriterData` has `entities`,
// Each `entities` have different `animations`: run, walk, jump, ...
// each `animation` have a single `mainline` and multiple `timelines`
// `Mainline` defines the frames and timing for each frames
// Example : Frame 0 is in 0s, Frame 1 is in 0.2s, Frame...
// Each `timeline` define how a single part (head, arm, leg, ...) and bones moves in the timeline
// I do not know how to handle bones :/ what I do know is that they are defined alongside entity

data: SpriterData

@(private)
SpriterData :: struct {
	folder: Folder,
	entity: Entity, // will be an array if we add more entities
}

@(private)
Folder :: struct {
	files: [13]File, // should be dynamic
}

@(private)
File :: struct {
	id:      u8,
	name:    BodyPart,
	width:   f32,
	height:  f32,
	pivot_x: f32,
	pivot_y: f32,
}

@(private)
Entity :: struct {
	obj_infos:  [8]Bone,
	animations: map[string]Animation,
}

@(private)
Bone :: struct {
	name:  string,
	width: f32,
}

@(private)
Animation :: struct {
	id:        u8,
	length:    int,
	// l: int, // -475
	// t: int, // -732
	// r: int, // 424
	// b: int, // 168
	// interval: u8, // = 33, if required
	mainline:  MainLine,
	glines:    [dynamic]Gline,
	timelines: [dynamic]TimeLine,
}

@(private)
MainLine :: struct {
	bone_refs: [dynamic]BoneRef,
	obj_refs:  [dynamic]ObjRef,
}

@(private)
BoneRef :: struct {
	id:       u8,
	timeline: u8,
	parent:   i8,
	key:      u8,
}

@(private)
ObjRef :: struct {
	id:       u8,
	timeline: u8,
	parent:   i8,
	key:      u8,
	z_index:  u8,
}

@(private)
Gline :: struct {
	pos: int,
	// v:   u8, // 1
}

@(private)
TimeLine :: struct {
    id: u8,
    name: BodyPart,
    keys: [dynamic]TimeLineKey
}

@(private)
TimeLineKey :: struct {
    id: u8,
    spin: i8,
    time: f32,
    x: f32,
    y: f32,
    angle: f32,
    scale_x: f32,
    scale_y: f32,
    alpha: f32,
}
