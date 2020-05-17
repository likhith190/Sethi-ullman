%{
#include "y.tab.h"
//void yyerror(char *);
%}
%%
0 {                 
	yylval.t= yytext;
	return INTEGER;             
	}
	
[1-9][0-9]* {                 
	yylval.t= yytext;
	return INTEGER;             
	}
[a-zA-Z] {
	yylval.t= yytext;
	return INTEGER; }
[-()<>=+*/;{}.] {                 
	return *yytext;              
	}
%%
int yywrap(void) {    
	return 1; 
}

