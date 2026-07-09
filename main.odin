package main

import "core:fmt"
import "core:os"
import "lexer"

main :: proc() {
	args := os.args
	if len(args) != 2 {
		fmt.fprintf(os.stderr, "Usage: occ <file.c>\n")
		return
	}

	data, err := os.read_entire_file_from_path(args[1], context.allocator)
	if err != nil {
		panic("error reading file")
	}

	tokens := lexer.lex(string(data))
	defer delete(tokens)

	for token in tokens {
		fmt.println(token)
	}
}
