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
    char* symbol;
    double number;
}
%type<text> IDENTIFIER
%type<symbol> SYMBOL
%type<number> NUMBER

%token IDENTIFIER NUMBER SYMBOL
%token LEARN END DEFINE TRUE FALSE IF

%% 

blocks: 
      | blocks block
      ;

attribution: DEFINE     { logo.OpenList("define"); } 
             SYMBOL     { logo.Add(string($3)); } 
             exp        { logo.CloseList(); }

learn_parameters:
                | learn_parameters SYMBOL { logo.Add(string($2)); }

learning: LEARN             { logo.OpenList("define"); }
          IDENTIFIER        { logo.Add($3); logo.OpenList("lambda"); logo.OpenList(); }
          learn_parameters  { logo.CloseList(); logo.OpenList(); }
          blocks 
          END               { logo.CloseList(); logo.CloseList(); logo.CloseList(); }

block: learning
     | attribution
     | exp
     ;

exps:
    | exps exp
    ;

if: IF              { logo.OpenList("if"); }
    exp
    '[' { logo.OpenList("begin"); } exps ']' { logo.CloseList(); }
    '[' { logo.OpenList("begin"); } exps ']' { logo.CloseList(); logo.CloseList(); }

exp: if
   | IDENTIFIER     { logo.AddCommand(string($1)); }
   | NUMBER         { logo.Add($1); }
   | SYMBOL         { logo.Add($1); }
   | TRUE           { logo.Add("true"); }
   | FALSE          { logo.Add("false"); }
   | '[' { logo.OpenList("quote"); } exps ']' { logo.CloseList(); }
   ;

%%

/* vim: ts=4:sw=4:sts=4:expandtab */
