%{
#include <stdlib.h>
#include <string.h>

#include "parser.hh"
%}

%option     8bit
%option     warn nodefault
%option     yylineno
%option     nounput noinput default

%%

aprenda                     return LEARN;
fim                         return END;
atribua                     return DEFINE;

\[                          return '[';
\]                          return ']';

[-+]?[0-9]*\.?[0-9]+        yylval.number = strtod(yytext, NULL); return NUMBER;
[A-Za-z][A-Za-z0-9_\-\.]*   yylval.text = strdup(yytext); return IDENTIFIER;

.                           ;
\n                          ;

%%

// vim: ts=4:sw=4:sts=4:expandtab
