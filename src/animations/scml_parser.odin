package animation

// import "core:encoding/xml"

init :: proc() {
    loadAllParts()

	// xml.load_from_file("res/images/sprite/character/skele1/animations.scml")
}

close :: proc() {
    unloadAllParts()
}
