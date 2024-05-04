miniC : lex.yy.c sintactico.tab.c listaCodigo.c listaSimbolos.c
	gcc lex.yy.c sintactico.tab.c listaCodigo.c listaSimbolos.c -ll -o miniC

lex.yy.c : sintactico.tab.h lexico.l
	flex lexico.l

sintactico.tab.h sintactico.tab.c: sintactico.y
	bison -d sintactico.y

clean :
	rm -f sintactico.tab.h sintactico.tab.c lex.yy.c miniC
