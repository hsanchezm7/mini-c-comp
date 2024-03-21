%{
    #include <stdio.h>
    #include "sintactico.tab.h"
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


%token PARI PARD PYCO SUMA MULT ASIG DIVI REST
%token <entero> ENTE
%token <cadena> IDEN
%left SUMA REST
%left MULT DIVI
%left UMENOS
%type <entero> expresion entrada


%%

entrada : 	              {$$=1;}
	| entrada {printf("Expr n. %d: ",$1);} linea        {$$=$1+1;}
        ;

linea : expresion '\n' {printf("%d\n",$1);} 
	| IDEN ASIG expresion '\n' {printf("La variable %s toma el valor %d\n",$1,$3);}
	| error '\n'
        ;

expresion : expresion SUMA termino {$$ = $1 + $3; }
          | expresion REST termino {$$ = $1 - $3;}
          | expresion MULT termino {$$ = $1 * $3;}
       	  | expresion DIVI termino {$$ = $1 / $3;}
          | PARI termino PARD {$$ = $2;}
	      | REST termino %prec UMENOS {$$=-$2;} 
          | ENTE ;

termino : termino MULT factor {$$=$1*$3;}
| termino DIVI factor {$$=$1/$3;}
| factor

;

factor : PARI expresion PARD { $$ = $2; }
       | REST factor { $$ =- $2; }
       | ENTE;

%%

void yyerror() {
    printf("Error en la línea %d: %s \n", yylineno, yytext);
}

int main() {
	return yyparse();
}
