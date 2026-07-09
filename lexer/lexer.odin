package lexer

import "core:unicode"

tokentype :: enum {
	L_BRACE,
	R_BRACE,
	L_PAREN,
	R_PAREN,
	SEMICOLON,
	KEYWORD,
	IDENTIFIER,
	INTEGER_LITERAL,
}

token :: struct {
	type:    tokentype,
	literal: string,
}

new_token :: proc(type: tokentype, literal: string) -> token {
	return token{type, literal}
}

lex :: proc(source: string) -> [dynamic]token {
	tokens: [dynamic]token
	for i := 0; i < len(source); i += 1 {
		c := rune(source[i])
		switch c {
		case '(':
			append(&tokens, new_token(.L_PAREN, "("))
		case ')':
			append(&tokens, new_token(.R_PAREN, ")"))
		case '{':
			append(&tokens, new_token(.L_BRACE, "{"))
		case '}':
			append(&tokens, new_token(.R_BRACE, "}"))
		case ';':
			append(&tokens, new_token(.SEMICOLON, ";"))
		case:
			if unicode.is_space(c) {
				continue
			} else if unicode.is_digit(c) {
				startIndex := i
				for unicode.is_digit(rune(source[i])) {
					i += 1
				}
				number := source[startIndex:i]
				append(&tokens, new_token(.INTEGER_LITERAL, number))
			} else if unicode.is_letter(c) {
				startIndex := i
				for unicode.is_letter(rune(source[i])) {
					i += 1
				}
				word := source[startIndex:i]
				if word == "int" || word == "return" {
					append(&tokens, new_token(.KEYWORD, word))
				} else {
					append(&tokens, new_token(.IDENTIFIER, word))
				}
			}
		}
	}
	return tokens
}
