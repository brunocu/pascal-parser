%{
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

char* infilename;
char* outfilename;


int line = 1;
int col = 1;
%}
%option case-insensitive
%option array
%option noyywrap

LETRA   [A-Za-z]
DIGITO  [0-9]
NOCERO  [1-9]
%%
"while"     |
"var"       |
"to"        |
"then"      |
"string"    |
"real"      |
"program"   |
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
"and"       |
"writeln"   |
"write"     |
"readln"    |
"read"      |
"E"         |
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
":="        |
":"         |
";"         |
","         |
"-"         |
{LETRA}     |
{DIGITO}    {
    fprintf(yyout, "%s:%d.%d:\t\"%s\"\n", infilename, line, col, yytext);
    col += yyleng;
}

[[:blank:]]         ++col;
\n|\r\n     {
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
        int infilelen = strlen(infilename);
        outfilename = malloc((infilelen + 8) * sizeof(char));
        strcpy(outfilename, infilename);
        strcpy(outfilename + infilelen, ".tokens");
        yyout = fopen(outfilename, "w");
    }
    else
        return(1);

    yylex();
}