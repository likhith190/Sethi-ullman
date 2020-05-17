%{
#include<stdio.h>
#include<string.h>
typedef struct node{
	char *operator;
	struct node *loperand;
	struct node *roperand;
	int Reg_Req;
}node;
//#define YYSTYPE int
void yyerror(char *s);
node *create_node(char *op,node *left,node *right);
int Reg_required(node *root);
void Label_leaves(node *root);
int max(int a,int b);
int is_leaf(node *root);
void gen_code(node *root);
char *decode_operator(node *root);
void print_tree(node *root);
void print2DUtil(node *root, int space);
#define COUNT 10
int n_reg=3;
int t_reg=5;
int Rstack_top;
int Rstack[3];
int Tstack_top;
int Tstack[5];
void initiate_stack();
void swap();
int Rpop();
int Tpop();
void Rpush();
void Tpush();
//int push
//void swap();
%}

%union {   
	struct node *L;
	char *t;
	};
%start S 
%type <L> E T F 
%token <t> INTEGER
%left '+' '-' 
%left '*' '/'

%%

	S:	E';'	{//printf("%s\n",$1->operator);
			 //printf("%s\n",$1->loperand->operator);
			 //printf("%s\n",$1->roperand->operator);
			 Label_leaves($1);
			 Reg_required($1);
			 printf("\nOptimal No. of Registers Required to compute expression : %d\n",$1->Reg_Req);
			 //printf("pre-order traversal of parse tree generated is \n\n");
			 print_tree($1);
			 //printf("Hi1");
			 initiate_stack();
			 printf(".............................Generating Optimal code using sethi-ullmann algorithm...........................................\n");
			 gen_code($1);
				//printf("hloo");
			}
	  ;
	  
	E:	E'+'T		{$$=create_node("+",$1,$3);}
	 |	E'-'T		{$$=create_node("-",$1,$3);}
	 |	T		{$$=$1;}
	 ;
	T:	T'*'F		{$$=create_node("*",$1,$3);}
	 |	T'/'F		{$$=create_node("/",$1,$3);}
	 |	F		{$$=$1;}
	 ;
	F:	'('E')'	{$$=$2;}
	 |	INTEGER	{$$=create_node(yylval.t,NULL,NULL);
	 				//printf("%s\n",yylval.t);
	 				}
	 ; 
	 //E:	INTEGER	{$$=create_node((char *)yylval,0,0);}
	 
%%

node *create_node(char *op,node *op1,node *op2){
	//printf("Hi1");
	node *temp=(node *)malloc(sizeof(node));
	char *op_temp = (char *)malloc(strlen(op)+1);
	strcpy(op_temp,op);
	
	temp->operator=op_temp;
	if(op1){
	temp->loperand=op1;}
	else{temp->loperand=NULL;}
	if(op2){
	temp->roperand=op2;}
	else{temp->roperand=NULL;}
	return(temp);
}
void yyerror(char *s) {     
	fprintf(stdout, "%s\n", s); 
		}
int is_leaf(node *root){
	if(!(root->loperand) && !(root->roperand)){
	return 1;}
	else{
	return 0;}
	}
int Reg_required(node *root){
	if(!(is_leaf(root))){
	
		int k=Reg_required(root->loperand);
		int l=Reg_required(root->roperand);
		if (k!=l){
			root->Reg_Req=max(k,l);
		}
		else{
			root->Reg_Req=k+1;
		}
		return root->Reg_Req;
	}
	else{
		return root->Reg_Req;
	}
	
}
void Label_leaves(node *root){
	if(root){
	if(root->loperand && is_leaf(root->loperand)){root->loperand->Reg_Req=1;}
	if(root->roperand && is_leaf(root->roperand)){root->roperand->Reg_Req=0;}
	Label_leaves(root->loperand);
	Label_leaves(root->roperand);
	}
	else{return ;}
}
void gen_code(node *root){
	if(is_leaf(root)&&(root->Reg_Req==1)){
			//Rpush(root->oprator);
			printf("MOVE %s  r%d  \n",root->operator,Rstack[Rstack_top]);
			return ;	
	}
	else if(is_leaf(root->roperand)&& root->roperand->Reg_Req==0){
		gen_code(root->loperand);
		//Rstack[Rstack_top]=Rstack[Rstack_top] op root->roperand
		//char *t=decode_operator(root);
		printf("%s  %s r%d  \n",decode_operator(root),root->roperand->operator,Rstack[Rstack_top]);
		return ;
	}
	else if(root->loperand->Reg_Req < root->roperand->Reg_Req && root->roperand->Reg_Req < n_reg){
		//swap(RStack);
		swap();
		gen_code(root->roperand);
		//char *R=pop(Rstack);
		int R=Rpop();
		gen_code(root->loperand);
		//char *t=decode_operator(root);
		printf("%s  r%d r%d  \n",decode_operator(root),Rstack[Rstack_top],R);
		//push(Rstack,R);
		Rpush();
		//swap(Rstack);
		swap();
		return ;
	}
	else if(root->loperand->Reg_Req >=root->roperand->Reg_Req && root->loperand->Reg_Req < n_reg){
		gen_code(root->loperand);
		//char *R=pop(Rstack);
		int R=Rpop();
		gen_code(root->roperand);
		//char *t=decode_operator(root);
		printf("%s  r%d r%d  \n",decode_operator(root),Rstack[Rstack_top],R);
		//push(Rstack,R);
		Rpush();
		return ;
	}
	else if(root->loperand->Reg_Req >= n_reg && root->roperand->Reg_Req >=n_reg){
		gen_code(root->roperand);
		//char *T=pop(Tstack);
		int T=Tpop();
		//printf("%s <- %s",T,top(Rstack));
		gen_code(root->loperand);
		//push(Tstack,T);
		Tpush();
		//char *t=decode_operator(root);
		printf("%s <- r%d t%d  \n",decode_operator(root),Rstack[Rstack_top],T);
		
		return ;
	}
	else{return ;}
}
void swap(){
	int temp=Rstack[Rstack_top];
	Rstack[Rstack_top]=Rstack[Rstack_top-1];
	Rstack[Rstack_top-1]=temp;
}
int Rpop(){
	int temp=Rstack[Rstack_top];
	Rstack_top=Rstack_top-1;
	return temp;
}
int Tpop(){
	int temp=Tstack[Tstack_top];
	Tstack_top=Tstack_top-1;
	return temp;
}
char *decode_operator(node *root){
	
	if(strcmp(root->operator,"+")==0){return "ADD";}
	else if(strcmp(root->operator,"-")==0){return "MINUS";}
	else if(strcmp(root->operator,"*")==0){return "MUL";}
	else {return "DIV";}
	//if(root->operator=='/')


}
void initiate_stack(){
	for(int i=0;i<n_reg;i++){Rstack[i]=n_reg-i-1;}
	Rstack_top=n_reg-1;
	for(int i=0;i<t_reg;i++){Tstack[i]=t_reg-i-1;}
	Tstack_top=t_reg-1;
}
void Rpush() {
//no need to check whther stack is full or not as sethi-ullman algo.takes care of it
      Rstack_top = Rstack_top + 1;   
      //Rstack[Rstack_top] =(int)data;
}
void Tpush() {
//no need to check whther stack is full or not as sethi-ullman algo.takes care of it
      Tstack_top = Tstack_top + 1;   
      //Tstack[Tstack_top] = data;
}
void print_tree(node *root){
	print2DUtil(root, 0); 
	}
void print2DUtil(node *root, int space) 
{ 
    // Base case 
    if (root == NULL) 
        return; 
  
    // Increase distance between levels 
    space += COUNT; 
  
    // Process right child first 
    print2DUtil(root->roperand, space); 
  
    // Print current node after space 
    // count 
    printf("\n"); 
    for (int i = COUNT; i < space; i++) 
        printf(" "); 
    printf("'%s'(%d)\n", root->operator,root->Reg_Req); 
  
    // Process left child 
    print2DUtil(root->loperand, space); 
} 
int max(int a,int b){if(a>b){return a;}else{return b;}}	
int main (void) {
 printf("Enter An Expression to generate optimal code(with ; after the expression....sample=='(1+2);'):\n");
 yyparse (); return 0;} 

