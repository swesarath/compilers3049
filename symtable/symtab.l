%{
	#include <bits/stdc++.h>
	#include "y.tab.h"
%}

%%

(int)|(float)|(char)|(double) 	yylval.str=strdup(yytext);return KEY ;
[a-zA-Z_][a-zA-Z_0-9]* 	yylval.str=strdup(yytext);return ID ;
([0-9]*\.?[0-9]*)|(\".*?\")|(\'.\')	yylval.str=strdup(yytext);return VAL ;
";"		yylval.str=strdup(yytext);return SC ;
","		yylval.str=strdup(yytext);return CM ;
"{"		yylval.str=strdup(yytext);return OP ;
"}"		yylval.str=strdup(yytext);return CL ;
"="		yylval.str=strdup(yytext);return EQ ;
[\n \t]+	;
. 		yylval.str=strdup(yytext);return UNR;

%%
