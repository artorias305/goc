package generator

import "../parser"
import "core:fmt"
import "core:strings"

generate :: proc(ast: parser.Ast) -> string {
	builder := strings.Builder{}

	name := ast.root.function.name
	fmt.sbprintf(&builder, ".globl _%s\n_%s:\n", name, name)

	body := ast.root.function.body
	switch stmt in body {
	case parser.Return_Stmt:
		value := stmt.expr.(parser.Const_Expr).value
		fmt.sbprintf(&builder, "movl    $%d, %%eax\nret", value)
	}
	return strings.to_string(builder)
}

