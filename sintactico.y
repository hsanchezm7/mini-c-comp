%{
    #include <stdio.h>
    #include <stdlib.h>    
    #include "listaSimbolos.h"
    #include “listaCodigo.h” 
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

%code requires {
#include “listaCodigo.h”
}

%union{
    int entero;
    char *cadena;
    Tipo *tipo;
}

%union {
    char *str;
    ListaC codigo;
}

%token ID VAR CONST INT STRING READ PRINT IF ELSE WHILE PARI PARD CORI CORD COMA PYCO ADD SUB MUL DIV ASIG 
%token <entero> ENTE
%token <cadena> CADENA

%left ADD SUB
%left MUL DIV
%left UMENOS

%type program declarations identifier_list identifier statement_list statement print_list print_item read_list 
%type <codigo> expression

%%

program : ID PARI PARD CORI {tS = creaLS();} declarations statement_list CORD 
        {
          
        }
        ;

declarations : declarations VAR {tipo= VARIABLE;} identifier_list PYCO
                                                                    {
                                                                      $$=creaLC();
                                                                      concatenaLC($$,$1);
                                                                      liberaLC($1);
                                                                      concatenaLC($$,$4);
                                                                      liberaLC($4);
                                                                    }
            | declarations CONST {tipo = CONSTANTE;} identifier_list PYCO
                                                                    {
                                                                      $$=creaLC();
                                                                      concatenaLC($$,$1);
                                                                      liberaLC($1);
                                                                      concatenaLC($$,$4);
                                                                      liberaLC($4);
                                                                    }
            | /* lambda */
            ;
            
identifier_list : identifier
                | identifier_list COMA identifier
                ;

identifier : ID                       { Simbolo aux;
                                        aux.nombre = $1;
                                        aux.tipo= tipo;
                                        insertaLS(tS,finalLS(tS),aux);}
           | ID ASIG expression       {Simbolo aux;
                                        aux.nombre = $1;
                                        aux.tipo= tipo;
                                        insertaLS(tS,finalLS(tS),aux);}
           ;
           
statement_list : statement_list statement
               | {
               
                }

               ;
               
statement : ID ASIG expression PYCO     {Operacion oper;
                                        oper.op = "sw"; 
                                        oper.res=recuperaLC($3);
                                        insertaLC($$,finalLC(),oper);
                                        liberaLC($3);
                                        }

          | CORI statement_list CORD    {$$ = $2;}
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
           
read_list : ID                {buscaLS(tS,$1)} 
          | read_list COMA ID   { buscaLS(tS,$3)}
          ;

expression : ID     {$$ = $1;
                    Operacion oper; 
                    oper.op = "lw"; 
                    oper.res = recuperaLC($1);
                    oper.arg1= concatenaLC("_", $1);
                    insertaLC($$,finalLC($$),oper); 
                    liberaLC($1);
                    }
        
           | ENTE   {$$ = $1;
                    Operacion oper; 
                    oper.op = "li"; 
                    oper.res = recuperaLC($1);
                    oper.arg1=recuperaLC($1);
                    insertaLC($$,finalLC($$),oper); 
                    liberaLC($1);}

            //li $t0, 1
            //lw $t1, _b
            //add $t0, $t0, $t1
            //neg $t0, $t0
            
           | expression ADD expression      {$$= creaLC();
                                            $$ = $1; 
                                            concatenaLC($$,$3);
                                            Operacion oper; 
                                            oper.op = "add"; 
                                            oper.res = recuperaLC($1);
                                            oper.arg1 = recuperaLC($1); 
                                            oper.arg2 = recuperaLC($3);
                                            insertaLC($$,finalLC($$),oper); 
                                            liberaLC($1);
                                            liberaLC($3);
                                            liberarReg(oper.arg2);
                                            }

           | expression SUB expression      {$$= creaLC();
                                            $$ = $1; 
                                            concatenaLC($$,$3);
                                            Operacion oper; 
                                            oper.op = "sub"; 
                                            oper.res = recuperaLC($1);
                                            oper.arg1 = recuperaLC($1); 
                                            oper.arg2 = recuperaLC($3);
                                            insertaLC($$,finalLC($$),oper); 
                                            liberaLC($1);
                                            liberaLC($3);
                                            liberarReg(oper.arg2); 
                                            }

           | expression MUL expression      {$$= creaLC();
                                            $$ = $1; 
                                            concatenaLC($$,$3);
                                            Operacion oper; 
                                            oper.op = "mul"; 
                                            oper.res = recuperaLC($1);
                                            oper.arg1 = recuperaLC($1); 
                                            oper.arg2 = recuperaLC($3);
                                            insertaLC($$,finalLC($$),oper); 
                                            liberaLC($1);
                                            liberaLC($3);
                                            liberarReg(oper.arg2); 
                                            }
                                            
           | expression DIV expression      {$$= creaLC();
                                            $$ = $1; 
                                            concatenaLC($$,$3);
                                            Operacion oper; 
                                            oper.op = "div"; 
                                            oper.res = recuperaLC($1);
                                            oper.arg1 = recuperaLC($1); 
                                            oper.arg2 = recuperaLC($3);
                                            insertaLC($$,finalLC($$),oper);
                                            liberaLC($1);
                                            liberaLC($3);
                                            liberarReg(oper.arg2); 
                                            }

           | SUB expression                 {$$= creaLC();
                                            $$ = $2; 
                                            Operacion oper; 
                                            oper.op = "neg"; 
                                            oper.res = recuperaLC($2);
                                            oper.arg1 = recuperaLC($2);
                                            insertaLC($$,finalLC($$),oper);
                                            liberaLC($2);
                                            }

           | PARI expression PARD           {$$ = $2;}
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

//Imprimir la lista del codigo 
    void imprimirLC(ListaC codigo1){
        printf(".text\n.globl main\n main: \n"); 
        Operacion oper; 
        PosicionListaC p = inicioLC(codigo1);
         while (p != finalLC(codigo1)) {
            oper = recuperaLC(codigo1,p);
            if(!strcmp(oper.op, "etiq")){
                printf(" %s:",oper.res);
            }else{
            printf("\t%s",oper.op);
            if (oper.res) printf(" %s",oper.res);
                if (oper.arg1) printf(",%s",oper.arg1);
                    if (oper.arg2) printf(",%s",oper.arg2);
            }

                     printf("\n");
                    p = siguienteLC(codigo1,p);
        }
        printf("\tli $v0 , 10\n\tsyscall\n"); 
    }

int main() {
	return yyparse();
}
