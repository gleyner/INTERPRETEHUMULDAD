  /* Definición Léxica */
%lex

%options case-sensitive

%%

\s+											                
"//".*										              
[/][*][^*]*[*]+([^/*][^*]*[*]+)*[/]			

// Solo debemos usar asignacion, condicionales, ciclos, anidacion de ciclos y condicionales

//Palabras reservadas
'dv' return 'declaracionVariable';
'dc' return 'declaracionConstante';
'console' return 'console'; 
'log' return 'log';
'declararF' return 'declararFuncion';
'return' return 'return';
'null' return 'null';
'sentenciaIf' return 'sentenciaIf';
'contrarioIf' return 'contrarioIf';//else
'true' return 'true'; 
'false' return 'false'; 
'sentenciaWhile' return 'sentenciaWhile';
'do' return 'do';                    
'sentenciaFor' return 'sentenciaFor';

//Signos
';' return 'punto_coma';
',' return 'coma';
':' return 'dos_puntos';
'{' return 'signo_apertura'; 
'}' return 'signo_cierre'; 
'(' return 'par_izq_gra'; 
')' return 'par_der_gra'; 
'[' return 'cor_izq';
']' return 'cor_der';
'.' return 'punto';
'++' return 'mas_mas';
'+' return 'mas';
'--' return 'menos_menos'
'-' return 'menos';
'**' return 'potencia';
'*' return 'por';
'/' return 'div';
'%' return 'mod';
'<=' return 'menor_igual'; 
'>=' return 'mayor_igual'; 
'>' return 'mayor'; 
'<' return 'menor'; 
'==' return 'igual_que'; 
'$=' return 'igual'; 
'!=' return 'dif_que'; 
'&&' return 'and'; 
'||' return 'or'; 
'!' return 'not'; 
'?' return 'interrogacion';



//Patrones (Expresiones regulares)
\"[^\"]*\"			{ yytext = yytext.substr(0,yyleng-0); return 'string'; }
\'[^\']*\'			{ yytext = yytext.substr(0,yyleng-0); return 'string'; }
\`[^\`]*\`			{ yytext = yytext.substr(0,yyleng-0); return 'string'; }
[0-9]+("."[0-9]+)?\b  	return 'number';
([a-zA-Z])[a-zA-Z0-9_]* return 'id';

//Fin del archivo
<<EOF>>				return 'EOF';
//Errores lexicos
.					{
  const er = new error_1.Error({ tipo: 'lexico', linea: `${yylineno + 1}`, descripcion: `El valor "${yytext}" no es valido, columna: ${yylloc.first_column + 1}` });
  errores_1.Errores.getInstance().push(er);
  }
/lex

//Imports
%{
  const { NodoAST } = require('../arbol/nodoAST');
  const error_1 = require("../arbol/error");
  const errores_1 = require("../arbol/errores");
%}

/* Asociación de operadores y precedencia */

%left 'interrogacion'
%left 'or'
%left 'and'
%left 'not'
%left 'igual_que' 'dif_que'
%left 'mayor' 'menor' 'mayor_igual' 'menor_igual'
%left 'mas' 'menos'
%left 'por' 'div' 'mod'
%left 'umenos'
%right 'potencia'
%left 'mas_mas' 'menos_menos'

%start S

%%

//Definición de la Grámatica

S
  : INSTRUCCIONES EOF { return new NodoAST({label: 'S', hijos: [$1], linea: yylineno}); }
;


INSTRUCCIONES
  : INSTRUCCIONES INSTRUCCION  { $$ = new NodoAST({label: 'INSTRUCCIONES', hijos: [...$1.hijos, ...$2.hijos], linea: yylineno}); }
  | INSTRUCCION                { $$ = new NodoAST({label: 'INSTRUCCIONES', hijos: [...$1.hijos], linea: yylineno}); }
;

INSTRUCCION
  : DECLARACION_VARIABLE /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | DECLARACION_FUNCION /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | DECLARACION_TYPE /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | ASIGNACION /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | CONSOLE_LOG /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | INSTRUCCION_IF /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | RETURN /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | WHILE /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | DO_WHILE /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | FOR /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | LLAMADA_FUNCION /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  | INCREMENTO_DECREMENTO { $$ = new NodoAST({label: 'INSTRUCCION', hijos: [$1], linea: yylineno}); }
  // | error { console.error('Este es un error sintáctico: ' + yytext + ', en la linea: ' + this._$.first_line + ', en la columna: ' + this._$.first_column); }
;

LLAMADA_FUNCION 
  : id par_izq_gra par_der_gra punto_coma { $$ = new NodoAST({label: 'LLAMADA_FUNCION', hijos: [$1,$2,$3,$4], linea: yylineno}); }
  | id par_izq_gra LISTA_EXPRESIONES par_der_gra punto_coma { $$ = new NodoAST({label: 'LLAMADA_FUNCION', hijos: [$1,$2,$3,$4,$5], linea: yylineno}); }
;

LLAMADA_FUNCION_EXP 
  : id par_izq_gra par_der_gra { $$ = new NodoAST({label: 'LLAMADA_FUNCION_EXP', hijos: [$1,$2,$3], linea: yylineno}); }
  | id par_izq_gra LISTA_EXPRESIONES par_der_gra { $$ = new NodoAST({label: 'LLAMADA_FUNCION_EXP', hijos: [$1,$2,$3,$4], linea: yylineno}); }
;

WHILE 
  : sentenciaWhile par_izq_gra EXP par_der_gra signo_apertura INSTRUCCIONES signo_cierre { $$ = new NodoAST({label: 'WHILE', hijos: [$1,$2,$3,$4,$5,$6,$7], linea: yylineno}); }
;

// Falta
DO_WHILE 
  : do signo_apertura INSTRUCCIONES signo_cierre sentenciaWhile par_izq_gra EXP par_der_gra punto_coma { $$ = new NodoAST({label: 'DO_WHILE', hijos: [$1,$2,$3,$4,$5,$6,$7,$8,$9], linea: yylineno}); }
;

FOR 
  : sentenciaFor par_izq_gra DECLARACION_VARIABLE EXP punto_coma ASIGNACION_FOR par_der_gra signo_apertura INSTRUCCIONES signo_cierre { $$ = new NodoAST({label: 'FOR', hijos: [$1,$2,$3,$4,$5,$6,$7,$8,$9,$10], linea: yylineno}); }
  | sentenciaFor par_izq_gra ASIGNACION EXP punto_coma ASIGNACION_FOR par_der_gra signo_apertura INSTRUCCIONES signo_cierre { $$ = new NodoAST({label: 'FOR', hijos: [$1,$2,$3,$4,$5,$6,$7,$8,$9,$10], linea: yylineno}); }
;

ASIGNACION 
  //variable = EXP ;
  
  : id TIPO_IGUAL EXP punto_coma { $$ = new NodoAST({label: 'ASIGNACION', hijos: [$1,$2,$3,$4], linea: yylineno}); }

  // type.accesos = EXP ; || type.accesos[][] = EXP;
  
  | id LISTA_ACCESOS_TYPE TIPO_IGUAL EXP punto_coma { $$ = new NodoAST({label: 'ASIGNACION', hijos: [$1,$2,$3,$4,$5], linea: yylineno}); }

;

TIPO_IGUAL 
  : igual { $$ = new NodoAST({label: 'TIPO_IGUAL', hijos: [$1], linea: yylineno}); }
  | mas igual { $$ = new NodoAST({label: 'TIPO_IGUAL', hijos: [$1,$2], linea: yylineno}); }
  | menos igual { $$ = new NodoAST({label: 'TIPO_IGUAL', hijos: [$1,$2], linea: yylineno}); }
;

ASIGNACION_FOR 
  : id TIPO_IGUAL EXP { $$ = new NodoAST({label: 'ASIGNACION_FOR', hijos: [$1,$2,$3], linea: yylineno}); }
  | id mas_mas { $$ = new NodoAST({label: 'ASIGNACION_FOR', hijos: [$1,$2], linea: yylineno}); }
  | id menos_menos { $$ = new NodoAST({label: 'ASIGNACION_FOR', hijos: [$1,$2], linea: yylineno}); }
;

RETURN 
  : return EXP punto_coma { $$ = new NodoAST({label: 'RETURN', hijos: [$1,$2,$3], linea: yylineno}); }
  | return punto_coma { $$ = new NodoAST({label: 'RETURN', hijos: [$1,$2], linea: yylineno}); }
;

INSTRUCCION_IF 
  : IF /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION_IF', hijos: [$1], linea: yylineno}); }
  | IF ELSE /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION_IF', hijos: [$1,$2], linea: yylineno}); }
  | IF LISTA_ELSE_IF /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION_IF', hijos: [$1,$2], linea: yylineno}); }
  | IF LISTA_ELSE_IF ELSE /*--> - <--*/ { $$ = new NodoAST({label: 'INSTRUCCION_IF', hijos: [$1,$2,$3], linea: yylineno}); }
;

// Se modifico el if
IF 
  : sentenciaIf par_izq_gra EXP par_der_gra signo_apertura INSTRUCCIONES signo_cierre { $$ = new NodoAST({label: 'IF', hijos: [$1,$2,$3,$4,$5,$6,$7], linea: yylineno}); }
;

// Se modifico el else
ELSE 
  : contrarioIf signo_apertura INSTRUCCIONES signo_cierre { $$ = new NodoAST({label: 'ELSE', hijos: [$1,$2,$3,$4], linea: yylineno}); }
;

// Se modifico el if else
ELSE_IF 
  : contrarioIf sentenciaIf par_izq_gra EXP par_der_gra signo_apertura INSTRUCCIONES signo_cierre { $$ = new NodoAST({label: 'ELSE_IF', hijos: [$1,$2,$3,$4,$5,$6,$7,$8], linea: yylineno}); }
;

LISTA_ELSE_IF 
  : LISTA_ELSE_IF ELSE_IF /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_ELSE_IF', hijos: [...$1.hijos, $2], linea: yylineno}); }
  | ELSE_IF /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_ELSE_IF', hijos: [$1], linea: yylineno}); }
;

DECLARACION_FUNCION 

  //Funcion sin parametros y sin tipo -> function test() { INSTRUCCIONES }
  
  : declararFuncion id par_izq_gra par_der_gra signo_apertura INSTRUCCIONES signo_cierre { $$ = new NodoAST({label: 'DECLARACION_FUNCION', hijos: [$1, $2, $3, $4, $5, $6, $7], linea: yylineno}); }

;

LISTA_PARAMETROS 
  : LISTA_PARAMETROS coma PARAMETRO { $$ = new NodoAST({label: 'LISTA_PARAMETROS', hijos: [...$1.hijos,$2,$3], linea: yylineno}); } //Revisar si agrego o no coma
  | PARAMETRO { $$ = new NodoAST({label: 'LISTA_PARAMETROS', hijos: [$1], linea: yylineno}); }
;

PARAMETRO 
  : id dos_puntos TIPO_VARIABLE_NATIVA { $$ = new NodoAST({label: 'PARAMETRO', hijos: [$1, $2, $3], linea: yylineno}); }
  | id dos_puntos TIPO_VARIABLE_NATIVA LISTA_CORCHETES { $$ = new NodoAST({label: 'PARAMETRO', hijos: [$1, $2, $3, $4], linea: yylineno}); }
  //| id dos_puntos Array menor TIPO_VARIABLE_NATIVA mayor { $$ = new NodoAST({label: 'PARAMETRO', hijos: [$1,$2,$3,$4,$5,$6], linea: yylineno}); }
;

DECLARACION_TYPE 
  : type id igual llave_izq LISTA_ATRIBUTOS llave_der { $$ = new NodoAST({label: 'DECLARACION_TYPE', hijos: [$1, $2, $3, $4, $5, $6], linea: yylineno}); }
  | type id igual llave_izq LISTA_ATRIBUTOS llave_der punto_coma { $$ = new NodoAST({label: 'DECLARACION_TYPE', hijos: [$1, $2, $3, $4, $5, $6, $7], linea: yylineno}); }
;

LISTA_ATRIBUTOS 
  : ATRIBUTO coma LISTA_ATRIBUTOS { $$ = new NodoAST({label: 'LISTA_ATRIBUTOS', hijos: [$1,$2,...$3.hijos], linea: yylineno}); } //Revisar si agrego o no coma
  | ATRIBUTO { $$ = new NodoAST({label: 'LISTA_ATRIBUTOS', hijos: [$1], linea: yylineno}); }
;

ATRIBUTO 
  : id dos_puntos TIPO_VARIABLE_NATIVA { $$ = new NodoAST({label: 'ATRIBUTO', hijos: [$1, $2, $3], linea: yylineno}); }
  | id dos_puntos TIPO_VARIABLE_NATIVA LISTA_CORCHETES { $$ = new NodoAST({label: 'ATRIBUTO', hijos: [$1,$2,$3,$4], linea: yylineno}); }
;

DECLARACION_VARIABLE 
  : TIPO_DEC_VARIABLE LISTA_DECLARACIONES punto_coma { $$ = new NodoAST({label: 'DECLARACION_VARIABLE', hijos: [$1,$2,$3], linea: yylineno});  }
;


LISTA_DECLARACIONES 
  : LISTA_DECLARACIONES coma DEC_ID /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [...$1.hijos,$3], linea: yylineno}); } //No utilice las comas
  | LISTA_DECLARACIONES coma DEC_ID_TIPO /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [...$1.hijos,$3], linea: yylineno}); }
  | LISTA_DECLARACIONES coma DEC_ID_TIPO_CORCHETES /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [...$1.hijos,$3], linea: yylineno}); }
  | LISTA_DECLARACIONES coma DEC_ID_EXP /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [...$1.hijos,$3], linea: yylineno}); }
  | LISTA_DECLARACIONES coma DEC_ID_TIPO_EXP /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [...$1.hijos,$3], linea: yylineno}); }
  | LISTA_DECLARACIONES coma DEC_ID_TIPO_CORCHETES_EXP /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [...$1.hijos,$3], linea: yylineno}); }
  | DEC_ID /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [$1], linea: yylineno}); }
  | DEC_ID_TIPO /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [$1], linea: yylineno}); }
  | DEC_ID_TIPO_CORCHETES /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [$1], linea: yylineno}); }
  | DEC_ID_EXP /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [$1], linea: yylineno}); }
  | DEC_ID_TIPO_EXP /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [$1], linea: yylineno}); }
  | DEC_ID_TIPO_CORCHETES_EXP /*--> - <--*/ { $$ = new NodoAST({label: 'LISTA_DECLARACIONES', hijos: [$1], linea: yylineno}); }
;


DEC_ID_TIPO_CORCHETES_EXP 
  : id dos_puntos TIPO_VARIABLE_NATIVA LISTA_CORCHETES igual EXP { $$ = new NodoAST({label: 'DEC_ID_TIPO_CORCHETES_EXP', hijos: [$1,$2,$3,$4,$5,$6], linea: yylineno}); }
;


DEC_ID_TIPO_EXP
  : id dos_puntos TIPO_VARIABLE_NATIVA igual EXP { $$ = new NodoAST({label: 'DEC_ID_TIPO_EXP', hijos: [$1,$2,$3,$4,$5], linea: yylineno}); }
;


DEC_ID_EXP 
  : id igual EXP { $$ = new NodoAST({label: 'DEC_ID_EXP', hijos: [$1,$2,$3], linea: yylineno}); }
;


DEC_ID  
  : id  { $$ = new NodoAST({label: 'DEC_ID', hijos: [$1], linea: yylineno}); }
;

LISTA_CORCHETES 
  : LISTA_CORCHETES cor_izq cor_der { $$ = new NodoAST({label: 'LISTA_CORCHETES', hijos: [...$1.hijos, '[]'], linea: yylineno}); }
  | cor_izq cor_der { $$ = new NodoAST({label: 'LISTA_CORCHETES', hijos: ['[]'], linea: yylineno}); }
;

INCREMENTO_DECREMENTO
  : id mas_mas punto_coma { $$ = new NodoAST({label: 'INCREMENTO_DECREMENTO', hijos: [$1,$2,$3], linea: yylineno}); }
  | id menos_menos punto_coma { $$ = new NodoAST({label: 'INCREMENTO_DECREMENTO', hijos: [$1,$2,$3], linea: yylineno}); }
;

EXP
  //Operaciones Aritmeticas
  : menos EXP %prec umenos /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2], linea: yylineno}); }
  | EXP mas EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP menos EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP por EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP div EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP mod EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP potencia EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | id mas_mas /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2], linea: yylineno}); }
  | id menos_menos /*-->- --*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2], linea: yylineno}); }
  | par_izq EXP par_der /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  //Operaciones de Comparacion
  | EXP mayor EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP menor EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP mayor_igual EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP menor_igual EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP igual_que EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP dif_que EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  //Operaciones Lógicas
  | EXP and EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | EXP or EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2, $3], linea: yylineno}); }
  | not EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1, $2], linea: yylineno}); }
  //Valores Primitivos
  | number /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [new NodoAST({label: 'NUMBER', hijos: [$1], linea: yylineno})], linea: yylineno}); }
  | string /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [new NodoAST({label: 'STRING', hijos: [$1], linea: yylineno})], linea: yylineno}); }
  | id /*--> - <--*/  { $$ = new NodoAST({label: 'EXP', hijos: [new NodoAST({label: 'ID', hijos: [$1], linea: yylineno})], linea: yylineno}); }
  | true /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [new NodoAST({label: 'BOOLEAN', hijos: [$1], linea: yylineno})], linea: yylineno}); }
  | false /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [new NodoAST({label: 'BOOLEAN', hijos: [$1], linea: yylineno})], linea: yylineno}); }
  | null /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [new NodoAST({label: 'NULL', hijos: [$1], linea: yylineno})], linea: yylineno}); }
  //Arreglos
  | cor_izq LISTA_EXPRESIONES cor_der /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1,$2,$3], linea: yylineno}); }
  | cor_izq cor_der /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1,$2], linea: yylineno}); }
  //Types - accesos
  | ACCESO_TYPE /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1], linea: yylineno}); }
  | TYPE /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1], linea: yylineno}); }
  //Funciones
  | LLAMADA_FUNCION_EXP /*--> - <--*/ { $$ = new NodoAST({label: 'EXP', hijos: [$1], linea: yylineno}); }
;

TYPE 
  : llave_izq ATRIBUTOS_TYPE llave_der { $$ = new NodoAST({label: 'TYPE', hijos: [$1,$2,$3], linea: yylineno}); }
;

ATRIBUTOS_TYPE 
  : ATRIBUTO_TYPE coma ATRIBUTOS_TYPE { $$ = new NodoAST({label: 'ATRIBUTOS_TYPE', hijos: [$1,$2,...$3.hijos], linea: yylineno}); }
  | ATRIBUTO_TYPE { $$ = new NodoAST({label: 'ATRIBUTOS_TYPE', hijos: [$1], linea: yylineno}); }
;

ATRIBUTO_TYPE 
  : id dos_puntos EXP { $$ = new NodoAST({label: 'ATRIBUTO_TYPE', hijos: [$1,$2,$3], linea: yylineno}); }
;

ARRAY_LENGTH 
  : id punto length /*--> - <--*/ { $$ = new NodoAST({label: 'ARRAY_LENGTH', hijos: [$1,$2,$3], linea: yylineno}); }
  | id LISTA_ACCESOS_ARREGLO punto length /*--> - <--*/ { $$ = new NodoAST({label: 'ARRAY_LENGTH', hijos: [$1,$2,$3,$4], linea: yylineno}); }
  | id LISTA_ACCESOS_TYPE punto length /*--> - <--*/ { $$ = new NodoAST({label: 'ARRAY_LENGTH', hijos: [$1,$2,$3,$4], linea: yylineno}); }
;

ARRAY_POP
  : id punto pop par_izq par_der /*--> - <--*/ { $$ = new NodoAST({label: 'ARRAY_POP', hijos: [$1,$2,$3,$4,$5], linea: yylineno}); }
  | id LISTA_ACCESOS_ARREGLO punto pop par_izq par_der /*--> - <--*/ { $$ = new NodoAST({label: 'ARRAY_POP', hijos: [$1,$2,$3,$4,$5,$6], linea: yylineno}); }
  | id LISTA_ACCESOS_TYPE punto pop par_izq par_der /*--> - <--*/ { $$ = new NodoAST({label: 'ARRAY_POP', hijos: [$1,$2,$3,$4,$5,$6], linea: yylineno}); }
;

TERNARIO 
  : EXP interrogacion EXP dos_puntos EXP { $$ = new NodoAST({label: 'TERNARIO', hijos: [$1,$2,$3,$4,$5], linea: yylineno}); }
;

ACCESO_ARREGLO 
  : id LISTA_ACCESOS_ARREGLO { $$ = new NodoAST({label: 'ACCESO_ARREGLO', hijos: [$1, $2], linea: yylineno}); }
;

ACCESO_TYPE 
  : id LISTA_ACCESOS_TYPE { $$ = new NodoAST({label: 'ACCESO_TYPE', hijos: [$1, $2], linea: yylineno}); }
;

LISTA_EXPRESIONES 
  : LISTA_EXPRESIONES coma EXP { $$ = new NodoAST({label: 'LISTA_EXPRESIONES', hijos: [...$1.hijos,$2,$3], linea: yylineno}); }
  | EXP { $$ = new NodoAST({label: 'LISTA_EXPRESIONES', hijos: [$1], linea: yylineno}); }
;


TIPO_DEC_VARIABLE
  : declaracionVariable       { $$ = new NodoAST({label: 'TIPO_DEC_VARIABLE', hijos: [$1], linea: yylineno}); }
  | declaracionConstante     { $$ = new NodoAST({label: 'TIPO_DEC_VARIABLE', hijos: [$1], linea: yylineno}); }
;

CONSOLE_LOG 
  : console punto log par_izq_gra LISTA_EXPRESIONES par_der_gra punto_coma { $$ = new NodoAST({label: 'CONSOLE_LOG', hijos: [$1,$2,$3,$4,$5,$6,$7], linea: yylineno}); }
;
