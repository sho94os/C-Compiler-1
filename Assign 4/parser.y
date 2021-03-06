%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "SymbolTable.h"

#define YYSTYPE SymbolInfo*

using namespace std;
string dec_print = "outdec proc\n\
;input ax\n\
PUSH AX\n\
PUSH BX\n\
PUSH CX\n\
PUSH DX\n\
cmp ax,0\n\
jge @END_IF1\n\
PUSH AX\n\
MOV DL,'-'\n\
MOV AH,2\n\
INT 21H\n\
POP AX\n\
NEG AX\n\
\n\
@END_IF1:\n\
XOR CX,CX\n\
MOV BX,10D\n\
\n\
@REPEAT1:\n\
XOR DX,DX\n\
DIV BX\n\
PUSH DX\n\
INC CX\n\
cmp ax,0\n\
JNE @REPEAT1\n\
\n\
MOV AH,2\n\
\n\
@PRINT_LOOP:\n\
\n\
POP DX\n\
mov dh,0\n\
add DL,30H\n\
INT 21H\n\
LOOP @PRINT_LOOP\n\
\n\
POP DX\n\
POP CX\n\
POP BX\n\
POP AX\n\
RET\n\
OUTDEC ENDP\n\
";


int labelCount=0;
int tempCount=0;

string IntToString (int a)
{
    ostringstream temp;
    temp<<a;
    return temp.str();
}

string newLabel()
{
  string temp="l";
  
  labelCount++;
  temp=temp+IntToString(labelCount);
  return temp;

}


string newTemp()
{
  string temp="t";
  tempCount++;
  temp=temp+IntToString(tempCount);
  return temp;

}


string bb="";
string total_code;
string initial_code =".MODEL SMALL\n.STACK 100H\n\n.DATA\n";
string declare_code;
string function_code;
string main_code = ".CODE\n\nMAIN PROC\n\nMOV AX, @DATA\nMOV DS, AX\n\n";

int global_scope_id=1;
int yyparse(void);
int yylex(void);
extern FILE *yyin;

extern int lin_count;
extern int error_count;
int type;
SymbolTable* table;
SymbolInfo* dam;
FILE *logout;
FILE *errorout;
FILE *asmout;
int pos=0;
int flow[10];
string item[10];
int pos1=0;
int flow1[10];
int flow2[10];
int println=0;
void yyerror(char *s)
{
	//write your code
}


%}

%token IF ELSE FOR INT CHAR WHILE FLOAT VOID RETURN PRINTLN ID ADDOP MULOP INCOP DECOP RELOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON ASSIGNOP CONST_CHAR CONST_INT CONST_FLOAT LOGICOP MAIN

%left '+' '-' 
%left '*' '%'

%nonassoc noelse 

%nonassoc ELSE

%%

start : program
         {
	
              
              {fprintf(logout,"Line no %d->start: program\n\n",lin_count);} 
              //main code er shate $$->code ta add korte hope
              //main_code = main_code+$1->code;
              main_code = main_code + "\n\nMAIN ENDP\n\n";
             
	}
	;

program : program unit
	{
           fprintf(logout,"Line no %d->program: unit program\n\n",lin_count);

	} 
       | unit {fprintf(logout,"Line no %d->program: unit \n\n",lin_count); $$=$1;}
        
	
	;
unit :  
         var_declaration
	{
            fprintf(logout,"Line no %d->unit: var_declaration\n\n",lin_count);
	}
     	| 
     	func_declaration
     	{
           fprintf(logout,"Line no %d->unit: func_declaration\n\n",lin_count);

     	}
     	| 
     	func_definition
     	{
           fprintf(logout,"Line no %d->unit: func_definition\n\n",lin_count);
           $$=$1;
     	}
       
     	;
     
func_declaration : type_specifier ID lparen2 parameter_list2 RPAREN SEMICOLON
			{
                           fprintf(logout,"Line no %d->func_declaration : type_specifier ID LPAREN parameter_list2 RPAREN SEMICOLON\n\n",lin_count);
                        table->ExitScope();
                        cout<<" exitscope from func";
                       SymbolInfo* temp=table->Look($2->name);
                        
                       if(!temp){
                         table->InsertS($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,$1->value.c);
                         temp=table->Look($2->name);
                        
                        
                        	
                        temp->type="Function";
                        temp->fsize=pos;
                        temp->para=1;
                        temp->isF=0;
                        if (temp->value.c==0) { temp->fsign=0; temp->value.c=-3;}
                        else if(temp->value.c==1) {temp->fsign=1; temp->value.c=-3;}
                        else if(temp->value.c==4) {temp->fsign=2; temp->value.c=-3;}
                         
                        for(int i=0;i<pos;i++) {  temp->f[i]=flow[i]; }; 
                        
                        
                        pos=0;
                        table->AllScopePrint();
                        
                          
			}
                        else if(temp) { fprintf(errorout,"Array already declared\n\n"); error_count++;}

}
		 	;
		 
func_definition : type_specifier ID lparen2 parameter_list2 RPAREN compound_statement
			{
                         fprintf(logout,"Line no %d->func_definition:type_specifier ID LPAREN parameter_list2 RPAREN compound_statement\n\n",lin_count);
                        table->ExitScope();
                        cout<<" exitscope from defi";
                        
                        SymbolInfo* temp=table->Look($2->name);
                        
                       if(!temp){
                        table->InsertS($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,type);
                        temp=table->Look($2->name);	
                        temp->type="Function";
                        temp->fsize=pos;
                        temp->para=1;
                        temp->isF=1;
                        if (temp->value.c==0) { temp->fsign=0; temp->value.c=-3;}
                        else if(temp->value.c==1) {temp->fsign=1; temp->value.c=-3;}
                        else if(temp->value.c==4) {temp->fsign=2; temp->value.c=-3;}
                         
                        for(int i=0;i<pos;i++) { temp->f[i]=flow[i]; temp->variable[i]=item[i];
                           


}
                        temp->freturn=$6->freturn;
                        string tempq=newTemp();
                        declare_code+=tempq+" dw ?\n";
                        bb=tempq;
                        
                        
                        if(temp->name=="main") { $$=$6; main_code=main_code+$6->code;  }
                        else {
                              $6->code+="\n\nmov ax,"+$6->freturn+"\n";
                              $6->code+="mov "+bb+",ax";
                             function_code+="\n"+temp->name+" proc near\n\n";
                             function_code+="push ax\npush bx\npush cx\npush dx\n";
                             function_code+=$6->code+"\n";
                             function_code+="pop dx\npop cx\npop bx\npop ax\nret\n\n";
                             function_code+=temp->name+" endp\n\n";

                             }
                        //bb=temp->freturn;//=string(newTemp());
                        pos=0;
                        table->AllScopePrint();
                       
                          
			}
                        else if(temp->isF==0 && (temp->fsign==0||temp->fsign==1 || temp->fsign==2)) {temp->isF=1;}
                        else if(temp->isF==1){ fprintf(errorout,"%s is already defined \n\n",temp->name.c_str()); error_count++; } 
                        else { fprintf(errorout,"Error at Line no%d: %s is a ID ",lin_count,temp->name.c_str()); error_count++; }                    

                        $$=$6;
                        
}
 		 	;
lparen2 :
         LPAREN  {if($1->name=="(") {table->EntryScope(); global_scope_id++;}}
         ;



 		
parameter_list2 : parameter_list  {fprintf(logout,"Line no %d->parameter_list2 : parameter_list\n\n",lin_count);}
                | {fprintf(logout,"Line no %d->parameter_list2 : \n\n",lin_count);}
                ; 
parameter_list  : parameter_list COMMA type_specifier ID {fprintf(logout,"Line no %d->parameter_list : parameter_list COMMA type_specifier ID\n %s \n\n",lin_count,$4->name.c_str());

                 if(table->Look($4->name)!=NULL) {fprintf(errorout,"Line np %d->Multiple declaration of %s\n\n",lin_count,$4->name.c_str());  error_count++;}
                 else {

                      $4->symbol=$4->name+IntToString(global_scope_id);
                      declare_code+=$4->symbol+" dw "+"?\n";
                      table->InsertS($4->name,$4->type,$4->symbol,-1111,-1111,1,0,-1111,-1111,type);

                       //table->InsertS($4->name,$4->type,-1111,-1111,1,0,-1111,-1111,type);
                       flow[pos]=$3->value.c;
                       item[pos]=$4->symbol;
                        pos++;
                      table->AllScopePrint();}
                 

}	 
 		| type_specifier ID  {fprintf(logout,"Line no %d->parameter_list : type_specifier ID\n %s \n\n",lin_count,$2->name.c_str());
                 if(table->Look($2->name)!=NULL) {fprintf(errorout,"Line np %d->Multiple declaration of %s \n\n ",lin_count,$2->name.c_str());  error_count++;}
                 else {
                      $2->symbol=$2->name+IntToString(global_scope_id);
                      declare_code+=$2->symbol+" dw "+"?\n";
                      table->InsertS($2->name,$2->type,$2->symbol,-1111,-1111,1,0,-1111,-1111,type);

                        //table->InsertS($2->name,$2->type,-1111,-1111,1,0,-1111,-1111,type);
                        flow[pos]=$1->value.c;
                        item[pos]=$2->symbol;
                        pos++;
                      table->AllScopePrint();}
                 


}	 
 		;
 		
compound_statement : LCURL statements RCURL {fprintf(logout,"Line no %d->compound_statement : LCURL statements RCURL\n\n",lin_count); $$=$2;



}
 		    | LCURL RCURL {fprintf(logout,"Line no %d->compound_statement : LCURL RCURL\n\n",lin_count);}
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON {fprintf(logout,"Line no %d->var_declaration : type_specifier declaration_list SEMICOLON\n\n",lin_count);  }
                 ;
 		 
type_specifier	: INT  {fprintf(logout,"Line no %d->type_specifier	: INT\n\n",lin_count); type=0;  
                         SymbolInfo* temp=new SymbolInfo;
                         temp->value.c=0;
                         $$=temp;
                         
                          }  
 		| FLOAT {fprintf(logout,"Line no %d->type_specifier	: FLOAT\n\n",lin_count); type=1;
                         SymbolInfo* temp=new SymbolInfo;
                         temp->value.c=1;
                         $$=temp;
                         
                         }
 		| VOID {fprintf(logout,"Line no %d->type_specifier	: VOID\n\n",lin_count);  type=4;
                         SymbolInfo* temp=new SymbolInfo;
                         temp->value.c=4;
                         $$=temp;
                         }
 		;
 		
declaration_list : declaration_list COMMA ID {
                 fprintf(logout,"Line no %d->declaration_list : declaration_list COMMA ID\n %s\n\n",lin_count,$3->name.c_str());
                 if(table->Look($3->name)!=NULL) {fprintf(errorout,"Line no %d->Multiple declaration of %s",lin_count,$3->name); error_count++;}
                 else {
                       $3->symbol=$3->name+IntToString(global_scope_id);
                      declare_code+=$3->symbol+" dw "+"?\n";


                        table->InsertS($3->name,$3->type,$3->symbol,-1111,-1111,1,0,-1111,-1111,type);
                        table->AllScopePrint();
                              }

                   }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
                 fprintf(logout,"Line no %d->declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n %s\n\n",lin_count,$3->name.c_str());
                  if(table->Look($3->name)!=NULL) {fprintf(errorout,"Line no %d->Multiple declaration of %s",lin_count,$3->name.c_str()); error_count++;}
                  else {if(type==0) {
                         $3->symbol=$3->name+IntToString(global_scope_id);
                         declare_code+=$3->symbol+" dw ";
                         for(int i=0;i<$5->value.ival-1;i++) { declare_code+="? "; }
                         declare_code+="?\n";


                      table->InsertS($3->name,$3->type,$3->symbol,-1111,-1111,$5->value.ival,0,-1111,-1111,2); 
                      table->AllScopePrint();}
                        else if(type==1){table->InsertS($3->name,$3->type,$3->symbol,-1111,-1111,$5->value.ival,0,-1111,-1111,3); table->AllScopePrint();}                     
}
                    }
 		  | ID {   
                 fprintf(logout,"Line no %d->declaration_list : ID\n %s \n\n",lin_count,$1->name.c_str()); 
                 if(table->Look($1->name)!=NULL) {fprintf(errorout,"Line np %d->Multiple declaration of %s",lin_count,$1->name.c_str());  error_count++;}
                 else {
                      $1->symbol=$1->name+IntToString(global_scope_id);
                      declare_code+=$1->symbol+" dw "+"?\n";
                      table->InsertS($1->name,$1->type,$1->symbol,-1111,-1111,1,0,-1111,-1111,type);
                      table->AllScopePrint();}
                  }
 		  | ID LTHIRD CONST_INT RTHIRD {fprintf(logout,"Line no %d->declaration_list : ID LTHIRD CONST_INT RTHIRD\n %s\n\n",lin_count,$1->name.c_str());
                  if(table->Look($1->name)!=NULL) {fprintf(errorout,"Line no %d->Multiple declaration of %s",lin_count,$1->name.c_str()); error_count++;}
                  else { if(type==0) {

                         $1->symbol=$1->name+IntToString(global_scope_id);
                         declare_code+=$1->symbol+" dw ";
                         for(int i=0;i<$3->value.ival-1;i++) { declare_code+="? "; }
                         declare_code+="?\n";

                         table->InsertS($1->name,$1->type,$1->symbol,-1111,-1111,$3->value.ival,0,-1111,-1111,2); 
                         table->AllScopePrint();
                                                   }
                         else if(type==1){table->InsertS($1->name,$1->type,$1->symbol,-1111,-1111,$3->value.ival,0,-1111,-1111,3); table->AllScopePrint();}                          
}
                  
                   
                   }
 		  ;
 		  
statements : statement {fprintf(logout,"Line no %d-> statements : statement\n\n",lin_count); $$=$1;  }
	   | statements statement {fprintf(logout,"Line no %d-> statements : statements statement\n\n",lin_count); $$=new SymbolInfo; $$->code=$1->code + $2->code; $$->freturn=$2->freturn;  }
	   ;
	   
statement : var_declaration  {fprintf(logout,"Line no %d->statement : var_declaration\n\n",lin_count);$$=$1;}
	  | expression_statement {fprintf(logout,"Line no %d->statement : expression_statement\n\n",lin_count);$$=$1;}
	  | compound_statement  {fprintf(logout,"Line no %d-> statement : compound_statement\n\n",lin_count); $$=$1;}
	  | FOR lparen2 expression_statement expression_statement expression RPAREN statement {fprintf(logout,"Line no %d->statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",lin_count); 

                 string label_start=newLabel();
                 string label_end=newLabel();
                 SymbolInfo* p=new SymbolInfo;
                 p->code=$3->code+"\n";
                 p->code+=label_start+":\n";
                 p->code+=$4->code+"\n";
                 p->code+="mov ax,"+$4->address+"\n";
                 p->code+="cmp ax,0\n";
                 p->code+="je "+label_end+"\n";
                 p->code+=$7->code+"\n";
                 p->code+=$5->code+"\n";
                 p->code+="jmp "+label_start+"\n";
                 p->code+=label_end+":\n\n";


                 $$=p;






                  table->ExitScope(); 
                  cout<<"exitscopefor "; }
	  | IF lparen2 expression RPAREN statement %prec noelse  {fprintf(logout,"Line no %d->statement: IF LPAREN expression RPAREN statement\n\n",lin_count); 
                    string label_f=newLabel();
                    SymbolInfo* p=new SymbolInfo;
                    p->code=$3->code+"\n";
                    p->code+="mov ax,"+$3->address+"\n";
                    p->code+="cmp ax,0\n";
                    p->code+="je "+label_f+"\n";
                    p->code+=$5->code+"\n";
                    p->code+=label_f+":\n\n";
                   
                    $$=p; 
                   
                    table->ExitScope(); 
                    //global_scope_id--; 
                    cout<<"exitscope if ";             
                  
}
	  | IF lparen2 expression RPAREN statement ELSE statement  {fprintf(logout,"Line no %d->statement: IF LPAREN expression RPAREN statement ELSE statement\n\n",lin_count); 

              string label_f=newLabel();
              string label_t=newLabel();
              SymbolInfo* p=new SymbolInfo;
              p->code=$3->code+"\n";
              p->code+="mov ax,"+$3->address+"\n";
              p->code+="cmp ax,0\n";
              p->code+="je "+label_f+"\n";
              p->code+=$5->code+"\n";
              p->code+="jmp "+label_t+"\n";
              p->code+=label_f+":\n";
              p->code+=$7->code+"\n";
              p->code+=label_t+":\n";

             $$=p;


              table->ExitScope(); 

              cout<<"exitscope";}
	  | WHILE lparen2 expression RPAREN statement {fprintf(logout,"Line no %d->statement: WHILE LPAREN expression RPAREN statement\n\n",lin_count); 


              string label_start=newLabel();
              string label_end=newLabel();
              SymbolInfo* p=new SymbolInfo;
              
              p->code=label_start+"\n";
              p->code+=$3->code+"\n";
              p->code+="mov ax,"+$3->address+"\n";
              p->code+="cmp ax,0\n";
              p->code+="je "+label_end+"\n";
              p->code+=$5->code+"\n";
              p->code+="jmp "+label_start+"\n";
              p->code+=label_end+":\n";
                   
                   table->ExitScope(); 
                   cout<<"exitscopewhile";}
	 
          | PRINTLN LPAREN ID RPAREN SEMICOLON  {fprintf(logout,"Line no %d->statement: PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",lin_count);  

if($3->value.c==0) fprintf(logout,"Value of %s is %d\n\n",$3->name.c_str(),$3->value.ival);
else if($3->value.c=1) fprintf(logout,"Value of %s is %f\n\n",$3->name.c_str(),$3->value.fval);
       declare_code+=$3->name+ " dw " +"?\n";
      $$=$3;
      $$->code+="mov ax,"+$3->name+"\n";
      $$->code+="call dec_print\n"; println=1;
      $$->code+="mov ah,2\nmov dl,0dh\nint 21h\nmove ah,2\nmov dl,0ah\nint 21h\n";



}
	  | RETURN expression SEMICOLON {fprintf(logout,"Line no %d->statement: RETURN expression SEMICOLON\n\n",lin_count);

              //$$=new SymbolInfo("return","RETURN");
              //$$->code="\n\n;exit to dos\nMOV AH, 4ch\nINT 21H\n";
              //$$->freturn=$2->address;
              $2->code+="push dx,"+$2->address+"\n"+"ret \n";
              $$=$2;
              
              



}
	  ;
	  
expression_statement 	: SEMICOLON {fprintf(logout,"Line no %d->expression_statement : SEMICOLON\n\n",lin_count);$$=$1;}			
			| expression SEMICOLON {fprintf(logout,"Line no %d->expression_statement : expression SEMICOLON\n\n",lin_count);$$=$1;}
			;
	  
variable : ID  {  fprintf(logout,"Line no %d-> variable: ID\n %s\n\n",lin_count,$1->name.c_str());
                     SymbolInfo* d=table->LookAll($1->name);
                     if(d==NULL) {fprintf(errorout,"Line no %d: Undeclared Variable %s \n\n",lin_count,$1->name.c_str()); $$=dam; error_count++; }
                     else if(d->value.c==2 || d->value.c==3) {fprintf(errorout,"Line no %d: %s is Araay Type\n\n",lin_count,$1->name.c_str());                  $$=dam; error_count++; } 
                     else {$$=d;}    
}
	 | ID LTHIRD expression RTHIRD {
                   fprintf(logout,"Line no %d-> variable: ID LTHIRD expression RTHIRD\n %s\n\n",lin_count,$1->name.c_str());
                SymbolInfo* d=table->LookAll($1->name);
                 if(d==NULL) {fprintf(errorout,"Line no %d: Undeclared variable %s \n\n",lin_count,$1->name.c_str()); $$=dam; error_count++;}
                 
                 else { 
                         
                        if(d->value.c!=2 && d->value.c!=3) {fprintf(errorout,"Line no %d: %s is not a Array type\n\n",lin_count,d->name.c_str()); $$=dam; error_count++; }
                        else if (d->value.arraysize<$3->value.ival){fprintf(errorout,"Line no %d: ArrayOutOfBound Error\n\n",lin_count); $$=dam; error_count++;}
                        else if ($3->value.c==1) {fprintf(errorout,"Line no %d: Array Index is not  <INT> type\n\n",lin_count); $$=dam; error_count++;} 
                        else if ($3->value.ival<0) {fprintf(errorout,"Line no %d: Array Index is Negative\n\n",lin_count); $$=dam; error_count++;}
                        else if ($3->value.arrayl==1) {fprintf(errorout,"Line no %d: Ivalid Index found \n\n"); $$=dam; error_count++;} 
                        else  {  d->value.arraypos=$3->value.ival; $$=d; 

                        $$->code=$3->code+"mov bx, " +$3->address +"\nadd bx, bx\n"; }
                     }
                   


}
	 ;
	 
expression : logic_expression {fprintf(logout,"Line no %d->expression-> logic_expression\n\n",lin_count); $$=$1; $$->address=IntToString($1->value.ival);}		
	   | variable ASSIGNOP logic_expression {
fprintf(logout,"Line no %d->expression-> variable ASSIGNOP logic_expression\n\n",lin_count);
           
          //SymbolInfo* p= new SymbolInfo;
          if($1->value.c==0 && $3->value.c==0) {$1->value.ival=$3->value.ival;}
          else if($1->value.c==0 && $3->value.c==1) { fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",lin_count); error_count++;  $1->value.ival=$3->value.fval;}
          else if($1->value.c==0 && $3->value.c==2) { $1->value.ival=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==0 && $3->value.c==3) { fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",lin_count);
error_count++;  $1->value.ival=$3->value.farray[$3->value.arraypos];}

          else if($1->value.c==1 && $3->value.c==0) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",lin_count); error_count++;  $1->value.fval=$3->value.ival;}
          else if($1->value.c==1 && $3->value.c==1) {$1->value.fval=$3->value.fval;}
          else if($1->value.c==1 && $3->value.c==2) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",lin_count); error_count++;  $1->value.fval=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==1 && $3->value.c==3) {$1->value.fval=$3->value.farray[$3->value.arraypos];}

          else if($1->value.c==2 && $3->value.c==0) {$1->value.iarray[$1->value.arraypos]=$3->value.ival;}
          else if($1->value.c==2 && $3->value.c==1) {fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",lin_count); error_count++;  $1->value.iarray[$1->value.arraypos]=$3->value.fval;}
          else if($1->value.c==2 && $3->value.c==2) {$1->value.iarray[$1->value.arraypos]=$3->value.iarray[$3->value.arraypos];}
          else if($1->value.c==2 && $3->value.c==3) {fprintf(errorout,"Error at %d: Type Casting from 'float' to 'int'\n\n",lin_count);
error_count++;   $1->value.iarray[$1->value.arraypos]=$3->value.farray[$3->value.arraypos]; }

          else if($1->value.c==3 && $3->value.c==0) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",lin_count); error_count++;  $1->value.farray[$1->value.arraypos]=$3->value.ival; } 
          else if($1->value.c==3 && $3->value.c==1) { $1->value.farray[$1->value.arraypos]=$3->value.fval; }
          else if($1->value.c==3 && $3->value.c==2) {fprintf(errorout,"Error at %d: Type Casting from 'int' to 'float'\n\n",lin_count); error_count++;  $1->value.farray[$1->value.arraypos]=$3->value.iarray[$3->value.arraypos]; }
          else if($1->value.c==3 && $3->value.c==3) {$1->value.farray[$1->value.arraypos]=$3->value.farray[$3->value.arraypos];}  
          

         string temp=newTemp();
         declare_code+=temp+ " dw " +"?\n";
         $$=$1;
         $$->code+=$3->code;
         $$->code+="mov ax,"+$3->address+"\n";
         if($1->value.c==0) {$$->code+="mov "+$1->symbol+",ax\n";}
         else if($1->value.c==2) {$$->code+="mov "+$1->symbol+"[bx],ax\n";}
                   
        $$->code+="mov "+temp+",1\n\n";
        $$->address=temp;  


      table->AllScopePrint();

}

         



	
	   ;
			
logic_expression : rel_expression {fprintf(logout,"Line no %d->logic_expression : rel_expression\n\n",lin_count); $$=$1;}	 	
		 | rel_expression LOGICOP rel_expression {
fprintf(logout,"Line no %d->logic_expression : rel_expression LOGICOP rel_expression\n\n",lin_count);
                 if($1->value.arrayl==1) {$$=$1;}
                 else if($3->value.arrayl==1) {$$=$3;}
                 else{
                  SymbolInfo* p= new SymbolInfo;
                  p->code=$1->code+$3->code;
                  string op=$2->name;
                  int temp;
               if($1->value.c==0 && $3->value.c==0) {
                       int x=$1->value.ival;
                       int y=$3->value.ival;
                         
                if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
               else if($1->value.c==0 && $3->value.c==1) {
                         int x=$1->value.ival;
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                 
                else if($1->value.c==0 && $3->value.c==2) {
                         int x=$1->value.ival;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                else if($1->value.c==0 && $3->value.c==3) {
                         int x=$1->value.ival;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                  
                     
                else if($1->value.c==1 && $3->value.c==0) {
                         float x=$1->value.fval;
                         int y=$3->value.ival;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                else if($1->value.c==1 && $3->value.c==1) {
                         float x=$1->value.fval;
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                
                else if($1->value.c==1 && $3->value.c==2) {
                         float x=$1->value.fval;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

                else if($1->value.c==1 && $3->value.c==3) {
                         float x=$1->value.fval;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
 
                else if($1->value.c==2 && $3->value.c==0) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                
               else if($1->value.c==2 && $3->value.c==1) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
                else if($1->value.c==2 && $3->value.c==2) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

  
                else if($1->value.c==2 && $3->value.c==3) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

                else if($1->value.c==3 && $3->value.c==0) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

                else if($1->value.c==3 && $3->value.c==1) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }

               else if($1->value.c==3 && $3->value.c==2) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
               else if($1->value.c==3 && $3->value.c==3) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                 if(op=="&&") temp = x&&y;
		else if(op=="||") temp = x||y;
                                }
 
         p->value.c=0;
         p->value.ival=temp;
         string temp1=newTemp();
         declare_code+=temp1+ " dw " +"?\n";
         string label_t=newLabel();
         string label_f=newLabel();

         p->code+="mov ax,"+$1->address+"\n";
         p->code+="cmp ax,0\n";
         if(op=="&&"){p->code+="je "+label_f+"\n";
                      p->code+="mov ax,"+$3->address+"\n";
                      p->code+="cmp ax,0\n";
                      p->code+="je " + label_f + "\n";
                      p->code+="mov " + temp1 + ",1\n";
                      p->code+="jmp " + label_t+"\n";
                      p->code+=label_f + ":\n";
                      p->code+="mov " + temp1 + ", 0\n";
                      p->code+= label_t + ":\n\n";
                     }
         else if(op=="||"){p->code+="jne "+label_t+"\n";
                      p->code+="mov ax,"+$3->address+"\n";
                      p->code+="cmp ax,0\n";
                      p->code+="jne " + label_t + "\n";
                      p->code+="mov " + temp1 + ",0\n";
                      p->code+="jmp " + label_f+"\n";
                      p->code+=label_t + ":\n";
                      p->code+="mov " + temp1 + ", 1\n";
                      p->code+= label_f + ":\n\n";
}
         p->address=temp1;
         $$=p;
        
 
}

  

}	
		 ;
			
rel_expression	: simple_expression {fprintf(logout,"Line no %d->rel_expression	: simple_expression\n\n",lin_count); $$=$1;}
		| simple_expression RELOP simple_expression {
                 fprintf(logout,"Line no %d->rel_expression: simple_expression RELOP simple_expression\n\n",lin_count);
                 
                 if($1->value.arrayl==1) {$$=$1;}
                 else if($3->value.arrayl==1) {$$=$3;}
                 else{
                  SymbolInfo* p= new SymbolInfo;
                  p->code=$1->code+$3->code;
                  string op=$2->name;
                  int temp;
               if($1->value.c==0 && $3->value.c==0) {
                       int x=$1->value.ival;
                       int y=$3->value.ival;
                         
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
		                                }
               else if($1->value.c==0 && $3->value.c==1) {
                         int x=$1->value.ival;
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	
                                }
                 
                else if($1->value.c==0 && $3->value.c==2) {
                         int x=$1->value.ival;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                else if($1->value.c==0 && $3->value.c==3) {
                         int x=$1->value.ival;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                  
                     
                else if($1->value.c==1 && $3->value.c==0) {
                         float x=$1->value.fval;
                         int y=$3->value.ival;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                else if($1->value.c==1 && $3->value.c==1) {
                         float x=$1->value.fval;
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                
                else if($1->value.c==1 && $3->value.c==2) {
                         float x=$1->value.fval;
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

                else if($1->value.c==1 && $3->value.c==3) {
                         float x=$1->value.fval;
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
 
                else if($1->value.c==2 && $3->value.c==0) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                
               else if($1->value.c==2 && $3->value.c==1) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
                else if($1->value.c==2 && $3->value.c==2) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

  
                else if($1->value.c==2 && $3->value.c==3) {
                         int x=$1->value.iarray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

                else if($1->value.c==3 && $3->value.c==0) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.ival;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

                else if($1->value.c==3 && $3->value.c==1) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.fval;
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }

               else if($1->value.c==3 && $3->value.c==2) {
                         float x=$1->value.farray[$1->value.arraypos];
                         int y=$3->value.iarray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
               else if($1->value.c==3 && $3->value.c==3) {
                         float x=$1->value.farray[$1->value.arraypos];
                         float y=$3->value.farray[$3->value.arraypos];
                        
                if (op==">") temp = x>y;
		else if(op=="<") temp = x<y;
		else if(op==">=") temp = x>=y;
		else if(op=="<=") temp = x<=y;
		else if(op=="==") temp = x==y;
		else if(op=="!=")  temp = x!=y;
	                        }
 
         p->value.c=0;
         p->value.ival=temp;
         string temp1=newTemp();
         declare_code+=temp1+ " dw " +"?\n";
         string label_t=newLabel(); 
         string label_f=newLabel(); 
         p->code+="mov ax,"+$1->address+"\n";
         p->code+="cmp ax,"+$3->address+"\n";
         if(op=="<") {p->code+="jl "+label_t+"\n";}
         else if(op==">") {p->code+="jg "+label_t+"\n";}
         else if(op==">=") {p->code+="jge "+label_t+"\n";}
         else if(op=="<=") {p->code+="jle "+label_t+"\n";}
         else if(op=="==") {p->code+="je "+label_t+"\n";}
         else if(op=="!=") {p->code+="jne "+label_t+"\n";}
         p->code+="mov "+temp1+",0\n";
         p->code+="jmp "+label_f+"\n";
         p->code+=label_t+":\n";
         p->code+="mov "+temp1+",1\n";
         p->code+=label_f+":\n\n";
         p->address=temp1;

         $$=p;
         
 
}


                  } 
 



	
		;
				
simple_expression : term  {fprintf(logout,"Line no %d->simple_expression : term\n\n",lin_count); $$=$1;} 
		  | simple_expression ADDOP term {fprintf(logout,"Line no %d->simple_expression : simple_expression\n\n",lin_count);

                 if($1->value.arrayl==1) {$$=$1;}
                 else if($3->value.arrayl==1) {$$=$3;}
                 else{
                     SymbolInfo* p = new SymbolInfo;
                     p->code=$1->code+$3->code;
                   if($2->name=="+"){
                       if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival+$3->value.ival;}
               else if($1->value.c==0 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.ival+$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival+$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval+$3->value.farray[$3->value.arraypos];}
 
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]+$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]+$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]+$3->value.farray[$3->value.arraypos];}

               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]+$3->value.farray[$3->value.arraypos];}

                 }
                  else if($2->name=="-"){
                    if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival-$3->value.ival;}
               else if($1->value.c==0 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.ival-$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival-$3->value.farray[$3->value.arraypos];}
 
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval-$3->value.farray[$3->value.arraypos];}
            
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]-$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]-$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]-$3->value.farray[$3->value.arraypos];}
                  
               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]-$3->value.farray[$3->value.arraypos];}


                 }

          string temp=newTemp();
          declare_code+=temp+ " dw " +"?\n";
             p->code+="mov ax,"+$1->address+"\n";
              if($2->name=="+"){p->code+="add ax,"+$3->address+"\n";}
              else if($2->name=="-"){p->code+="sub ax,"+$3->address+"\n";}
             p->code+="mov "+temp+",ax\n\n";
             p->address=temp;
             $$=p;
             
   }  
               
     table->AllScopePrint();



} 
		  ;
					
term :	unary_expression {fprintf(logout,"Line no %d->term :	unary_expression\n\n",lin_count); $$=$1;}
     |  term MULOP unary_expression {fprintf(logout,"Line no %d->term :	term MULOP unary_expression\n\n",lin_count);

        if($1->value.arrayl==1) {$$=$1;}
        else if($3->value.arrayl==1) {$$=$3;}
        else{
             SymbolInfo* p=new SymbolInfo;
             p->code=$1->code+$3->code;
             if($2->name=="*"){
               if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival*$3->value.ival;}
               else if($1->value.c==0 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.ival*$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival*$3->value.farray[$3->value.arraypos];}
     
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval*$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]*$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]*$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]*$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]*$3->value.farray[$3->value.arraypos];}
                 }
             else if($2->name=="/"){
               if (($3->value.c==0 && $3->value.ival==0) || ($3->value.c==1 && $3->value.fval==0) || ($3->value.c==2 && $3->value.iarray[$3->value.arraypos]) || ($3->value.c==3 && $3->value.farray[$3->value.arraypos])) {fprintf(errorout,"Line no %d: divedend by zero error\n\n",lin_count); error_count++; p=dam;  }
               else if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival/$3->value.ival;}                
               else if($1->value.c==0 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.ival/$3->value.fval;}
               else if($1->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==0 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.ival/$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==1 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.ival;}
               else if($1->value.c==1 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.fval;}
               else if($1->value.c==1 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==1 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.fval/$3->value.farray[$3->value.arraypos];}
               
               else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]/$3->value.ival;}
               else if($1->value.c==2 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]/$3->value.fval;}
               else if($1->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos]/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==2 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.iarray[$1->value.arraypos]/$3->value.farray[$3->value.arraypos];}
             
               else if($1->value.c==3 && $3->value.c==0) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.ival;}
               else if($1->value.c==3 && $3->value.c==1) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.fval;}
               else if($1->value.c==3 && $3->value.c==2) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.iarray[$3->value.arraypos];}
               else if($1->value.c==3 && $3->value.c==3) {p->value.c=1; p->value.fval=$1->value.farray[$1->value.arraypos]/$3->value.farray[$3->value.arraypos];}
                         

               }
             else if($2->name=="%"){
                
                if($1->value.c==1 || $1->value.c==3 || $3->value.c==1 || $3->value.c==3){fprintf(errorout,"Line no %d: Ivalid operands to binary %\n\n ",lin_count); error_count++; p=dam;}
                else if($1->value.c==0 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.ival % $3->value.ival;}
                else if($2->value.c==0 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.ival % $3->value.iarray[$3->value.arraypos];}
                else if($1->value.c==2 && $3->value.c==0) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos] % $3->value.ival;}
                else if($2->value.c==2 && $3->value.c==2) {p->value.c=0; p->value.ival=$1->value.iarray[$1->value.arraypos] % $3->value.iarray[$3->value.arraypos];}

               }
          string temp=newTemp();
          declare_code+=temp+ " dw " +"?\n";
               
          p->code+="mov dx,0\n";
          p->code+="mov ax,"+$1->address+"\n";
          if($2->name=="*") {p->code+="mul "+$3->address +"\n";}
          else if($2->name=="/" || $2->name=="%"){p->code+="div "+$3->address +"\n";}

          if($2->name=="*" || $2->name=="/"){p->code+="mov "+temp+",ax\n\n";}
          else if($2->name=="%") {p->code+="mov "+temp+",dx\n\n";}
          
          
          p->address=temp;

          $$=p;
           
} 
   table->AllScopePrint();
}
     ;

unary_expression : ADDOP unary_expression { fprintf(logout,"Line no %d-> unary_expression : ADDOP unary_expression\n\n",lin_count);
                   if($2->value.arrayl==1) {$$=$2;}
                   else{
                    SymbolInfo* p= new SymbolInfo;
                    if($1->name=="+") {

                        
                        if($2->value.c==0) {p->value.c=$2->value.c; p->value.ival=$2->value.ival;  }
                        else if($2->value.c==1) {p->value.c=$2->value.c; p->value.fval=$2->value.fval;}
                        else if($2->value.c==2) {p->value.c=0; p->value.ival=$2->value.iarray[$2->value.arraypos];}
                        else if($2->value.c==3) {p->value.c=1; p->value.fval=$2->value.farray[$2->value.arraypos];}
                          }
                   else if($1->name=="-"){
                        if($2->value.c==0) {

                        p->value.c=$2->value.c; 
                        p->value.ival=-$2->value.ival;
}
                        else if($2->value.c==1) {p->value.c=$2->value.c; p->value.fval=-$2->value.fval;}
                        else if($2->value.c==2) {p->value.c=0; p->value.ival=-$2->value.iarray[$2->value.arraypos];}
                        else if($2->value.c==3) {p->value.c=1; p->value.fval=-$2->value.farray[$2->value.arraypos];}
                           


                          }
                        
                     p->code=$2->code;
                     if($1->name=="-"){
                     string temp=newTemp();
                    declare_code+=temp+ " dw " +"?\n";
                    p->code+="mov ax, " + $2->address + "\n";
		    p->code+="neg ax\n";
		    p->code+="mov "+temp+", ax\n\n";


}


                     $$=p;
                    
 }
                  table->AllScopePrint();
                  
} 
		 | NOT unary_expression { fprintf(logout,"Line no %d-> unary_expression : NOT unary_expression\n\n",lin_count);
                   
                   if($2->value.arrayl==1){$$=$2;} 
                   else{
                   SymbolInfo* p=new SymbolInfo;
                   p->value.c=0;
                  
                   if($2->value.c==0) {p->value.ival=!($2->value.ival);
                    


                    }
                   else if($2->value.c==1) {p->value.ival=!($2->value.fval);}
                   else if($2->value.c==2) {p->value.ival=!($2->value.iarray[$2->value.arraypos]);
                   




                   }
                   else if($2->value.c==3) {p->value.ival=!($2->value.farray[$2->value.arraypos]);}
                                        
                    p->code=$2->code;
                    string temp=newTemp();
                    string label1=newLabel(); 
                    string label2=newLabel(); 
                    declare_code+=temp+ " dw " +"?\n";
                    
                    p->code+="mov ax, " + $2->address + "\n";
		    p->code+="cmp ax,0\n";
                    p->code+="je "+label1+"\n";
                    p->code+="mov "+temp+",0\n";
                    p->code+="jmp "+label2+"\n";
                    p->code+=label1+":\n";
                    p->code+="mov "+temp+",1\n";
                    p->code+=label2+":\n";
                    
		    p->address=temp;

                   $$=p;
                   
                         }
                  table->AllScopePrint();
}
		 | factor {fprintf(logout,"Line no %d->unary_expression: factor\n\n",lin_count); $$=$1;}
		 ;
	
factor	: variable  {fprintf(logout,"Line no %d->factor: variable\n\n",lin_count);
                $$=$1;
                if($1->value.arrayl==1) {}                      
                else if($1->value.c==0) { $$->address=$1->symbol;}
                else if($1->value.c==2) {
                string temp=newTemp();
                declare_code+=temp+ " dw " +"?\n";
                $$->code+= "mov ax, " +$1->symbol+"[bx]\n";
                $$->code+="mov "+temp+",ax\n\n";
                
                $$->address=temp; 
               }           



                    }
	| ID LPAREN argument_list RPAREN {fprintf(logout,"Line no %d->factor: ID LPAREN argument_list RPAREN\n\n",lin_count);
             SymbolInfo* p=new SymbolInfo;
           SymbolInfo* temp=table->LookAll($1->name);
         
          if(temp==NULL) {fprintf(errorout,"Error at Line %d: function is not defined\n\n",lin_count); p=dam; error_count++;}
          else if(temp->isF==0) {fprintf(errorout,"Error at Line %d: function is only declared , no defined\n\n",lin_count); p=dam; error_count++; }
          else if(temp->isF==-1) {fprintf(errorout,"Error at Line %d: Not a Function\n\n",lin_count); p=dam; error_count++; }
          else if(temp->fsize!=pos1 ) {fprintf(errorout,"Error at Line %d: parameter numbers are no equal\n\n",lin_count); p=dam; error_count++;} 
          else if(temp->fsize==0 && pos1==0 && temp->fsign==0) {p->value.c=0; p->value.ival=temp->funi;}
          else if(temp->fsize==0 && pos1==0 && temp->fsign==1) {p->value.c=1; p->value.fval=temp->funf;}
          else if(temp->fsize==0 && pos1==0 && temp->fsign==2) {}
          
          else  if(temp->fsize==pos1){ int i=0,k=0;
for(i=0;i<temp->fsize;i++){if(temp->f[i]!=flow1[i]) {fprintf(errorout,"Error at Line %d: perameter is not matched\n\n",lin_count);} p=dam; k=1; error_count++; break; }
          if(k==0){
                   if(temp->fsign==0) {p->value.c=0; p->value.ival=temp->funi;}
                   else if(temp->fsign==1) {p->value.c=1; p->value.fval=temp->funf;}
                   else if(temp->fsign==2) {p->value.arrayl=1;}
  }

}        
         for(int i=0;i<pos1;i++){

            p->code+="mov "+temp->variable[i]+","+IntToString(flow2[i])+"\n";

                        } 
         p->code+="\ncall  " +temp->name+"\n\n";   
         $$=p;
         pos1=0;
               


}





	| LPAREN expression RPAREN {fprintf(logout,"Line no %d->factor: LPAREN expression RPAREN\n\n",lin_count); $$=$2;}
	| CONST_INT       {fprintf(logout,"Line no %d->factor: CONST_INT\n %s\n\n",lin_count,$1->name.c_str()); $$=$1; $$->address=IntToString($1->value.ival); }
	| CONST_FLOAT    {fprintf(logout,"Line no %d->factor: CONST_FLOAT\n %s\n\n",lin_count,$1->name.c_str()); $$=$1;}
	| variable INCOP {fprintf(logout,"Line no %d->factor: variable INCOP\n\n",lin_count);
$$=new SymbolInfo($1->name,$1->type,$1->value.ival,$1->value.fval,$1->value.arraysize,$1->value.arraypos,-1111,-1111,$1->value.c);
 
                          if($1->value.arrayl==1){$$->value.arrayl=1;}
                          else {  
                          int c=$1->value.arraypos;  
                          if($1->value.c==0) {
                          
                          string temp=newTemp();
                            declare_code+=temp+ " dw " +"?\n";
                            string code="";
                            code = code+"mov ax," + $1->symbol+"\n";
                            code+="mov "+temp+",ax\n";
                            code+="inc ax\n";
                            code+="mov "+$1->symbol+",ax\n\n";
                            $$->code=$1->code+code;
                            $$->address=temp;
                            $1->value.ival=$1->value.ival+1;

}
                          else if($1->value.c==1) {$1->value.fval=$1->value.fval+1;}
                          else if($1->value.c==2) {
                          
                           string temp=newTemp();
                           declare_code+=temp+ " dw " +"?\n";
                           string code="";
                         
                           code+= "mov ax, " +$1->symbol+"[bx]\n";
                           code+="mov "+temp+",ax\n";
                           code+="inc ax\n";
                           code+="mov "+$1->symbol+"[bx],ax\n\n";

                           $$->code=$1->code+code;
                           $$->address=temp;
                            $$->value.iarray[c]=$1->value.iarray[c];
                           $1->value.iarray[c]=$1->value.iarray[c]+1;
                            
}
                          else if($1->value.c==3) {$$->value.farray[c]=$1->value.farray[c]; $1->value.farray[c]=$1->value.farray[c]+1;}
                          }
                         
                          
                          table->AllScopePrint(); 
  

}
	| variable DECOP { fprintf(logout,"Line no %d->factor: variable DECOP\n\n",lin_count);
                $$=new SymbolInfo($1->name,$1->type,$1->value.ival,$1->value.fval,$1->value.arraysize,$1->value.arraypos,-1111,-1111,$1->value.c); 
                   
                  if($1->value.arrayl==1){$$->value.arrayl=1;}
                  else {  
                          int c=$1->value.arraypos;  
                          
                          if($1->value.c==0) {  
                            
                            string temp=newTemp();
                            declare_code+=temp+ " dw " +"?\n";
                            string code="";
                            code = code+"mov ax," + $1->symbol+"\n";
                            code+="mov "+temp+",ax\n";
                            code+="dec ax\n";
                            code+="mov "+$1->symbol+",ax\n\n";
                            $$->code=$1->code+code;
                            $$->address=temp;
                            
                            $1->value.ival=$1->value.ival-1;
                            
                            
                              }
                          else if($1->value.c==1) { $1->value.fval=$1->value.fval-1; }
                          else if($1->value.c==2) { 
                          
                           string temp=newTemp();
                           declare_code+=temp+ " dw " +"?\n";
                           string code="";
                         
                           code+= "mov ax, " +$1->symbol+"[bx]\n";
                           code+="mov "+temp+",ax\n";
                           code+="dec ax\n";
                           code+="mov "+$1->symbol+"[bx],ax\n\n";

                           $$->code=$1->code+code;
                           $$->address=temp;
                           $$->value.iarray[c]=$1->value.iarray[c];
                           $1->value.iarray[c]=$1->value.iarray[c]-1;
                           

}
                          else if($1->value.c==3) {$$->value.farray[c]=$1->value.farray[c]; $1->value.farray[c]=$1->value.farray[c]-1;  } 
                       }
                     
                     
                     table->AllScopePrint(); 
           }
	;
	
 

argument_list : arguments {fprintf(logout,"Line no %d->argument_list: arguments\n\n",lin_count);} 
                    |    {fprintf(logout,"Line no %d->argument_list: ",lin_count); }
                    ;
arguments: arguments COMMA logic_expression {fprintf(logout,"Line no %d->arguments: arguments COMMA logic_expression\n\n",lin_count);               
                              if($3->value.c==0 || $3->value.c==1) {flow1[pos1]=$3->value.c; flow2[pos1]=$3->value.ival;
  pos1++;}
                              else {flow1[pos]=-2; pos++;}

}
              | logic_expression {fprintf(logout,"Line no %d->arguments: logic_expression\n\n",lin_count); 


              
               if($1->value.c==0 || $1->value.c==1) {flow1[pos1]=$1->value.c; flow2[pos1]=$1->value.ival; 
                    
                     pos1++;}
               else {flow1[pos]=-2; pos++;}
}
              ;










%%
int main(int argc,char *argv[])
{
        table=new SymbolTable(7);
        dam=new SymbolInfo;
        dam->value.arrayl=1;
        dam->value.c=-2;
        declare_code = "\n";
        
	FILE *fp;	
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}


        logout=fopen("log.txt","w");
        errorout=fopen("error.txt","w");
        asmout=fopen("code.asm","w");	
	

	yyin=fp;
	yyparse();

        fprintf(logout,"Total Line: %d\n\n",lin_count);
        fprintf(logout,"Total Error: %d\n\n",error_count);
        declare_code = declare_code + "\n\n";
 	
 	total_code = initial_code + declare_code + main_code;
 	if(println==1){total_code = total_code + "\n" +dec_print+ "\nEND MAIN\n"+function_code;}
        else {total_code = total_code + "\n" +"\nEND MAIN\n"+function_code;}
        
        fprintf(asmout,"%s",total_code.c_str());
        
	fclose(yyin);
        fclose(logout);
        fclose(errorout);

	
	return 0;
}
