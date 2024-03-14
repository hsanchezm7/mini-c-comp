#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;
extern int yylex();
extern char *yytext;
extern int yyleng;
FILE *fich;

int main(int argc, char *argv[]) {

    fich = fopen(argv[1], "r");
    yyin = fich;
    int tok;
    while ( (tok = yylex()) != 0 ) {
        printf("%s -> Token: %d, Leng: %d\n", yytext, tok, yyleng);
    }

}