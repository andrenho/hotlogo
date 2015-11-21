%{
#include <cstdio>
#include <string>
using namespace std;

#include "lpu.h"

extern "C" {
    int yylex(void);
    int yywrap() { return 1; }
}

extern int yylineno;
extern char* yytext;

void yyerror(const char* s) 
{
    fprintf(stderr, "error: %s in line %d (token \"%s\")\n", s, yylineno, yytext);
}

LPU lpu;

int main()
{
    extern int yyparse(void);
    yyparse();
    lpu.PrintBuffer();
}

%}

%union {
    char* text;
    double number;
}
%type<text> IDENTIFIER
%type<number> NUMBER

%token IDENTIFIER NUMBER REPEAT

%% 

block: 
     | block exp
     | REPEAT NUMBER { lpu.Add("(repeat " + to_string($2) + " "); } '[' block ']' { lpu.Add(") "); }
     ;

exp: IDENTIFIER     { lpu.PushIdentifier(string($1)); }
   | NUMBER         { lpu.Push($1); }
   ;

%%

/* vim: ts=4:sw=4:sts=4:expandtab */
