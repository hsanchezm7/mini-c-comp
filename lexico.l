/* lexico.l */

%{
    #include "sintactico.tab.h"
    #include <stdio.h>
    int contador_errores = 0;
    void error();
%}

/* Macros Expresiones regulares */
D   [0-9]
L   [a-zA-Z_]
E   {D}+
ERR [^a-zA-Z_0-9+\-*\=; ()\t\r\n]

/* Opciones Flex */
%option yylineno

/* Expresiones regulares */
%%
"//"(.*)\n                           ;
"/∗"([^∗]|[∗]+[^∗/])∗[∗]∗"∗/"        ;

"var"                       { return VAR; }
"const"                     { return CONST; }

"int"                       { return INT; }
"string"                    { return STRING; }

"read"                      { return READ; }
"print"                     { return PRINT; }

"if"                        { return IF; }
"else"                      { return ELSE; }
"while"                     { return WHILE; }

"="                         { return ASIG; }
"+"                         { return ADD; }
"-"                         { return SUB; }
"*"                         { return MUL; }
"/"                         { return DIV; }


{E}                         { 
                                yylval.entero=atoi(yytext); 
                                return ENTE; 
                            }


({L}|_)({L}|{D}|_)*         { return ID; }

";"                         { return PYCO; }
","                         { return COMA; }

"("                         { return PARI; }
")"                         { return PARD; }

"{"                         { return CORI; }
"}"                         { return CORD; }

{ERR}+                      { printf("Error léxico en la línea %d: %s \n", yylineno, yytext); }

%%

void error()
{
    printf("Error en el carácter %s\n",yytext);
}