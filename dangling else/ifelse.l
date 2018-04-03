%{
	#include<stdio.h>
    #include"y.tab.h"
	char *prev = "";
%}
IDENTIFIER [a-zA-Z][a-zA-Z0-9_]* 
CONSTANT [0-9]+
%%
"c"		{
			//ECHO;
			//yylval.str = strdup (yytext);
			//printf(" cnd %s\n",yytext);
			fprintf(yyout,"%s",prev);
			prev = strdup(yytext);
			return CND;
		}
"if"		{
			//ECHO;
			//yylval.str = strdup (yytext);
			//printf(" ifstmt :  %s\n",yytext);
			fprintf(yyout,"%s",prev);
			prev = strdup(yytext);
			return IF;
		}
"else"	{
			//ECHO;
			//yylval.str = strdup (yytext);
			//printf(" else stmt : %s\n",yytext);
			fprintf(yyout,"%s",prev);
			prev = strdup(yytext);
			return ELSE;
		}
s[0-9]		{
			//ECHO;
			yylval.str = strdup (yytext);
//			printf(" stmt : %s\n",yytext);
			fprintf(yyout,"%s",prev);
			prev = strdup(yytext);			
			return STMT;
		}
";" 		{
			ECHO;			
			return *yytext;
		}

[(){}]	{
			//ECHO;
			fprintf(yyout,"%s",prev);
			prev = strdup(yytext);
			return *yytext;
		}
[ \n\t]     ;
[$]		{
			fprintf(yyout,"%s",prev);			
			return *yytext;
		}		
.		{ 
			printf("Invalid character!");
		}
%%
int yywrap(void){
	return 1;
}
/*int main(){
	yylex();
}*/
