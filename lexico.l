/* Analizador léxico */
%{
    #include <stdio.h>
    #include "sintactico.tab.h"
    void error_lexico();
    void error_comentario();
    int inicio_coment;   
    int errores_lexicos = 0;   
%}

/* Macros Expresiones regulares */
D       [0-9]
L       [a-zA-Z_]
E       {D}+
ERR     [^a-zA-Z_0-9+\-*\=; ()\t\r\n,{}]

/* Opciones Flex */
%option yylineno

%%

 /* Expresiones regulares  */

[ \n\t\r]+                           ;   
"//"(.*)\n                           ;
"/∗"([^∗]|[∗]+[^∗/])∗[∗]∗"∗/"        ;

"var"                       { return VAR; }
"const"                     { return CONST; }

"read"                      { return READ; }
"print"                     { return PRINT; }

"if"                        { return IF; }
"else"                      { return ELSE; }
"while"                     { return WHILE; }

 /* Extras  */
"do"                        { return DO; }
"for"                       { return FOR; }

({L}|_)({L}|{D}|_)*         { yylval.cadena = strdup(yytext);
                            return ID; }

"="                         { return ASIG; }
"+"                         { return ADD; }
"-"                         { return SUB; }
"*"                         { return MUL; }
"/"                         { return DIV; }

";"                         { return PYCO; }
","                         { return COMA; }

"("                         { return PARI; }
")"                         { return PARD; }

"{"                         { return CORI; }
"}"                         { return CORD; }

{E}                         { 
                                yylval.cadena = strdup(yytext);
                                return ENTE; 
                            }

\"([^\"\n\r]|\\”)+\"        {
                                yylval.cadena = strdup(yytext);
                                return STRING; 
                            }

 /* Detección de errores */
{ERR}+                      {error_lexico(); }

%%

void error_lexico(){
    errores_lexicos++;
    printf("Error léxico en la línea %d: %s \n", yylineno, yytext);
}