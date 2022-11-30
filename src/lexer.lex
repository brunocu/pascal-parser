%{
#include "parser.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

/**
 * Sets and returns the semantic value yylval of the token to the token kind code.
*/
#define TOKEN(t) (yylval.t = t)
%}
%option case-insensitive
%option array
%option noyywrap
%option nodefault
/* %option debug */

LETRA   [A-Za-z]
DIGITO  [0-9]
NOCERO  [1-9]
ENTERO  ({NOCERO}{DIGITO}*)
%%
"and"       return TOKEN(TOK_AND);
"array"     return TOKEN(ARRAY);
"begin"     return TOKEN(PBEGIN);
"boolean"   return TOKEN(TOK_BOOLEAN);
"const"     return TOKEN(CONST);
"do"        return TOKEN(DO);
"downto"    return TOKEN(TOK_DOWNTO);
"else"      return TOKEN(ELSE);
"end"       return TOKEN(END);
"for"       return TOKEN(FOR);
"function"  return TOKEN(FUNCTION);
"if"        return TOKEN(IF);
"integer"   return TOKEN(TOK_INTEGER);
"not"       return TOKEN(NOT);
"of"        return TOKEN(OF);
"or"        return TOKEN(TOK_OR);
"procedure" return TOKEN(PROCEDURE);
"program"   return TOKEN(PROGRAM);
"real"      return TOKEN(TOK_REAL);
"string"    return TOKEN(TOK_STRING);
"then"      return TOKEN(THEN);
"to"        return TOKEN(TOK_TO);
"var"       return TOKEN(VAR);
"while"     return TOKEN(WHILE);

"writeln"   return TOKEN(WRITELN);
"write"     return TOKEN(WRITE);
"readln"    return TOKEN(READLN);
"read"      return TOKEN(READ);

".."        return TOKEN(TWO_DOTS);
":="        return TOKEN(ASSIGNMENT);

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
"-"         {
    *((int*)&yylval) = *yytext;
    return *yytext;
};

"\""[][#$%&*+,./:;<=>{}[:alnum:][:blank:]-]*"\""    {
    yylval.CADENA = strdup(yytext);
    return CADENA;
};
{LETRA}({DIGITO}|{LETRA})*  {
    yylval.TOK_IDENTIFICADOR = strdup(yytext);
    return TOK_IDENTIFICADOR;
};
("+"|"-")?({NOCERO}{DIGITO}*)"."({NOCERO}{DIGITO}*)("e"("+"|"-")?({NOCERO}{DIGITO}*))?  {
    yylval.REAL = strtod(yytext, NULL);
    return REAL;
};
{ENTERO}                    {
    yylval.ENTERO = strtol(yytext, NULL, 10);
    return ENTERO;
};

[[:blank:]]+    /**/
\n|\r\n         /**/
