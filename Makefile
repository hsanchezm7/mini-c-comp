calc : lex.yy.c sintactico.tab.c
	gcc lex.yy.c sintactico.tab.c -lfl -o calc

lex.yy.c : sintactico.tab.h lexico.l
	flex lexico.l

sintactico.tab.h sintactico.tab.c: sintactico.y
	bison -d sintactico.y

clean :
	rm sintactico.tab.h sintactico.tab.c lex.yy.c
