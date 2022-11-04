%{
#include "parser.tab.h"
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

char* infilename;
char* outfilename;


int line = 1;
int col = 1;

#define TOKEN(t)    {                                                                               \
                        fprintf(yyout, "%s:%d.%d:\t%s \'%s\'\n", infilename, line, col, t, yytext); \
                        col += yyleng;                                                              \
                    }
%}
%option case-insensitive
%option array
%option noyywrap

LETRA   [A-Za-z]
DIGITO  [0-9]
NOCERO  [1-9]
ENTERO  ({NOCERO}{DIGITO}*)
%%
"program"   return PROGRAM;
"while"     |
"var"       |
"to"        |
"then"      |
"string"    |
"real"      |
"procedure" |
"or"        |
"of"        |
"not"       |
"integer"   |
"if"        |
"function"  |
"for"       |
"end"       |
"else"      |
"downto"    |
"do"        |
"const"     |
"boolean"   |
"begin"     |
"array"     |
"and"       TOKEN("keyword");

"writeln"   |
"write"     |
"readln"    |
"read"      TOKEN("instruccion");

".."        |
":="        { /* que valor darle a cadenas de dos ? */ }

"$"         |
">"         |
"="         |
"<"         |
"+"         |
"%"         |
"#"         |
"&"         |
"\""        |
"/"         |
"*"         |
"]"         |
"["         |
")"         |
"("         |
"."         |
":"         |
";"         |
","         |
"-"         return *yytext;

{LETRA}({DIGITO}|{LETRA})*  return IDENTIFICADOR;
"\""[[:alnum:]]*"\""        TOKEN("cadena");
("+"|"-")?{ENTERO}          TOKEN("entero");
("+"|"-")?{ENTERO}"."{ENTERO}("e"("+"|"-")?{ENTERO})?   TOKEN("real");

[[:blank:]]+    col += yyleng;
\n|\r\n         {
                    ++line;
                    col = 1;
                }

%%
/* User Code */
int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        infilename = strdup(argv[1]);
        yyin = fopen(infilename, "r");
        if (!yyin)
            return(EINVAL);
        printf("Reconociendo: %s\n", infilename);
        int infilelen = strlen(infilename);
        outfilename = malloc((infilelen + 8) * sizeof(char));
        strcpy(outfilename, infilename);
        strcpy(outfilename + infilelen, ".tokens");
        yyout = fopen(outfilename, "w");
        printf("Generando: %s\n", outfilename);
    }
    else
        return(1);

    yylex();
}