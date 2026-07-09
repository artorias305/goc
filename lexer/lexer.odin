package lexer

import "core:strings"
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

Lexer_Error :: enum {
	None = 0,
	Missing_Paren,
	Missing_Retval,
	No_Brace,
	No_Space,
	No_Semicolon,
	Wrong_Case,
}

token :: struct {
	type:    tokentype,
	literal: string,
}

new_token :: proc(type: tokentype, literal: string) -> token {
	return token{type, literal}
}

lex :: proc(source: string) -> ([dynamic]token, Lexer_Error) {
	tokens: [dynamic]token
	paren_count := 0
	brace_count := 0

	for i := 0; i < len(source); {
		c := rune(source[i])
		switch c {
		case '(':
			append(&tokens, new_token(.L_PAREN, "("))
			i += 1
			paren_count += 1
		case ')':
			append(&tokens, new_token(.R_PAREN, ")"))
			i += 1
			paren_count -= 1
		case '{':
			append(&tokens, new_token(.L_BRACE, "{"))
			i += 1
			brace_count += 1
		case '}':
			append(&tokens, new_token(.R_BRACE, "}"))
			i += 1
			brace_count -= 1
		case ';':
			append(&tokens, new_token(.SEMICOLON, ";"))
			i += 1
		case:
			if unicode.is_space(c) {
				i += 1
				continue
			} else if unicode.is_digit(c) {
				startIndex := i
				for i < len(source) && unicode.is_digit(rune(source[i])) {
					i += 1
				}
				number := source[startIndex:i]
				append(&tokens, new_token(.INTEGER_LITERAL, number))
			} else if unicode.is_letter(c) {
				startIndex := i
				for i < len(source) && unicode.is_letter(rune(source[i])) {
					i += 1
				}
				word := source[startIndex:i]
				lower := strings.to_lower(word)

				if len(word) > 3 && strings.to_lower(word[:3]) == "int" {
					return tokens, .No_Space
				}
				if len(word) > 6 && strings.to_lower(word[:6]) == "return" {
					return tokens, .No_Space
				}

				if lower == "int" && word != "int" || lower == "return" && word != "return" {
					return tokens, .Wrong_Case
				}

				if word == "int" {
					append(&tokens, new_token(.KEYWORD, word))
				} else if word == "return" {
					append(&tokens, new_token(.KEYWORD, word))

					for i < len(source) && unicode.is_space(rune(source[i])) {
						i += 1
					}

					if i >= len(source) ||
					   !unicode.is_letter(rune(source[i])) && !unicode.is_digit(rune(source[i])) {
						return tokens, .Missing_Retval
					}

					if unicode.is_digit(rune(source[i])) {
						start := i
						for i < len(source) && unicode.is_digit(rune(source[i])) {
							i += 1
						}
						append(&tokens, new_token(.INTEGER_LITERAL, source[start:i]))
					} else {
						start := i
						for i < len(source) && unicode.is_letter(rune(source[i])) {
							i += 1
						}
						val := source[start:i]
						if val == "int" || val == "return" {
							append(&tokens, new_token(.KEYWORD, val))
						} else {
							append(&tokens, new_token(.IDENTIFIER, val))
						}
					}

					for i < len(source) && unicode.is_space(rune(source[i])) {
						i += 1
					}

					if i >= len(source) || rune(source[i]) != ';' {
						return tokens, .No_Semicolon
					}
					append(&tokens, new_token(.SEMICOLON, ";"))
					i += 1
				} else {
					append(&tokens, new_token(.IDENTIFIER, word))
				}
			}
		}
	}

	if paren_count != 0 {
		return tokens, .Missing_Paren
	}
	if brace_count != 0 {
		return tokens, .No_Brace
	}

	return tokens, .None
}
