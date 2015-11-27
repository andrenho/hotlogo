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

int n_pars = 0;
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
%token LEARN END DEFINE TRUE FALSE IF REPEAT NOT AND OR NEQ GEQ LEQ

%% 

blocks: 
      | blocks block
      ;

attribution: DEFINE     { logo.OpenList("define"); } 
             SYMBOL     { logo.Add(string($3)); } 
             exp        { logo.CloseList(); }

learn_parameters:
                | learn_parameters SYMBOL { logo.Add(string($2)); ++n_pars; }

learning: LEARN             { logo.OpenList("define"); }
          IDENTIFIER        { n_pars = 0; logo.Add($3); logo.OpenList("lambda"); logo.OpenList(); }
          learn_parameters  { logo.AddTempFunction($3, n_pars); logo.CloseList(); logo.OpenList(); }
          blocks 
          END               { logo.CloseList(); logo.CloseList(); logo.CloseList(); }

block: learning
     | attribution
     | exp
     ;

if: IF  { logo.OpenList("if"); }
    exp
    '[' { logo.OpenList("begin"); } exps ']' { logo.CloseList(); }
    '[' { logo.OpenList("begin"); } exps ']' { logo.CloseList(); logo.CloseList(); }

repeat: REPEAT { logo.OpenList("repeat"); }
        exp
        '[' { logo.OpenList("begin"); } exps ']' { logo.CloseList(); logo.CloseList(); }

primary_exp: NUMBER         { logo.Add($1); }
           | SYMBOL         { logo.Add($1); }
           | TRUE           { logo.Add("true"); }
           | FALSE          { logo.Add("false"); }
           | '[' { logo.OpenList("quote"); } exps ']' { logo.CloseList(); }
           | '(' exp ')'
           ;

eq_exp: primary_exp
      | eq_exp '=' primary_exp
      | eq_exp NEQ primary_exp
      | eq_exp '>' primary_exp
      | eq_exp '<' primary_exp
      | eq_exp GEQ primary_exp
      | eq_exp LEQ primary_exp
      ;

sum_exp: eq_exp
       | sum_exp { logo.OpenListInv("__sum"); } '+' eq_exp { logo.CloseList(); }
       | sum_exp '-' eq_exp
       ;

mult_exp: sum_exp
        | mult_exp '*' sum_exp
        | mult_exp '/' sum_exp
        ;

and_or_exp: mult_exp
          | and_or_exp AND mult_exp
          | and_or_exp OR mult_exp
          ;

unary_exp: and_or_exp
         | '-' and_or_exp
         | NOT and_or_exp
         ;

exp: IDENTIFIER     { logo.AddCommand(string($1)); }
   | if
   | repeat
   | unary_exp
   ;

exps:
    | exps exp
    ;

%%

/* vim: ts=4:sw=4:sts=4:expandtab */
