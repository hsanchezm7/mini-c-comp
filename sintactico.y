%{
    #include <stdio.h>
    #include "sintactico.tab.h"
    void yyerror();
    extern int yylex();
    int main();
    extern int yylineno;
    extern char *yytext;

%}


%token ENTE SUMA MULT PARI PARD ASIG DIVI

%%

R : E ASIG 		    { printf("Resultado=??\n"); }

E : E SUMA T		{ $$ = $1 + $3; }
    | T			    { printf("T\n"); }
    ;

T : T MULT F		{ $$ = $1 * $3; }
    | F			    { printf("F\n"); }
    ;

F : PARI E PARD		{ printf("(E)"); }
    | ENTE			{ printf("E"); }
    ;

%%

void yyerror() {
    printf("Error en la línea %d: %s \n", yylineno, yytext);
}

int yylex() {
}

int main() {
	return yyparse();
}
