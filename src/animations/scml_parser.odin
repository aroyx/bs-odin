package animation

import "core:strings"
// this initialises the `data` gloabl variable

import "core:encoding/xml"
import "core:fmt"
import "core:strconv"
import "core:time"
import "vendor:raylib"

@(private)
parse_scml :: proc() {
	// use raylib file loader so that I can use it in wasm
	fileSize: i32 = 0
	raw := raylib.LoadFileData("res/images/character/Animations.scml", &fileSize)
	if raw == nil {
		fmt.println("XML: Okay, you done fucked bad")
		return
	}
	defer raylib.UnloadFileData(raw)

	bytes := make([]u8, fileSize)
	copy(bytes, raw[:fileSize])
	defer delete(bytes)

	doc, err := xml.parse_bytes(bytes)
	if !handle_xml_errors(err) {
		return
	}
	defer xml.destroy(doc)
	// load the things in my own datas

	if doc.element_count < 0 do return

	root_id: u32 = 0
	if doc.elements[root_id].ident != "spriter_data" {
		fmt.println("XML Error: This is bad, are you sure the xml file is yours?")
	}

	parse_root(doc, root_id)
	fmt.println(size_of(data))
}

@(private = "file")
parse_root :: proc(doc: ^xml.Document, id: xml.Element_ID) {
	root := &doc.elements[id]
	for child_val in root.value {
		child_id := child_val.(xml.Element_ID)

		child_node := &doc.elements[child_id]

		if child_node.ident == "folder" {
			parse_folder(doc, child_id)
		} else if child_node.ident == "entity" {
			parse_entity(doc, child_id)
		} else {
			fmt.println("XML Error: unknown element in root: ", child_node.ident)
		}
	}
}

@(private = "file")
parse_folder :: proc(doc: ^xml.Document, id: xml.Element_ID) {
	folder_el := &doc.elements[id]

	file_i := 0
	for child_val in folder_el.value {
		child_id, ok := child_val.(xml.Element_ID)
		if !ok do continue

		child_node := &doc.elements[child_id]
		if child_node.ident != "file" do continue

		part_name: BodyPart

		file_name := get_attrib_str(child_node, "name")
		for val, key in part_lookup {
			if val == file_name {
				part_name = key
				break
			}
		}

		file: File = {
			name    = part_name,
			id      = u8(get_attrib_int(child_node, "id")),
			width   = get_attrib_float(child_node, "width"),
			height  = get_attrib_float(child_node, "height"),
			pivot_x = get_attrib_float(child_node, "pivot_x"),
			pivot_y = get_attrib_float(child_node, "pivot_y"),
		}
		data.folder.files[file_i] = file
		file_i += 1
	}
}

@(private = "file")
parse_entity :: proc(doc: ^xml.Document, id: xml.Element_ID) {
	entity_el := &doc.elements[id]

	bone_i := 0

	data.entity.animations = make(map[string]Animation)

	for child_val in entity_el.value {
		child_id, ok := child_val.(xml.Element_ID)
		if !ok do continue

		child_node := &doc.elements[child_id]
		if child_node.ident == "obj_info" {
			bone: Bone = {
				name  = get_attrib_str(child_node, "name"),
				width = get_attrib_float(child_node, "w"),
			}
			data.entity.obj_infos[bone_i] = bone
			bone_i += 1
		} else if child_node.ident == "animation" {
			anim := parse_animation(doc, child_id)
			anim_name := get_attrib_str(child_node, "name")
			data.entity.animations[anim_name] = anim
		}
	}
}

@(private = "file")
parse_animation :: proc(doc: ^xml.Document, id: xml.Element_ID) -> Animation {
	anim_el := &doc.elements[id]

	anim: Animation = {
		id        = u8(get_attrib_int(anim_el, "id")),
		length    = get_attrib_int(anim_el, "length"),
		glines    = make([dynamic]Gline),
		timelines = make([dynamic]TimeLine),
	}
	anim.mainline.bone_refs = make([dynamic]BoneRef)
	anim.mainline.obj_refs = make([dynamic]ObjRef)

	for child_val in anim_el.value {
		child_id, ok := child_val.(xml.Element_ID)
		if !ok do continue

		child_node := &doc.elements[child_id]

		if child_node.ident == "gline" {
			gl: Gline = {
				pos = get_attrib_int(child_node, "pos"),
			}
			append(&anim.glines, gl)
		} else if child_node.ident == "mainline" {
			parse_mainline(doc, child_id, &anim.mainline)
		} else if child_node.ident == "timeline" {
			tl := parse_timeline(doc, child_id)
			append(&anim.timelines, tl)
		}
	}

	return anim
}

@(private = "file")
parse_mainline :: proc(doc: ^xml.Document, id: xml.Element_ID, mainline: ^MainLine) {
	ml_el := &doc.elements[id]

	for child_val in ml_el.value {
		child_id, ok := child_val.(xml.Element_ID)
		if !ok do continue

		child_node := &doc.elements[child_id]

		if !(child_node.ident == "key" && get_attrib_int(child_node, "id") == 0) {
			continue
		}

		for childer_val in child_node.value {
			childer_id, ok2 := childer_val.(xml.Element_ID)
			if !ok2 do continue

			childer_node := &doc.elements[childer_id]

			if childer_node.ident == "bone_ref" {
				bone_ref: BoneRef = {
					id       = u8(get_attrib_int(childer_node, "id")),
					timeline = u8(get_attrib_int(childer_node, "timeline")),
					parent   = i8(get_attrib_int(childer_node, "parent", -1)),
					key      = u8(get_attrib_int(childer_node, "key")),
				}
				append(&mainline.bone_refs, bone_ref)

			} else if childer_node.ident == "object_ref" {
				obj_ref: ObjRef = {
					id       = u8(get_attrib_int(childer_node, "id")),
					timeline = u8(get_attrib_int(childer_node, "timeline")),
					parent   = i8(get_attrib_int(childer_node, "parent", -1)),
					key      = u8(get_attrib_int(childer_node, "key")),
					z_index  = u8(get_attrib_int(childer_node, "z_index")),
				}
				append(&mainline.obj_refs, obj_ref)
			}
		}
	}
}

@(private = "file")
parse_timeline :: proc(doc: ^xml.Document, id: xml.Element_ID) -> TimeLine {
	tl_el := &doc.elements[id]

	timeline: TimeLine = {
		id   = u8(get_attrib_int(tl_el, "id")),
		name = get_part(get_attrib_str(tl_el, "name")),
		keys = make([dynamic]TimeLineKey),
	}

	for child_val in tl_el.value {
		child_id, ok := child_val.(xml.Element_ID)
		if !ok do continue

		child_node := &doc.elements[child_id]
		if child_node.ident != "key" do continue

		key: TimeLineKey = {
			id   = u8(get_attrib_int(child_node, "id")),
			spin = i8(get_attrib_int(child_node, "spin", 1)),
			time = get_attrib_float(child_node, "time"),
		}

		childer_id, ok2 := child_node.value[0].(xml.Element_ID)
		if !ok2 do continue

		childer_node := &doc.elements[childer_id]

		if childer_node.ident == "bone" || childer_node.ident == "object" {
			key.x = get_attrib_float(childer_node, "x")
			key.y = get_attrib_float(childer_node, "y")
			key.angle = get_attrib_float(childer_node, "angle")
			key.scale_x = get_attrib_float(childer_node, "scale_x", 1)
			key.scale_y = get_attrib_float(childer_node, "scale_y", 1)
			key.alpha = get_attrib_float(childer_node, "a", 1)
            key.file_id = get_attrib_int(childer_node, "file", -1)
		}

		append(&timeline.keys, key)
	}
	return timeline
}

@(private = "file")
get_attrib_str :: proc(element: ^xml.Element, key: string, default: string = "") -> string {
	for attrib in element.attribs {
		if attrib.key == key {
			return attrib.val
		}
	}
	return default
}

@(private = "file")
get_attrib_int :: proc(element: ^xml.Element, key: string, default: int = 0) -> int {
	for attrib in element.attribs {
		if attrib.key == key {
			if val, ok := strconv.parse_int(attrib.val); ok {
				return val
			}
		}
	}
	return default
}

@(private = "file")
get_attrib_float :: proc(element: ^xml.Element, key: string, default: f32 = 0) -> f32 {
	for attrib in element.attribs {
		if attrib.key == key {
			if val, ok := strconv.parse_f32(attrib.val); ok {
				return val
			}
		}
	}
	return default
}

@(private = "file")
get_part :: proc(name: string) -> BodyPart {
	for file in data.folder.files {
		lookup_str := part_lookup[file.name]

		if strings.has_prefix(lookup_str, name) {
			return file.name
		}
	}
	return {}
}

@(private = "file")
handle_xml_errors :: proc(err: xml.Error) -> bool {
	switch err {
	case .None:
		fmt.println("XML Success: No error occurred.")

	// a single regex to rule them all. This is why neovim is fun. Took me a while to cook this up but it works and the dopamine is worth it
	// '<,'>s/\v(\w+).*/case .\1: fmt.println("XML Error: \U\1!")
	case .General_Error:
		fmt.println("XML Error: GENERAL_ERROR!")

	case .Unexpected_Token:
		fmt.println("XML Error: UNEXPECTED_TOKEN!")

	case .Invalid_Token:
		fmt.println("XML Error: INVALID_TOKEN!")

	case .File_Error:
		fmt.println("XML Error: FILE_ERROR!")

	case .Premature_EOF:
		fmt.println("XML Error: PREMATURE_EOF!")

	case .No_Prolog:
		fmt.println("XML Error: NO_PROLOG!")

	case .Invalid_Prolog:
		fmt.println("XML Error: INVALID_PROLOG!")

	case .Too_Many_Prologs:
		fmt.println("XML Error: TOO_MANY_PROLOGS!")

	case .No_DocType:
		fmt.println("XML Error: NO_DOCTYPE!")

	case .Too_Many_DocTypes:
		fmt.println("XML Error: TOO_MANY_DOCTYPES!")

	case .DocType_Must_Preceed_Elements:
		fmt.println("XML Error: DOCTYPE_MUST_PRECEED_ELEMENTS!")

	case .Invalid_DocType:
		fmt.println("XML Error: INVALID_DOCTYPE!")

	case .Invalid_Tag_Value:
		fmt.println("XML Error: INVALID_TAG_VALUE!")

	case .Mismatched_Closing_Tag:
		fmt.println("XML Error: MISMATCHED_CLOSING_TAG!")

	case .Unclosed_Comment:
		fmt.println("XML Error: UNCLOSED_COMMENT!")

	case .Comment_Before_Root_Element:
		fmt.println("XML Error: COMMENT_BEFORE_ROOT_ELEMENT!")

	case .Invalid_Sequence_In_Comment:
		fmt.println("XML Error: INVALID_SEQUENCE_IN_COMMENT!")

	case .Unsupported_Version:
		fmt.println("XML Error: UNSUPPORTED_VERSION!")

	case .Unsupported_Encoding:
		fmt.println("XML Error: UNSUPPORTED_ENCODING!")

	case .Unhandled_Bang:
		fmt.println("XML Error: UNHANDLED_BANG!")

	case .Duplicate_Attribute:
		fmt.println("XML Error: DUPLICATE_ATTRIBUTE!")

	case .Conflicting_Options:
		fmt.println("XML Error: CONFLICTING_OPTIONS!")
	}

	if err != .None do return false
	else do return true
}
