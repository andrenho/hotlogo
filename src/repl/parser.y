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
%type<text> IDENTIFIER SYMBOL
%type<number> NUMBER

%token IDENTIFIER NUMBER SYMBOL
%token LEARN END DEFINE TRUE FALSE

%% 

blocks: 
      | blocks block
      ;

attribution: DEFINE     { logo.OpenList(); logo.Add("define"); } 
             SYMBOL     { logo.Add(string($3)); } 
             exp        { logo.CloseList(); }

learn_parameters:
                | learn_parameters SYMBOL { logo.Add(string($2)); }

learning: LEARN             { logo.OpenList(); logo.Add("define"); }
          IDENTIFIER        { logo.Add($3); logo.OpenList(); logo.Add("lambda"); logo.OpenList(); }
          learn_parameters  { logo.CloseList(); logo.OpenList(); }
          blocks 
          END               { logo.CloseList(); logo.CloseList(); logo.CloseList(); }

block: learning
     | attribution
     | exp
     ;

exp: IDENTIFIER     { logo.AddCommand(string($1)); }
   | NUMBER         { logo.Add($1); }
   | TRUE           { logo.Add("true"); }
   | FALSE          { logo.Add("false"); }
   ;

%%

/* vim: ts=4:sw=4:sts=4:expandtab */
