%{
    #include <stdio.h>
    /*
       #include "sintactico.tab.h"
       En sintactico.y no hace falta incluir este sintactico.tab.h
     */
    void yyerror();
    extern int yylex();
    int main();
    extern int yylineno;
    extern char *yytext;
%}

%union{
    int entero;
    char *cadena;
}


%token ID VAR CONST INT STRING READ PRINT IF ELSE WHILE PARI PARD CORI CORD COMA PYCO ADD SUB MUL DIV ASIG 
%token <entero> ENTE
%token <cadena> CADENA

%left ADD SUB
%left MUL DIV
%left UMENOS
%type program declarations identifier_list identifier statement_list statement print_list print_item read_list expression

%%

program : ID PARI PARD CORI declarations statement_list CORD { }

declarations : declarations VAR { } identifier_list PYCO
            | declarations CONST { } identifier_list PYCO
            | /* lambda */
            ;
            
identifier_list : identifier
                | identifier_list COMA identifier
                ;

identifier : ID                       { }
           | ID ASIG expression       { }
           ;
           
statement_list : statement_list statement
               | /* lambda */
               ;
               
statement : ID ASIG expression PYCO     {}
          | CORI statement_list CORD    {}
          | IF PARI expression PARD statement ELSE statement
          | IF PARI expression PARD statement
          | WHILE PARI expression PARD statement
          | PRINT PARI print_list PARD PYCO
          | READ PARI read_list PARD PYCO
          ;
          
print_list : print_item
           | print_list COMA print_item
           ;
            
print_item : expression
           | STRING             {}
           ;
           
read_list : ID                {} 
          | read_list COMA ID
          ;

expression : ID     {}
           | ENTE   {}
           | expression ADD expression      {}
           | expression SUB expression      {}
           | expression MUL expression      {}
           | expression DIV expression      {}
           | SUB expression                 {}
           | PARI expression PARD           {}
           ;

%%

/* 
NUM {
lisatC codigo = creaLC();
Operacion oper;
oper.op = “li”
oper.res = "$tx";
oper.arg1 = $1;
oper.arg2 = NULL;
$$ = $1;
insertaLC(codigo, finalLC(codigo), oper);
guardarResLC(codigo, "$tx");
$$ = codigo;
}

char *resIzq = recuperarResLc($1)
char *resDer = recuperarResLc($3)
concatenaLC($1, $3); */

void yyerror() {
    printf("Error sintáctico en la línea %d: %s \n", yylineno, yytext);
}

int main() {
	return yyparse();
}
