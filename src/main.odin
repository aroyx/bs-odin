package main

import "core:fmt"

Cat :: struct {
	name: string,
	age:  i32,
}

main :: proc() {
	cat := Cat {
		name = "Brosky",
		age  = 24,
	}

	fmt.printfln("%[0]M", size_of([131072]i32))
	fmt.println("\v\tWow")
	return
}
