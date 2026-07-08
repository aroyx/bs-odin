package animation

import "core:fmt"
import rl "vendor:raylib"

@(private = "file")
global_cache: [CharacterType][CharacterTier][BodyPart]rl.Texture

// currently load all the images, later we will implement releasing data from the memory if required. Most games load like gigs of assets. I think we can get away with a few megabytes
@(private)
loadAllParts :: proc() {
	for type in CharacterType {
		for tier in CharacterTier {
			for part in BodyPart {
				loadPart(type, tier, part)
			}
		}
	}
}

@(private = "file")
loadPart :: proc(type: CharacterType, tier: CharacterTier, part: BodyPart) {
	BASE :: "res/images/character"
	type_str := type_lookup[type]
	tier_str := tier_lookup[tier]
	part_str := part_lookup[part]

	path := fmt.ctprintf("%s/%s/%s/%s", BASE, type_str, tier_str, part_str)

	tex := rl.LoadTexture(path)
	if tex.id == 0 {
		fmt.println("You gone done bro, dead. Path: ", path)
		return
	}

	global_cache[type][tier][part] = tex
}

// will create Texture if not available
getPartTex :: proc(type: CharacterType, tier: CharacterTier, part: BodyPart) -> rl.Texture {
	tex := global_cache[type][tier][part]

	if tex.id != 0 {
		return tex
	}

	loadPart(type, tier, part)

	return global_cache[type][tier][part]
}

@(private)
unloadAllParts :: proc() {
	for type in CharacterType {
		for tier in CharacterTier {
			for part in BodyPart {
				if global_cache[type][tier][part].id != 0 {
					rl.UnloadTexture(global_cache[type][tier][part]) // god of nesting
				} // kinda looks like a penis if you look hard enough ;)
			}
		}
	}
}

@(private)
unloadPart :: proc(type: CharacterType, tier: CharacterTier, part: BodyPart) {
	if global_cache[type][tier][part].id != 0 {
		rl.UnloadTexture(global_cache[type][tier][part])
	}
}
