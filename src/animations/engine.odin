package animation

import "core:math"
import "core:math/linalg"
import "core:time"

@(private = "file")
lerp_angle :: proc(start, end, t: f32, spin: i8 = 1) -> f32 {
	if spin == 0 do return start // no lerp

	target := end

	if spin == 1 && start > end { 	// anti-clockwise
		target += 360
	} else if spin == -1 && end > start { 	// clockwise
		target -= 360
	}

	return linalg.lerp(start, target, t)
}

DrawCommand :: struct {
	part:             BodyPart,
	x, y:             f32,
	scale_x, scale_y: f32,
	alpha:            f32,
	angle:            f32,
	pivot_x, pivot_y: f32,
}

calculate_frame :: proc(anim: ^Animation, time_ms, root_x, root_y: f32) -> [dynamic]DrawCommand {
	time_ms := math.mod(time_ms, f32(anim.length))

	root := Transform {
		x       = root_x,
		y       = root_y,
		scale_x = 1,
		scale_y = 1,
		alpha   = 1,
		angle   = 0,
	}

	bone_transforms: [256]Transform

	for bone_ref in anim.mainline.bone_refs {
		trans := get_timeline_transform(anim, bone_ref.timeline, time_ms)

		if bone_ref.parent != -1 {
			// please god, don't try to access parent without initialising parent first
			parent := bone_transforms[bone_ref.parent]
			bone_transforms[bone_ref.id] = combine_transforms(parent, trans)
		} else {
			bone_transforms[bone_ref.id] = combine_transforms(root, trans)
		}
	}

	draw_commands := make([dynamic]DrawCommand)

	for obj_ref in anim.mainline.obj_refs {
		trans := get_timeline_transform(anim, obj_ref.timeline, time_ms)

		tl := anim.timelines[obj_ref.timeline]

		final_trans: Transform

		if obj_ref.parent != -1 {
			parent := bone_transforms[obj_ref.parent]
			final_trans = combine_transforms(parent, trans)
		} else {
			final_trans = combine_transforms(root, trans)
		}

        file := get_file(tl.name)

		append(
			&draw_commands,
			DrawCommand {
				part = file.name,
				x = final_trans.x,
				y = root_y - (final_trans.y - root_y),
				alpha = final_trans.alpha,
				angle = -final_trans.angle,
				scale_x = final_trans.scale_x,
				scale_y = final_trans.scale_y,
				pivot_x = file.pivot_x,
				pivot_y = 1 - file.pivot_y,
			},
		)
	}

	return draw_commands
}

@(private)
Transform :: struct {
	x, y:             f32,
	scale_x, scale_y: f32,
	alpha:            f32,
	angle:            f32,
}

@(private = "file") // AI Made
combine_transforms :: proc(parent, child: Transform) -> Transform {
	rad := parent.angle * math.PI / 180.0
	c := math.cos(rad)
	s := math.sin(rad)

	return Transform {
		x = parent.x + (child.x * parent.scale_x * c) - (child.y * parent.scale_y * s),
		y = parent.y + (child.x * parent.scale_x * s) + (child.y * parent.scale_y * c),
		angle = parent.angle + child.angle,
		scale_x = parent.scale_x * child.scale_x,
		scale_y = parent.scale_y * child.scale_y,
		alpha = parent.alpha * child.alpha,
	}
}

@(private = "file")
get_timeline_transform :: proc(anim: ^Animation, timeline_id: u8, time_ms: f32) -> Transform {
	keys := &anim.timelines[timeline_id].keys

	if len(keys) == 0 do return {}
	if len(keys) == 1 {
		a := keys[0]
		return {
			x = a.x,
			y = a.y,
			scale_x = a.scale_x,
			scale_y = a.scale_y,
			alpha = a.alpha,
			angle = a.angle,
		}
	}

	key_index := 0

	for i in 0 ..< len(keys) {
		a := keys[i]
		if a.time <= time_ms {
			key_index = i
		} else {
			break
		}
	}

	a := keys[key_index]
	b := keys[(key_index + 1) % len(keys)]

	t: f32 = 0

	if b.time > a.time {
		t = linalg.unlerp(a.time, b.time, time_ms)
	} else if b.time < a.time {
		total := f32(anim.length) - a.time + b.time
		elapsed := time_ms - a.time
		t = elapsed / total
	}

	return {
		x = linalg.lerp(a.x, b.x, t),
		y = linalg.lerp(a.y, b.y, t),
		alpha = linalg.lerp(a.alpha, b.alpha, t),
		angle = lerp_angle(a.angle, b.angle, t, a.spin),
		scale_x = linalg.lerp(a.scale_x, b.scale_x, t),
		scale_y = linalg.lerp(a.scale_y, b.scale_y, t),
	}
}

@(private)
get_file :: proc(part: BodyPart) -> File {
	for file in data.folder.files {
		if file.name == part {
			return file
		}
	}

	return {}
}
