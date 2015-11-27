%{
#include <stdlib.h>
#include <string.h>

#include "parser.hh"
%}

CHR         [^ \t\n\[\]\(\)\!\=\<\>\+\-\*\/\:]

%option     8bit
%option     warn nodefault
%option     yylineno
%option     nounput noinput default

%%

aprenda                     return LEARN;
fim                         return END;
atribua                     return DEFINE;
se                          return IF;
repita                      return REPEAT;
e                           return AND;
ou                          return OR;
não                         return NOT;

verd                        return TRUE;
falso                       return FALSE;

\!\=                        return NEQ;
\<\=                        return LEQ;
\>\=                        return GEQ;
\+                          return '+';
\-                          return '-';
\*                          return '*';
\/                          return '/';
\[                          return '[';
\]                          return ']';
\(                          return '(';
\)                          return ')';

[0-9]*\.?[0-9]+             yylval.number = strtod(yytext, NULL); return NUMBER;
{CHR}+                      yylval.text = strdup(yytext); return IDENTIFIER;
\:{CHR}+                    yylval.symbol = strdup(yytext); return SYMBOL;

.                           ;
\n                          ;

%%

// vim: ts=4:sw=4:sts=4:expandtab
