%{ 
  #include <stdio.h> 
  typedef struct node 
  { 
    struct node *left; 
    struct node *right; 
    char *token; 
  } node; 
  node *mknode(node *left, node *right, char *token); 
  void printtree(node *tree); 
  extern FILE* yyin;
  extern FILE* yyout;
  #define YYSTYPE struct node * 
%} 
%start     lines 
%token     NUMBER 
%token     PLUS  MINUS TIMES DIVIDE     POWER 
%token     LEFT_PARENTHESIS RIGHT_PARENTHESIS 
%token     END 
%left PLUS  MINUS 
%left TIMES DIVIDE 
%right     POWER 
%% 
lines:  /* empty */ 
        | lines line /* do nothing */ 
line   :   exp END   { printtree($1); printf("\n");} 
       ; 
exp    : term             {$$ = $1;} 
        | exp PLUS term     {$$ = mknode($1, $3, "+");} 
        | exp MINUS term    {$$ = mknode($1, $3, "-");} 
         ; 
term   : factor           {$$ = $1;} 
        | term TIMES factor  {$$ = mknode($1, $3, "*");} 
        | term DIVIDE factor  {$$ = mknode($1, $3, "/");} 
        | term POWER factor  {$$ = mknode($1, $3, "^");} 
        ; 
factor : NUMBER           {$$ = mknode(0,0,(char *)yylval);} 
        | LEFT_PARENTHESIS exp RIGHT_PARENTHESIS {$$ = $2;} 
        ; 
%% 
node *mknode(node *left, node *right, char *token) 
{
  node *newnode = (node *)malloc(sizeof(node)); 
  char *newstr = (char *)malloc(strlen(token)+1); 
  strcpy(newstr, token); 
  newnode->left = left; 
  newnode->right = right; 
  newnode->token = newstr; 
  return(newnode); 
} 
void printtree(node *tree) 
{ 
  int i; 
  if (tree->left || tree->right) 
    printf("("); 
  printf(" %s ", tree->token); 
  if (tree->left) 
    printtree(tree->left); 
  if (tree->right) 
    printtree(tree->right); 
  if (tree->left || tree->right) 
    printf(")"); 
} 
int yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
int main(void)
{
	yyin = fopen("st1in.txt","r");
	yyout = fopen("st1out.txt","w");
	int i = 3;	
	while(i--)
        {
		yyparse();
	        printf("\n");
	}
	fclose(yyin);
	return 0;
}
