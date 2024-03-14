/* lexico.l */

%{
    #include "sintactico.tab.h"
    #include "lexico.h"
    #include <stdio.h>
    int contador_errores = 0;
    //      "/*"([^*]|[*]+[^*/])*[*]*"*/"          { return MULTI; }
%}

/* Macros Expresiones regulares */
D   [0-9]
L   [a-zA-z]
ERR [^a-zA-z_0-9+\-*/=;() \t\r\n]

/* Opciones Flex */
%option yylineno

%%

 /* Expresiones regulares */

"main"              { return MAIN; }
"print"             { return PRINT; }
"var"               { return VAR; }
"const"             { return CONST; }
"if"                { return IF; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"read"              { return READ; }


{L}+                { return IDEN; }

"="                 { return ASIG; }
"+"                 { return SUMA; }
"-"                 { return REST; }
"*"                 { return MULT; }
"/"                 { return DIVI; }


{D}+                { yylval=atoi(yytext); return ENTE; }

"//"(.*)\n          { return COMENT; }
";"                 { return PYCO; }
","                 { return COMA; }

"/*"(.|\n)*"*/"     { return MULT; }

"("                 { return PARI; }
")"                 { return PARD; }

"{"                 { return CORI; }
"}"                 { return CORD; }

{ERR}+              { printf("Error en la línea %d: %s \n", yylineno, yytext); }

%%