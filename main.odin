package main

import "core:fmt"
import "core:os"
import "lexer"
import "parser"
import "generator"

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

	tokens, lex_err := lexer.lex(string(data))
	if lex_err != .None {
		fmt.fprintf(os.stderr, "Lexer error: ")
		switch lex_err {
		case .Missing_Paren:
			fmt.fprintf(os.stderr, "unmatched opening parenthesis\n")
		case .Missing_Retval:
			fmt.fprintf(os.stderr, "'return' requires a return value followed by a semicolon\n")
		case .No_Brace:
			fmt.fprintf(os.stderr, "unmatched opening brace\n")
		case .No_Space:
			fmt.fprintf(os.stderr, "keyword must be followed by whitespace or delimiter\n")
		case .No_Semicolon:
			fmt.fprintf(os.stderr, "expected ';' after return statement\n")
		case .Wrong_Case:
			fmt.fprintf(os.stderr, "keywords must be lowercase\n")
		case .None:
			unreachable()
		}
		return
	}
	defer delete(tokens)

	ast, err_pars := parser.parse(tokens)
	if err_pars != .None {
		panic(parser.error_string(err_pars))
	}
	
	a := generator.generate(ast)
	fmt.printf("%s", a)
}
