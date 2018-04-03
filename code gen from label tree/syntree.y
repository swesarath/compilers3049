%{
	#include<bits/stdc++.h>
	using namespace std;
	int yylex();	
	void yyerror(char *s);

	typedef struct node
	{
		struct node *left,*right;
		string val;
		int label;
	}NODE;

	NODE* makeNode(string val, NODE* left , NODE* right)
	{
		NODE *temp=new NODE();
		temp->val=val;
		temp->left=left;
		temp->right=right;
		temp->label=0;
		return temp;
	}

	NODE* synTree;

%}

%token PL MI MUL DIV OP CL EQ ID VAL SC UNR POW

%union{
	typedef struct node NODE;
	char *str;
	NODE *node;
}

%type <node> s e t f g
%type <str> PL MI MUL DIV OP CL EQ ID VAL SC UNR POW

%%
s : e {$$=$1;synTree=$$;}
e : e PL t {$$=makeNode($2,$1,$3);} |
	 e MI t {$$=makeNode($2,$1,$3);} |
	  t {$$=$1;};
t : t MUL f {$$=makeNode($2,$1,$3);}|
	 t DIV f {$$=makeNode($2,$1,$3);}|
	  f {$$=$1;};
f : g POW f {$$=makeNode($2,$1,$3);} |
	 g {$$=$1;};
g : OP e CL {$$=$2;} |
	 ID{$$=makeNode($1,NULL,NULL);} |
	  VAL{$$=makeNode($1,NULL,NULL);} /*|
	   MI g{$$=makeNode($1,NULL,$2);} */;

%%

void setLabels(NODE *root)
{
	if(root==NULL)
		return;
	if(root->left==NULL && root->right==NULL)
	{
		root->label=1;
		return;
	}
	setLabels(root->left);
	setLabels(root->right);
	if(root->left->label==root->right->label)
		root->label=root->left->label+1;
	else
		root->label=max(root->left->label,root->right->label);
}
void genAssembly(NODE *root,int base=1)
{
	if(root==NULL)
		return;
	if(root->left==NULL && root->right==NULL)
	{
		cout<<"LD R"<<base<<", "<<root->val<<endl;
		return;
	}
	int k=root->label;
	if(root->left->label==root->right->label)
	{
		genAssembly(root->right,base+1);
		genAssembly(root->left,base);
		cout<<root->val<<" R"<<base+k-1<<", R"<<base+k-2<<", R"<<base+k-1<<endl;
	}
	else
	{
		if(root->left->label>root->right->label)
		{
			genAssembly(root->left,base);
			genAssembly(root->right,base);
		}
		else
		{
			genAssembly(root->right,base);
			genAssembly(root->left,base);
		}
		int m=min(root->left->label,root->right->label);
		cout<<root->val<<" R"<<base+k-1<<", R"<<base+m-1<<", R"<<base+k-1<<endl;
	}
}
void postOrder(NODE* root)
{
	if(root)
	{
		postOrder(root->left);
		postOrder(root->right);
		cout<<root->val<<" ";
	}
}

void inOrder(NODE* root)
{
	if(root)
	{
		inOrder(root->left);
		cout<<root->val<<" ";
		inOrder(root->right);
	}
}

void preOrder(NODE* root)
{
	if(root)
	{
		cout<<root->val<<" ";
		preOrder(root->left);
		preOrder(root->right);
	}
}
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
	postOrder(synTree);
	cout<<endl;
	setLabels(synTree);
	genAssembly(synTree);
}