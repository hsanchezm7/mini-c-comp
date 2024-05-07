%{
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    /* Listas de código y de símbolos */
    #include "listaCodigo.h"
    #include "listaSimbolos.h"

    /* Opciones de Yacc */
    extern int yylex();
    extern int yylineno;  
    extern int errores_lexicos;  
    void yyerror(const char *msg);

    /* Contadores de errores */
    int errores_sintacticos = 0;
    int errores_semanticos = 0;

    /* Estructuras de datos */
    Lista l;
    Tipo t;

    /* Registros */
    char registros[10];
    
    /* Otros */
    void imprimirLS();
    int analisis_ok();
    char *obtenerReg();
    void liberarReg(char *reg);
    void imprimirLC(ListaC codigo);
    int contadorEtiquetas=1;
    int contador_str = 0;
    char *obtenerEtiqueta();
%}

%code requires {
    #include "listaCodigo.h"
}

/* TAD de la gramática */
%union {
    char *cadena;
    ListaC codigo;
}

/* Tokens */
%token <cadena> ID
%token <cadena> ENTE
%token <cadena> STRING

%token ASIG
%token ADD
%token SUB
%token MUL
%token DIV

%token VAR
%token CONST

%token PRINT
%token READ

%token PARI
%token PARD
%token CORI
%token CORD

%token PYCO
%token COMA   

%token IF
%token ELSE
%token WHILE

/* Extras */
%token DO
%token FOR

/* Tipos no terminales */
%type <codigo> expression statement print_item print_list read_list asig inicializar statement_list program declarations identifier_list

/* Reglas de precedencia y operación (asociatividad) */
%left ADD SUB
%left MUL DIV
%precedence UMINUS

%start program
%define parse.error verbose

%expect 1

%%

/* Reglas de producción */

program : inicializar ID PARI PARD CORI declarations statement_list CORD
                                                                        {
                                                                            if (analisis_ok()){
                                                                                $$ = creaLC();
                                                                                concatenaLC($$, $6);
                                                                                concatenaLC($$, $7);
                                                                                liberaLC($6);
                                                                                liberaLC($7);
                                                                                imprimirLS();
                                                                                imprimirLC($$);
                                                                                liberaLS(l);
                                                                                liberaLC($$);
                                                                            }
                                                                        }
        ;

inicializar : %empty 
                    {
                        l = creaLS();
                        memset(registros, 0, 10);
                    }
            ;

declarations : declarations VAR { t = VARIABLE; } identifier_list PYCO 
                                                                    {
                                                                        if (analisis_ok()){
                                                                            $$ = creaLC();
                                                                            concatenaLC($$, $1);
                                                                            concatenaLC($$, $4);
                                                                            liberaLC($1);
                                                                            liberaLC($4);
                                                                        }    
                                                                    }
             | declarations CONST { t = CONSTANTE; } identifier_list PYCO
                                                                    {
                                                                        if (analisis_ok()){
                                                                                $$ = creaLC();
                                                                                concatenaLC($$, $1);
                                                                                concatenaLC($$, $4);
                                                                                liberaLC($1);
                                                                                liberaLC($4);
                                                                        }
                                                                }
        | %empty            { 
                if (analisis_ok()){
                        $$ = creaLC();
                }
        }
        ;

identifier_list : asig      { if (analisis_ok()){
                                $$ = $1;
                                }
                        }
        |   identifier_list COMA asig    { if (analisis_ok()){
                                                $$ = creaLC();
                                                concatenaLC($$, $1);
                                                concatenaLC($$, $3);
                                                liberaLC($1);
                                                liberaLC($3);
                                        }                      
                                        }
        ;

asig : ID     {
                PosicionLista p = buscaLS(l,$1);
                if (p != finalLS(l)) {
                        printf("Error en linea %d: identificador %s redeclarado\n", yylineno, $1);
                        errores_semanticos++;
                }
                else {
                        Simbolo aux;
                        aux.nombre = $1;
                        aux.tipo = t;
                        insertaLS(l,finalLS(l),aux);
                        if (analisis_ok()){
                                $$ = creaLC();
                        }
                }
                
                
                }
        | ID ASIG expression       {
                PosicionLista p = buscaLS(l,$1);
                if (p != finalLS(l)) {
                        printf("Error en linea %d: identificador %s redeclarado\n", yylineno, $1);
                        errores_semanticos++;
                }
                else {
                        Simbolo aux;
                        aux.nombre = $1;
                        aux.tipo = t;
                        insertaLS(l,finalLS(l),aux);
                        if (analisis_ok()){
                                $$ = $3;
                                Operacion o;
                                o.op = "sw";
                                o.res = recuperaResLC($3);
                                char *dir;
                                asprintf(&dir, "_%s", $1);
                                o.arg1 = dir;
                                o.arg2 = NULL;
                                insertaLC($$, finalLC($$), o);
                                liberarReg(o.res);
                        }
                }
                }
        ;

statement_list : statement_list  statement      { if (analisis_ok()){
                                                        $$ = $1;
                                                        concatenaLC($$, $2);
                                                        liberaLC($2);
                                                }        
                                                }
        | %empty                                { if (analisis_ok()){
                                                        $$ = creaLC(); 
                                                }
                                                }
        ;

statement : ID ASIG expression PYCO    {
                                        PosicionLista p = buscaLS(l, $1);
                                        if (p == finalLS(l)){
                                                printf("Error en linea %d: identificador %s no encontrado\n", yylineno, $1);
                                                errores_semanticos++;
                                        } else {
                                                Simbolo aux = recuperaLS(l, p);
                                                if (aux.tipo == CONSTANTE){
                                                        printf("Error en linea %d: identificador %s es constante\n", yylineno, $1);
                                                        errores_semanticos++;  
                                                }
                                        }
                                        if (analisis_ok()){
                                                        $$ = $3;
                                                        Operacion o;
                                                        o.op = "sw";
                                                        o.res = recuperaResLC($3);
                                                        char *dir;
                                                        asprintf(&dir, "_%s", $1);
                                                        o.arg1 = dir;
                                                        o.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o);
                                                        liberarReg(o.res);
                                        }
                                  
                                        }
        | CORI statement_list CORD    {   if (analisis_ok()){
                                                $$ = $2;
                                        }
                                        }
        | IF PARI expression PARD statement ELSE statement    {if (analisis_ok()){
                                                                        $$ = $3;
                                                                        Operacion o;
                                                                        o.op = "beqz";
                                                                        o.res = recuperaResLC($3);
                                                                        char *etiqueta1 = obtenerEtiqueta();
                                                                        o.arg1 = etiqueta1;
                                                                        o.arg2 = NULL;
                                                                        insertaLC($$, finalLC($$), o);
                                                                        concatenaLC($$, $5);
                                                                        liberarReg(o.res);
                                                                        Operacion o1;
                                                                        o1.op = "b";
                                                                        char *etiqueta2 = obtenerEtiqueta();
                                                                        o1.res = etiqueta2;
                                                                        o1.arg1 = NULL;
                                                                        o1.arg2 = NULL;
                                                                        insertaLC($$, finalLC($$), o1);
                                                                        Operacion o2;
                                                                        o2.op = "etiq";
                                                                        o2.res = etiqueta1;
                                                                        o2.arg1 = NULL;
                                                                        o2.arg2 = NULL;
                                                                        insertaLC($$, finalLC($$), o2);
                                                                        concatenaLC($$, $7);
                                                                        Operacion o3;
                                                                        o3.op = "etiq";
                                                                        o3.res = etiqueta2;
                                                                        o3.arg1 = NULL;
                                                                        o3.arg2 = NULL;
                                                                        insertaLC($$, finalLC($$), o3);
                                                                        liberaLC($5);
                                                                        liberaLC($7);
                                                                }
                                                                
                                                                }
        | IF PARI expression PARD statement     {if (analisis_ok()){
                                                        $$ = $3;
                                                        char *etiqueta1 = obtenerEtiqueta();
                                                        Operacion o;
                                                        o.op = "beqz";
                                                        o.res = recuperaResLC($3);
                                                        o.arg1 = etiqueta1;
                                                        o.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o);
                                                        concatenaLC($$, $5);
                                                        liberarReg(o.res);
                                                        liberaLC($5);
                                                        Operacion o1;
                                                        o1.op = "etiq";
                                                        o1.res = etiqueta1;
                                                        o1.arg1 = NULL;
                                                        o1.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o1);
                                                }
                                                
                                                }
        | WHILE PARI expression PARD statement  {if (analisis_ok()){
                                                        $$ = creaLC();
                                                        char * etiqueta1 = obtenerEtiqueta();
                                                        Operacion o;
                                                        o.op = "etiq";
                                                        o.res = etiqueta1;
                                                        o.arg1 = NULL;
                                                        o.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o);
                                                        concatenaLC($$, $3);
                                                        Operacion o1;
                                                        o1.op = "beqz";
                                                        o1.res = recuperaResLC($3);
                                                        char *etiqueta2 = obtenerEtiqueta();
                                                        o1.arg1 = etiqueta2;
                                                        o1.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o1);
                                                        concatenaLC($$, $5);
                                                        Operacion o2;
                                                        o2.op = "b";
                                                        o2.res = etiqueta1;
                                                        o2.arg1 = NULL;
                                                        o2.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o2);
                                                        Operacion o3;
                                                        o3.op = "etiq";
                                                        o3.res = etiqueta2;
                                                        o3.arg1 = NULL;
                                                        o3.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o3);
                                                        liberaLC($3);
                                                        liberaLC($5);
                                                        liberarReg(o1.res);
                                                }
                                                
                                                }
        | PRINT PARI print_list PARD PYCO                {if (analisis_ok()){
                                                        $$ = $3;
                                                }       
                                                }
        | READ read_list PYCO                  {if (analisis_ok()){
                                                        $$ = $2;
                                                }

                                                }
        | DO statement WHILE PARI expression PARD PYCO {if (analisis_ok()){
                                                                $$ = creaLC();
                                                                char * etiqueta1 = obtenerEtiqueta();
                                                                Operacion o1;
                                                                o1.op = "etiq";
                                                                o1.res = etiqueta1;
                                                                o1.arg1 = NULL;
                                                                o1.arg2 = NULL;
                                                                insertaLC($$, finalLC($$), o1);
                                                                concatenaLC($$, $2);
                                                                liberaLC($2);
                                                                concatenaLC($$, $5);
                                                                Operacion o3;
                                                                o3.op = "bnez";
                                                                o3.res = recuperaResLC($5);
                                                                o3.arg1 = etiqueta1;
                                                                o3.arg2 = NULL;
                                                                insertaLC($$, finalLC($$), o3);
                                                                liberaLC($5);
                                                                liberarReg(o3.res);
                                                        }
                                                        }
        | FOR PARI ENTE PARD statement         { if (analisis_ok()){
                                                        $$ = creaLC();
                                                        char * indice = obtenerReg();
                                                        Operacion o;
                                                        o.op = "li";
                                                        o.res = indice;
                                                        o.arg1 = "0";
                                                        o.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o);
                                                        char * etiqueta1 = obtenerEtiqueta();
                                                        char * etiqueta2 = obtenerEtiqueta();
                                                        Operacion o1;
                                                        o1.op = "etiq";
                                                        o1.res = etiqueta1;
                                                        o1.arg1 = NULL;
                                                        o1.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o1);
                                                        Operacion o2;
                                                        o2.op = "bge";
                                                        o2.res = indice;
                                                        o2.arg1 = $3;
                                                        o2.arg2 = etiqueta2;
                                                        insertaLC($$, finalLC($$), o2);
                                                        concatenaLC($$, $5);
                                                        Operacion o6;
                                                        o6.op = "addi";
                                                        o6.res = indice;
                                                        o6.arg1 = indice;
                                                        o6.arg2 = "1";
                                                        insertaLC($$, finalLC($$), o6);
                                                        Operacion o4;
                                                        o4.op = "b";
                                                        o4.res = etiqueta1;
                                                        o4.arg1 = NULL;
                                                        o4.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o4);
                                                        Operacion o5;
                                                        o5.op = "etiq";
                                                        o5.res = etiqueta2;
                                                        o5.arg1 = NULL;
                                                        o5.arg2 = NULL;
                                                        insertaLC($$, finalLC($$), o5);
                                                        liberaLC($5);
                                                        liberarReg(indice);
                                                }
                                               
                                                }
        ;
print_list : print_item             {if (analisis_ok()){
                                        $$ = $1;
                                }
                                }
        | print_list COMA print_item {
                                        if (analisis_ok()){
                                                $$ = $1;
                                                concatenaLC($$, $3);
                                                liberaLC($3);
                                        }
                                        
                                        }                                             
        ;
print_item : expression             {
                                        if (analisis_ok()){
                                                $$ = $1;
                                                Operacion o;
                                                o.op = "move";
                                                o.res = "$a0";
                                                o.arg1 = recuperaResLC($1);
                                                o.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o);
                                                liberarReg(o.arg1);
                                                Operacion o1;
                                                o1.op = "li";
                                                o1.res = "$v0";
                                                o1.arg1 = "1";
                                                o1.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o1);
                                                Operacion o2;
                                                o2.op = "syscall";
                                                o2.arg1 = NULL;
                                                o2.arg2 = NULL;
                                                o2.res = NULL;
                                                insertaLC($$, finalLC($$), o2);
                                        }
                                        
                                        }
        |       STRING                  {
                                        if (analisis_ok()){
                                                Simbolo aux;
                                                contador_str++;
                                                aux.nombre = $1;
                                                aux.tipo = CADENA;
                                                aux.valor = contador_str;
                                                insertaLS(l,finalLS(l),aux); 
                                                $$ = creaLC();
                                                char * etiqueta1;
                                                asprintf(&etiqueta1, "$str%d", aux.valor);
                                                Operacion o;
                                                o.op = "la";
                                                o.res = "$a0";
                                                o.arg1 = etiqueta1;
                                                o.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o);
                                                Operacion o1;
                                                o1.op = "li";
                                                o1.res = "$v0";
                                                o1.arg1 = "4";
                                                o1.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o1);
                                                Operacion o2;
                                                o2.op = "syscall";
                                                o2.res = NULL;
                                                o2.arg1 = NULL;
                                                o2.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o2);
                                        }
                                        
                                        }
        ;
read_list : ID                    {
                                        PosicionLista p = buscaLS(l, $1);
                                        if (p == finalLS(l)){
                                                printf("Error en linea %d: identificador %s no encontrado\n", yylineno, $1);
                                                errores_semanticos++;
                                        } else {
                                                Simbolo aux = recuperaLS(l, p);
                                                if (aux.tipo == CONSTANTE){
                                                        printf("Error en linea %d: identificador %s es constante\n", yylineno, $1);
                                                        errores_semanticos++;  
                                                }
                                        }
                                        if (analisis_ok()){
                                                $$ = creaLC();
                                                Operacion o;
                                                o.op = "li";
                                                o.res = "$v0";
                                                o.arg1 = "5";
                                                o.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o);
                                                Operacion o1;
                                                o1.op = "syscall";
                                                o1.res = NULL;
                                                o1.arg1 =NULL;
                                                o1.arg2  =NULL;
                                                insertaLC($$, finalLC($$), o1);
                                                Operacion o2;
                                                o2.op = "sw";
                                                o2.res = "$v0";
                                                char *dir;
                                                asprintf(&dir, "_%s", $1);
                                                o2.arg1 = dir;
                                                o2.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o2);
                                        }

                                        }
        | read_list COMA ID {
                                PosicionLista p = buscaLS(l, $3);
                                        if (p == finalLS(l)){
                                                printf("Error en linea %d: identificador %s no encontrado\n", yylineno, $3);
                                                errores_semanticos++;
                                        } else {
                                                Simbolo aux = recuperaLS(l, p);
                                                if (aux.tipo == CONSTANTE){
                                                        printf("Error en linea %d: identificador %s es constante\n", yylineno, $3);
                                                        errores_semanticos++;  
                                                }
                                        }
                                        if (analisis_ok()){
                                                $$ = $1;
                                                Operacion o;
                                                o.op = "li";
                                                o.res = "$v0";
                                                o.arg1 = "5";
                                                o.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o);
                                                Operacion o1;
                                                o1.op = "syscall";
                                                o1.res = NULL;
                                                o1.arg1 = NULL;
                                                o1.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o1);
                                                Operacion o2;
                                                o2.op = "sw";
                                                o2.res = "$v0";
                                                char *dir;
                                                asprintf(&dir, "_%s", $3);
                                                o2.arg1 = dir;
                                                o2.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o2);
                                        }
                                }
        ;
expression : expression ADD expression {
                                        if (analisis_ok()){
                                                $$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion o;
                                                o.op = "add";
                                                o.res = recuperaResLC($1);
                                                o.arg1 = recuperaResLC($1);
                                                o.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), o);
                                                liberarReg(o.arg2);
                                                liberaLC($3);
                                                
                                        }
                                        }
        | expression SUB expression {
                                        if (analisis_ok()){
                                                $$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion o;
                                                o.op = "sub";
                                                o.res = recuperaResLC($1);
                                                o.arg1 = recuperaResLC($1);
                                                o.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), o);
                                                liberarReg(o.arg2);
                                                liberaLC($3);
                                                
                                        }
                                        
                                        }
        | expression MUL expression     {
                                        if (analisis_ok()){
                                                $$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion o;
                                                o.op = "mul";
                                                o.res = recuperaResLC($1);
                                                o.arg1 = recuperaResLC($1);
                                                o.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), o);
                                                liberarReg(o.arg2);
                                                liberaLC($3);
                                                
                                        }
                                        
                                        }
        | expression DIV expression   { 
                                        if (analisis_ok()){
                                                $$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion o;
                                                o.op = "div";
                                                o.res = recuperaResLC($1);
                                                o.arg1 = recuperaResLC($1);
                                                o.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), o);
                                                liberarReg(o.arg2);
                                                liberaLC($3);
                                                
                                        }
                                        
                                        }
        | SUB expression   %prec UMINUS { 
                                        if (analisis_ok()){
                                                $$ = $2;
                                                Operacion o;
                                                o.op = "neg";
                                                o.res = recuperaResLC($2);
                                                o.arg1 = recuperaResLC($2);
                                                o.arg2 = NULL;
                                                insertaLC($$, finalLC($$), o);
                                                
                                        }
                                        
                                        }
        | PARI expression PARD        {
                                        if (analisis_ok()){
                                                $$ = $2;
                                        }
                                                        }
        | ID                  {
                                PosicionLista p = buscaLS(l, $1);
                                if (p == finalLS(l)){
                                        printf("Error en linea %d: identificador %s no encontrado\n", yylineno, $1);
                                        errores_semanticos++;
                                } 
                                if (analisis_ok()){
                                        $$ = creaLC();
                                        Operacion o;
                                        o.op = "lw";
                                        o.res = obtenerReg();
                                        char *dir;
                                        asprintf(&dir, "_%s", $1);
                                        o.arg1 = dir;
                                        o.arg2 = NULL;
                                        insertaLC($$, finalLC($$), o);
                                        guardaResLC($$, o.res);
                                }
                                }
        | ENTE                  {
                                if (analisis_ok()){
                                        $$ = creaLC();
                                        Operacion o;
                                        o.op = "li";
                                        o.res = obtenerReg();
                                        o.arg1 = $1;
                                        o.arg2 = NULL;
                                        insertaLC($$, finalLC($$), o);
                                        guardaResLC($$, o.res);
                                }
                                
                                }
        ;


%%

void yyerror(const char *msg){
        errores_sintacticos++;
    printf("Error en la linea %d: %s\n", yylineno, msg);
}


void imprimirLS(){
  PosicionLista p = inicioLS(l);
  printf(".data\n");
  while (p != finalLS(l)) {
    Simbolo aux = recuperaLS(l,p);
    if (aux.tipo == CADENA){
        printf("$str%d:\n       .asciiz %s\n",aux.valor, aux.nombre);
    } else{
        printf("_%s:\n          .word 0\n",aux.nombre); 
    }   
    p = siguienteLS(l,p);
  }
  printf(".text\n.globl main\nmain:\n");
}

int analisis_ok(){
        return  (errores_lexicos + errores_semanticos + errores_sintacticos) == 0;
}

char *obtenerReg(){
        int i;
        for (i = 0; i < 10; i++){
                if (registros[i] == 0){
                        break;
                }
        }
        if (i == 10){
                printf("Error fatal: no quedan registros libres\n");
                exit(1);
        }
        registros[i] = 1;
        char *reg;
        asprintf(&reg, "$t%d", i);
        return reg;
}

void liberarReg(char *reg){
        int i = reg[2] - '0';
        registros[i] = 0;
}

void imprimirLC(ListaC codigo){
        PosicionListaC p = inicioLC(codigo);
        Operacion oper;
        while (p != finalLC(codigo)) {
                oper = recuperaLC(codigo,p);
                if (!strcmp(oper.op, "etiq")){
                        printf("%s:\n", oper.res);
                }else{
                        printf("        %s",oper.op);
                        if (oper.res) printf(" %s",oper.res);
                        if (oper.arg1) printf(",%s",oper.arg1);
                        if (oper.arg2) printf(",%s",oper.arg2);
                        printf("\n");
                }
                p = siguienteLC(codigo,p);
        }
}

char *obtenerEtiqueta(){
            char aux[32];
            sprintf(aux, "$l%d", contadorEtiquetas++);
            return strdup(aux);
}