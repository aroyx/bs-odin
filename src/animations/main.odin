package animation


init :: proc() {
    loadAllParts()

    parseScml()
}

close :: proc() {
    unloadAllParts()
}
