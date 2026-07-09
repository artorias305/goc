package parser

import "../lexer"
import "core:strconv"

Parse_Error :: enum {
	None = 0,
	Unexpected_End,
	Unexpected_Token,
	Expect_Int_Keyword,
	Expect_Identifier,
	Expect_L_Paren,
	Expect_R_Paren,
	Expect_L_Brace,
	Expect_R_Brace,
	Expect_Semicolon,
	Integer_Overflow,
	Trailing_Tokens,
}

error_string :: proc(e: Parse_Error) -> string {
	switch e {
	case .None:
		return ""
	case .Unexpected_End:
		return "unexpected end of input"
	case .Unexpected_Token:
		return "unexpected token"
	case .Expect_Int_Keyword:
		return "expected 'int' keyword"
	case .Expect_Identifier:
		return "expected identifier"
	case .Expect_L_Paren:
		return "expected '('"
	case .Expect_R_Paren:
		return "expected ')'"
	case .Expect_L_Brace:
		return "expected '{'"
	case .Expect_R_Brace:
		return "expected '}'"
	case .Expect_Semicolon:
		return "expected ';'"
	case .Integer_Overflow:
		return "integer literal exceeds INT_MAX"
	case .Trailing_Tokens:
		return "unexpected tokens after function"
	}
	return "unknown error"
}

// Program is a function which has a name and a body, the body has a statement
// of type Return for now, it returns a expression of type Const with an int
// value
Const_Expr :: struct {
	value: int,
}

Expr :: union {
	Const_Expr,
}

Return_Stmt :: struct {
	expr: Expr,
}

Statement :: union {
	Return_Stmt,
}

Function_Decl :: struct {
	name: string,
	body: Statement,
}

Program :: struct {
	function: Function_Decl,
}
// ----------------------------------------------------------------------------

Ast :: struct {
	root: Program,
}

parse :: proc(tokens: [dynamic]lexer.token) -> (Ast, Parse_Error) {
	cursor: int

	expect :: proc(
		tokens: [dynamic]lexer.token,
		cursor: ^int,
		expected: lexer.tokentype,
	) -> (
		lexer.token,
		bool,
	) {
		if cursor^ >= len(tokens) || tokens[cursor^].type != expected {
			return {}, false
		}
		tok := tokens[cursor^]
		cursor^ += 1
		return tok, true
	}

	tok, ok := expect(tokens, &cursor, .KEYWORD)
	if !ok || tok.literal != "int" {
		return Ast{}, .Expect_Int_Keyword
	}

	tok, ok = expect(tokens, &cursor, .IDENTIFIER)
	if !ok {
		return Ast{}, .Expect_Identifier
	}
	name := tok.literal

	if _, ok = expect(tokens, &cursor, .L_PAREN); !ok {
		return Ast{}, .Expect_L_Paren
	}
	if _, ok = expect(tokens, &cursor, .R_PAREN); !ok {
		return Ast{}, .Expect_R_Paren
	}
	if _, ok = expect(tokens, &cursor, .L_BRACE); !ok {
		return Ast{}, .Expect_L_Brace
	}

	tok, ok = expect(tokens, &cursor, .KEYWORD)
	if !ok || tok.literal != "return" {
		return Ast{}, .Unexpected_Token
	}

	tok, ok = expect(tokens, &cursor, .INTEGER_LITERAL)
	if !ok {
		return Ast{}, .Unexpected_Token
	}

	value, parsed := strconv.parse_int(tok.literal, 10)
	if !parsed {
		return Ast{}, .Integer_Overflow
	}

	if _, ok = expect(tokens, &cursor, .SEMICOLON); !ok {
		return Ast{}, .Expect_Semicolon
	}
	if _, ok = expect(tokens, &cursor, .R_BRACE); !ok {
		return Ast{}, .Expect_R_Brace
	}

	if cursor != len(tokens) {
		return Ast{}, .Trailing_Tokens
	}

	return Ast {
			root = Program {
				function = Function_Decl {
					name = name,
					body = Return_Stmt{expr = Const_Expr{value = int(value)}},
				},
			},
		},
		.None
}
