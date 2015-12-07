%{
#include <cstdio>
#include <string>
using namespace std;

#include "logo.h"

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

Logo logo;

int main()
{
    extern int yyparse(void);
    yyparse();
}

%}

%union {
    char* text;
    double number;
}
%type<text> IDENTIFIER
%type<number> NUMBER

%token IDENTIFIER NUMBER 
%token LEARN END DEFINE

%% 

blocks: 
      | blocks block
      ;

block: LEARN IDENTIFIER blocks END
     | DEFINE { logo.OpenList(); logo.Add("define"); } IDENTIFIER { logo.Add(string($3)); } exp { logo.CloseList(); }
     | exp
     ;

exp: IDENTIFIER     { logo.Add(string($1)); }
   | NUMBER         { logo.Add($1); }
   ;

%%

/* vim: ts=4:sw=4:sts=4:expandtab */
