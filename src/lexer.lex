%{
#include <stdio.h>
%}
%option array
%option noyywrap
%option debug

LETRA   [A-Za-z]
DIGITO  [0-9]
NOCERO  [1-9]
%%
"while"     /* action */
"var"       /* action */
"to"        /* action */
"then"      /* action */
"string"    /* action */
"real"      /* action */
"program"   /* action */
"procedure" /* action */
"or"        /* action */
"of"        /* action */
"not"       /* action */
"integer"   /* action */
"if"        /* action */
"function"  /* action */
"for"       /* action */
"end"       /* action */
"else"      /* action */
"downto"    /* action */
"do"        /* action */
"const"     /* action */
"boolean"   /* action */
"begin"     /* action */
"array"     /* action */
"and"       /* action */

"writeln"   /* action */
"write"     /* action */
"readln"    /* action */
"read"      /* action */

"E"         /* action */
"e"         /* action */
"$"         /* action */
">"         /* action */
"="         /* action */
"<"         /* action */
"+"         /* action */
"%"         /* action */
"#"         /* action */
"&"         /* action */
"\""        /* action */
"/"         /* action */
"*"         /* action */
"]"         /* action */
"["         /* action */
")"         /* action */
"("         /* action */
"."         /* action */
":="        /* action */
":"         /* action */
";"         /* action */
","         /* action */
"-"         /* action */

{LETRA}     /* action */
{DIGITO}    /* action */
{NOCERO}    /* action */

%%
/* User Code */
int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (!yyin)
            yyin = stdin;
    }
    else
    {
        yyin = stdin;
    }

    yylex();
}