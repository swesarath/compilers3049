%{
	#include<bits/stdc++.h>
	using namespace std;
	int yywrap();
	int yylex();	
	void yyerror(char *s);
	int yyparse();
	string s;
	deque<int> start,end;
%}

%token FOR OP CL OP1 CL1 TEXT SC UNR DO WHILE

%union{
	char *str;
}

%type <str> s stmt for dwhile FOR OP CL OP1 CL1 TEXT SC UNR DO WHILE

%%
ss: s {cout<<s<<endl;}
s:		for s | stmt s | dwhile s| {};
for:	FOR OP TEXT SC TEXT SC TEXT CL {s=s+$3+";\nwhile("+$5+")";} OP1 {s=s+$10+"\n";} s CL1 {s=s+$7+";\n"+$13;};
stmt:	TEXT SC {s=s+$1+$2;};
dwhile: DO OP1 {s=s+"\nwhile("; start.push_back(s.length());} s CL1 WHILE OP TEXT CL SC {s.insert(start.back(),strcat($8,"){\n"));s=s+"\n}";start.pop_back();};
%%

void yyerror(char *s)
{
	printf("%s\n",s);
}
int yywrap()
{
	return 1;
}
int main(void)
{
	yyparse();
}