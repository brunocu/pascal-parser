%{
#include "parser.tab.h"
#include <stdio.h>
#include <errno.h>

%}
%option case-insensitive
%option array
%option noyywrap
%option nodefault

LETRA   [A-Za-z]
DIGITO  [0-9]
NOCERO  [1-9]
ENTERO  ({NOCERO}{DIGITO}*)
%%
"program"   return PROGRAM;
"begin"     return PBEGIN;
"end"       return END;
"var"       return VAR;
"const"     return CONST;
"while"     return WHILE;
"to"        return TO;
"then"      return THEN;
"string"    return STRING;
"real"      return REAL;
"procedure" return PROCEDURE;
"or"        return OR;
"of"        return OF;
"not"       return NOT;
"integer"   return INTEGER;
"if"        return IF;
"function"  return FUNCTION;
"for"       return FOR;
"else"      return ELSE;
"downto"    return DOWNTO;
"do"        return DO;
"boolean"   return BOOLEAN;
"array"     return ARRAY;
"and"       return AND;

"writeln"   return WRITELN;
"write"     return WRITE;
"readln"    return READLN;
"read"      return READ;

".."        return TWO_DOTS;
":="        return ASSIGNMENT;

"$"         |
">"         |
"="         |
"<"         |
"+"         |
"%"         |
"#"         |
"&"         |
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

"\""[][#$%&*+,./:;<=>{}[:alnum:][:blank:]-]*"\""    return CADENA;
{LETRA}({DIGITO}|{LETRA})*  return IDENTIFICADOR;
{ENTERO}                    return ENTERO;

[[:blank:]]+    /**/
\n|\r\n         /**/

%%
/* User Code */
int main(int argc, char *argv[])
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (!yyin)
            return(EINVAL);
        printf("Analizando: %s\n", argv[1]);
    }
    else
        return(1);

    yyparse();
    puts("Entrada válida");
}