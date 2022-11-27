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
"string"    return TOK_STRING;
"real"      return TOK_REAL;
"procedure" return PROCEDURE;
"or"        return TOK_OR;
"of"        return OF;
"not"       return NOT;
"integer"   return TOK_INTEGER;
"if"        return IF;
"function"  return FUNCTION;
"for"       return FOR;
"else"      return ELSE;
"downto"    return DOWNTO;
"do"        return DO;
"boolean"   return TOK_BOOLEAN;
"array"     return ARRAY;
"and"       return TOK_AND;

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
{LETRA}({DIGITO}|{LETRA})*  return TOK_IDENTIFICADOR;
{ENTERO}                    return ENTERO;

[[:blank:]]+    /**/
\n|\r\n         /**/

%%
/* User Code */
