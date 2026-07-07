package animation


init :: proc() {
    loadAllParts()

    parse_scml()
}

close :: proc() {
    unloadAllParts()
}
