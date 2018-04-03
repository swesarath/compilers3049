%{
	#include<bits/stdc++.h>
	typedef long long ll;
	using namespace std;
	int yylex();
	void yyerror(char *s);
	int tempcount=0;
	int getTemp()
	{
		return tempcount++;
	}
	typedef struct node
	{
		string  addr, array;
		pair<string,vector<ll> > type;
		vector<ll> trueList,falseList,nextList;
		int instNum;
	}NODE;

	NODE* makeNode()
	{
		NODE *temp=new NODE();
		ostringstream ss;
		ss<<"t"<<getTemp();
		temp->addr=ss.str();
		ss.str("");
		temp->array="";
		return temp;
	}
	NODE* makeNode(string *x)
	{
		NODE *temp=new NODE();
		temp->addr=*x;
		temp->array="";
		return temp;
	}

	//for symbol table
	deque<string> s;
	deque<int> vars;
	deque<int> blocks;
	int blocknum=-1,varnum=0;
	map<ll,map<string,pair<pair<string,vector<ll> >,string> > > table;
	map<string,ll> width;
	ll getWidth(pair<string,vector<ll> > type);
	string to_string(ll val);
	void insertID(int bno,string varname);
	void printTable();

	// for backpatch
	int instCounter=0;
	map<ll,string> instList;
	int nextInst();
	vector<ll> merge(vector<ll> a,vector<ll> b);
	void backpatch(vector<ll> list,int num);
%}

%union{
	typedef struct node NODE;
	string *str;
	NODE *node;

}

%token <str> KEY AND OR NOT RELOP ID VAL SC CM PL MI MUL DIV POW OP CL AO AC EQ BO BC UNR TRUE FALSE IF ELSE WHILE
%type <node> bool bb m n e t f g l r a if ifelse while stmt stmt_list block decl
%type <str>  d id arr ss 

%%

ss:		
		{
			blocknum++;
			blocks.push_back(blocknum);
			vars.push_back(varnum);
			varnum=0;
		}
		stmt
		{
			for(map<ll,string>::iterator it=instList.begin();it!=instList.end();it++)
			{
				cout<<it->first<<" "<<it->second<<endl;
			}
		};

stmt:	if {$$=new NODE();$$->nextList=$1->nextList;} |
		 ifelse {$$=new NODE();$$->nextList=$1->nextList;} |
		  while {$$=new NODE();$$->nextList=$1->nextList;} |
		   block {$$=new NODE();$$->nextList=$1->nextList;} |
		    a {$$=new NODE();$$->nextList=$1->nextList;}|
		     decl{$$=new NODE();$$->nextList=$1->nextList;};

if:		IF OP bool CL m stmt {
								$$=new NODE();
								backpatch($3->trueList,$5->instNum);
								$$->nextList=merge($3->falseList,$6->nextList);
							};
ifelse: IF OP bool CL m stmt ELSE n m stmt {
											$$=new NODE();
											backpatch($3->trueList,$5->instNum);
											backpatch($3->falseList,$9->instNum);
											$$->nextList=merge($6->nextList,$8->nextList);
											$$->nextList=merge($$->nextList,$10->nextList);
										};
while:	WHILE m OP bool CL m stmt {
									$$=new NODE();
									backpatch($4->trueList,$6->instNum);
									backpatch($7->nextList,$2->instNum);
									instList[nextInst()]="goto "+to_string($2->instNum);
									$$->nextList=$4->falseList;
								};
block: BO	{
			blocknum++;
			blocks.push_back(blocknum);
			for(int i=0;i<s.size();i++)
			{
				insertID(blocknum,s[i]);
			}
			vars.push_back(varnum);
			varnum=0;
		} 
		stmt_list BC 
		{
			blocks.pop_back();
			for(int i=0;i<varnum;i++)
				s.pop_back();
			varnum=vars.back();
			vars.pop_back();	
			$$=new NODE();
			$$->nextList=$3->nextList;
		};
stmt_list: stmt_list m stmt {
								$$=new NODE();
								backpatch($1->nextList,$2->instNum);
								$$->nextList=$3->nextList;
							} |
			 stmt {$$->nextList=$1->nextList;};
decl: KEY id {
				varnum++;s.push_back(*$1+" "+*$2);
				insertID(blocks.back(),*$1+" "+*$2);
			} d SC {$$=new NODE();}; 

id:	ID arr{$$=new string(*$1+*$2);} | ID arr EQ VAL {$$=new string(*$1+*$2+*$3+*$4);};

arr:	AO VAL AC arr {$$=new string(*$1+*$2+*$3+*$4);}| {$$=new string("");};

d: CM id {
			varnum++;s.push_back(*$2);
			insertID(blocks.back(),*$2);
		} d | {};

a:	l EQ r SC {instList[nextInst()]=$1->array+"["+$1->addr+"]= "+$3->addr;	} |
	  	ID EQ r SC 	{
	  					if(table[blocks.back()].find(*$1)==table[blocks.back()].end())
						{
							yyerror("variable not declared");
						}
	  					instList[nextInst()]=*$1+" = "+$3->addr;
	  					$$=new NODE();
	  				} ;
l: 	 ID AO e AC 
				{
					$$=makeNode();
					$$->array=*$1;
					if(table[blocks.back()].find(*$1)==table[blocks.back()].end())
					{
						yyerror("variable not declared");
					}
					$$->type=table[blocks.back()][*$1].first;
					instList[nextInst()]=$$->addr+" = "+$3->addr+" * "+to_string(getWidth($$->type));
				} |
		 l AO e AC
		 		{
		 			NODE *myTemp=makeNode();
		 			$$=makeNode();
		 			$$->array=$1->array;
		 			$$->type=$1->type;
		 			$$->type.second.erase($$->type.second.begin());
		 			instList[nextInst()]=myTemp->addr + " = "+$3->addr +" * "+to_string(getWidth($$->type));
		 			instList[nextInst()]=$$->addr+" = "+$1->addr+ " + " + myTemp->addr;
		 		}
r : e 	{$$=$1;};


bool:	bool OR m bb 	{
					$$=new NODE();
					backpatch($1->falseList,$3->instNum);
					$$->trueList=merge($1->trueList,$4->trueList);
					$$->falseList=$4->falseList;
				} |
	 bool AND m bb	{
	 				$$=new NODE();
	 				backpatch($1->trueList,$3->instNum);
	 				$$->trueList=$4->trueList;
	 				$$->falseList=merge($1->falseList,$4->falseList);
				} |
		 bb {$$=new NODE();$$->trueList=$1->trueList;$$->falseList=$1->falseList;};

bb:	  NOT bb {$$=new NODE();$$->trueList=$2->falseList;$$->falseList=$2->trueList;} |
	   OP bool CL {$$=new NODE();$$->trueList=$2->trueList;$$->falseList=$2->falseList;} |
	    e RELOP e 	{
	    				$$=new NODE();
	    				$$->trueList.push_back(nextInst());
	    				instList[$$->trueList.back()]="if("+$1->addr+" "+*$2+" "+$3->addr+") goto";
	    				$$->falseList.push_back(nextInst());
	    				instList[$$->falseList.back()]="goto";
	    			} |
	     TRUE {$$=new NODE();$$->trueList.push_back(nextInst());instList[$$->trueList.back()]="goto";} |
	      FALSE {$$=new NODE();$$->falseList.push_back(nextInst());instList[$$->falseList.back()]="goto";};
m:	{$$=new NODE();$$=new NODE();$$->instNum=instCounter;};
n:	{$$=new NODE();$$->nextList.push_back(nextInst());instList[$$->nextList.back()]="goto";};

e : e PL t {$$=makeNode();instList[nextInst()]=$$->addr+" = "+$1->addr+" + "+$3->addr;}|
	 e MI t {$$=makeNode();instList[nextInst()]=$$->addr+" = "+$1->addr+" - "+$3->addr;}|
	  t {$$=$1;} |
	   l {$$=makeNode();instList[nextInst()]=$$->addr+" = "+$1->array+"["+$1->addr+"]";};

t : t MUL f {$$=makeNode();instList[nextInst()]=$$->addr+" = "+$1->addr+" * "+$3->addr;}|
	 t DIV f {$$=makeNode();instList[nextInst()]=$$->addr+" = "+$1->addr+" / "+$3->addr;}|
	  f {$$=$1;};

f : g POW f {$$=makeNode();instList[nextInst()]=$$->addr+" = "+$1->addr+" ^ "+$3->addr;}|
	 g {$$=$1;};

g : OP e CL {$$=$2;}|
	 ID {
	 		if(table[blocks.back()].find(*$1)==table[blocks.back()].end())
			{
				yyerror("variable not declared");
			}
			$$=makeNode($1);
		} |
	  VAL {$$=makeNode($1);} |
	   MI g {$$=makeNode();instList[nextInst()]=$$->addr+" = - "+$2->addr;};

%%
/*void quadraple()
{
int cnt=0;
temp++;
printf(“\n\n\t QUADRAPLE CODE\n\n”);
while(cnt<ind)
{
//printf(“%c : = \t”,temp);
printf(“%d”,id);
printf(“\t”);
printf(“%c”,code[cnt].opr);
printf(“\t”);
if(isalpha(code[cnt].opd1))
printf(“%c\t”,code[cnt].opd1);
else
{printf(“%c\t”,temp);}

//printf(“%c\t”,code[cnt].opr);

if(isalpha(code[cnt].opd2))
printf(“%c\t”,code[cnt].opd2);
else
{printf(“%c\t”,temp);}

printf(“%c”,temp);

printf(“\n”);
cnt++;
temp++;
id++;

}
}*/
int nextInst()
{
	return instCounter++;
}
vector<ll> merge(vector<ll> a,vector<ll> b)
{
	a.insert(a.end(),b.begin(),b.end());
	return a;
}
void backpatch(vector<ll> list,int num)
{
	for(ll i=0;i<list.size();i++)
	{
		if(instList[list[i]].find("goto")==instList[list[i]].length()-4)
		{
			instList[list[i]]+=" "+to_string(num);
		}
	}
}
void insertID(int bno,string varname)
{
	string type,value;
	int ind=varname.find(" ");
	if(ind!=-1)
	{
		type=varname.substr(0,ind);
		varname=varname.substr(ind+1);
	}
	ind=varname.find("=");
	value="";
	if(ind!=-1)
	{
		value=varname.substr(ind+1);
		varname=varname.substr(0,ind);
	}
	ind=varname.find("[");
	vector<ll> dims;
	if(ind!=-1)
	{
		string indexes=varname.substr(ind);
		varname=varname.substr(0,ind);
		for(ll i=0;i<indexes.length();i++)
		{
			if(indexes[i]=='[' || indexes[i]==']')
				indexes[i]=' ';
		}
		istringstream in(indexes.c_str());
		int dim;
		while(in>>dim)
		{
			dims.push_back(dim);
		}
	}
	table[bno][varname]=make_pair(make_pair(type,dims),value);
}
ll getWidth(pair<string,vector<ll> > type)
{
	ll ans=width[type.first];
	for(ll i=1;i<type.second.size();i++)
	{
		ans=ans*type.second[i];
	}
	return ans;
}
void printTable()
{
	for(map<ll,map<string,pair<pair<string,vector<ll> >,string> > >::iterator it=table.begin();it!=table.end();it++)
	{
		cout<<it->first<<endl;
		for(map<string,pair<pair<string,vector<ll> >,string> >::iterator it2=it->second.begin();it2!=it->second.end();it2++)
		{
			cout<<it2->first<<" "<<it2->second.first.first<<" "<<it2->second.second;
			for(vector<ll>::iterator it3=it2->second.first.second.begin();it3!=it2->second.first.second.end();it3++)
				cout<<*it3<<' ';
			cout<<endl;
		}
		cout<<endl





;
	}
}
void setWidths()
{
	width["int"]=4;
	width["float"]=4;
	width["char"]=1;
	width["double"]=8;
}
string to_string(ll val)
{
	ostringstream ss;
	ss<<val;
	return ss.str();
}
void yyerror(char* s)
{
	cout<<s<<endl;
	exit(0);
} 
extern int yylex();
extern int yyparse();
extern FILE *yyin;
int main()
{
	setWidths();
	// open a file handle to a particular file:
	FILE *myfile = fopen("input.txt", "r");
	// make sure it is valid:
	if (!myfile) {
		printf("I can't open a.snazzle.file!");
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
	
	
}
