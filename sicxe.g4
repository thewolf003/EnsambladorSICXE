grammar sicxe;								//nombre de la gramatica

/*
*opciones de compilacion de la gramatica
*/
options {							
    language=CSharp2;								//lenguaje objetivo de la gramatica
}

/*
*	Reglas del Parser
*/

programa					
	: inicio
	;

inicio
	: simbolo 'START' CONS NEWLINE*
	;

expresion returns[string[] value = new string[6]]
    : simbolo instruct NEWLINE{$value=$instruct.value;}	| expresion2
    ;

expresion2
    : 'END' ope? NEWLINE*
    ;

instruct returns[string[] value = new string[6]]
    : FORMATO1 {$value[1] = "1"; $value[2] = "1";}|forma2 {$value[0]=$forma2.value[0];$value[1]=$forma2.value[1];$value[2]="1";}|
		simple {$value[0]=$simple.value[0];$value[1]=$simple.value[1];$value[2]="1";}|indirecto {$value[0]=$indirecto.value[0];$value[1]=$indirecto.value[1];$value[2]="1";}|
		inmediato {$value[0]=$inmediato.value[0];$value[1]=$inmediato.value[1];$value[2]="1";}|
        directivo {$value[1]=$directivo.value[1];$value[3]=$directivo.value[2];$value[4]=$directivo.value[3];
		$value[5]=$directivo.value[4];}|
		dirrsub {$value[1]=$dirrsub.value; $value[2]="1";}
    ;
 
 simple returns[string[] value = new string[2]]
    : index {$value[0]="simple"; $value[1] = $index.value;} |noindex {$value[0]="simple"; $value[1] = $noindex.value;}
    ;

index returns[string value]
    : normal exprcalc ',' EQUIS {$value=$normal.value;} |exten exprcalc ',' EQUIS {$value=$exten.value;}
    ;

ope
    : CONS|ETIQ
    ;

normal returns[string value]
    : FORMATO34 {$value = "3";}
    ;

exten returns[string value]
    : '+' FORMATO34 {$value = "4";}
    ;

noindex returns[string value]
    : normal exprcalc {$value=$normal.value;}| exten exprcalc {$value=$exten.value;}
    ;

indirecto returns[string[] value = new string[2]]
    : normal '@' exprcalc {$value[0]="indirecto"; $value[1] = $normal.value;}|exten '@' exprcalc {$value[0]="indirecto"; $value[1] = $exten.value;}
    ;

inmediato returns[string[] value = new string[2]] 
    : normal '#' exprcalc {$value[0]="inmediato"; $value[1] = $normal.value;}| exten '#' exprcalc {$value[0]="inmediato"; $value[1] = $exten.value;}
    ;

forma2 returns[string[] value=new string[2]]
    : insunreg {$value[1]="2";}| insdosreg {$value[1]="2";}| insnumreg {$value[1]="2";}|insnumnoreg {$value[1]="2";}
    ;

insunreg
    : FORMATO2UNREG registros
    ;

insdosreg
    : FORMATO2DOSREG registros ',' registros
    ;

insnumreg
	: FORMATO2REGNUM registros ',' CONS
	;

insnumnoreg
	: FORMATO2NUMNOREG CONS
	;

registros
	: REG | EQUIS
	;

simbolo
    : ETIQ |
    ;

directivo returns[string[] value = new string[5]]//los campos 2, 3 y 4 contienen direccion/valor de equ y tipo de termino y si es SE
	: normaldirec {$value[1]=$normaldirec.value[0];$value[2]=$normaldirec.value[1];$value[3]=$normaldirec.value[2];
	$value[4]=$normaldirec.value[3];}
	|specdirec {$value[1]=$specdirec.value;}
	;

normaldirec returns[string[] value = new string[4]]
	: direcnum {$value[0]=$direcnum.value;}|direcsimb|
	direqu{$value[1]=$direqu.value[0].ToString("X4");$value[2]=$direqu.value[1].ToString(); 
	$value[3]=$direqu.value[2].ToString();}|
	dirorg|diruse|direxref|dircsect|dirextdef
	;

direcnum returns[string value]
	: WORD exprcalc{$value="3";}|RESB exprcalc{$value = $exprcalc.value[0].ToString();}|RESW exprcalc{$value = (Global.HexHtoInt($exprcalc.value[0].ToString())*3).ToString();}
	;

direqu returns[int[] value = new int[3]]
	: EQDIR exprcalc{ $value[0] = $exprcalc.value[0]; $value[1] = $exprcalc.value[1]; $value[2] = $exprcalc.value[2];}|
	EQDIR POR{$value[0]=obtenCP(); $value[1]=1;  $value[2]=0;}	//numeros positivos indican que es relativo}
	;

dirorg
	: ORG CONS
	;

diruse
	: USE (ETIQ | )
	;
direcsimb
	: DIRBAS ETIQ
	;

direxref
	: EXTREF ETIQ (',' ETIQ)* 
	;

dirextdef
	: EXTDEF ETIQ (',' ETIQ)* 
	;

dircsect
	: CSECT
	;

specdirec returns[string value]
	: BYTDIR tipores {$value=$tipores.value;}
	;


tipores returns[string value]
	: 'C' '\'' ETIQ '\'' {$value = $ETIQ.text.Length.ToString();}| 'X' '\'' CONS '\''  {$value = (System.Math.Ceiling((double)$CONS.text.Length / 2)).ToString();}
	;

dirrsub returns[string value]
	: RSUB {$value="3";}| '+' RSUB {$value="4";}
	;

exprcalc returns[int[] value = new int[2]]						//El valor calculado por la expresion sera regresado como un entero.
	:	
	a = multiplicacion{$value = $a.value;} (		//Se asina el valor que se retornara en la regla.
	MAS b = multiplicacion {$value[0] =$value[0]+ $b.value[0]; $value[1] =$value[1] + $b.value[1]; 
	$value[2] =$value[2] + $b.value[2];}				//El valor se suma con el actual en la expresion.
	|
	MENOS b = multiplicacion{$value[0] =$value[0]- $b.value[0]; $value[1] =$value[1] - $b.value[1];
	$value[2] =$value[2] + $b.value[2];})*	//El valor se resta con el actual y se imprime el valor.
	;

multiplicacion returns[int[] value = new int[2]]					//La regla retorna un entero.
	:	
	a = numero{$value = $a.value;}  (				//Se asigna el valor que se regresara.
	POR b = numero{if($value[1]==0 && $b.value[1]==0){$value[0] =$value[0]* $b.value[0]; $value[1] =$value[1] + $b.value[1];}
			else{$value[0] =$value[0]* $b.value[0]; $value[1] =10000;}}		//Se calcula la multiplicacion 
	|
	ENTRE b = numero{if($value[1]==0 && $b.value[1]==0){$value[0] =$value[0]/ $b.value[0]; $value[1] =$value[1] + $b.value[1];
	$value[2] =$value[2] + $b.value[2];}
			else{$value[0] =$value[0]/ $b.value[0]; $value[1] =10000; $value[2] =$value[2] + $b.value[2];}}	)*	//Se calcula la division.
	;

numero returns[int[] value = new int[3]]							//La regla retonara un entero.
	:
	CONS{$value[0]=convertNum($CONS.text);$value[1]=0; $value[2]=0;}|	//termino absoluto lo pasa a decimal si esta en HEX
	tbsimbolo	{$value = $tbsimbolo.value;}			//se convierte a entero la cadena de entrada de la consola.			
	|
	MENOS tbsimbolo {$value[0] = -1*$tbsimbolo.value[0]; $value[1] = -1*$tbsimbolo.value[1]; $value[2] = $tbsimbolo.value[2];}
	|	
	PARENI exprcalc PAREND		{$value = $exprcalc.value;}		//se asigna el valor de la expresion dentro del parentesis.
	|
	MENOS PARENI exprcalc PAREND {$value[0] = -1*$exprcalc.value[0]; $value[1] = -1*$exprcalc.value[1]; $value[2] = $exprcalc.value[2];}
	;

tbsimbolo returns[int[] value = new int[3]]
	:
	ETIQ {$value[0]=buscarEtiq($ETIQ.text); int se = 0; $value[1]=buscaTipo($ETIQ.text, ref se); $value[2] = se;}|	
	;

/*
*	Reglas del Lexer.
*/

EQUIS
	: 'X'
	;

FORMATO1
    : ('FIX'|'FLOAT'|'HIO'|'NORM'|'SIO'|'TIO')
    ;

FORMATO34
    : ('ADD'|'COMP'|'J'|'JGT'|'JLT'|'JSUB'|'LDA'|'LDB'|'LDCH'|'LDS'|'LDT'|'LDX'|'LPS'|'MUL'|'MULF'|'RD'|'STA'|'STCH'
	  |'STL'|'SUB'|'TIX'|'WD')
    ;

FORMATO2UNREG
    : ('CLEAR'|'TIXR')
    ;

FORMATO2DOSREG
    : ('ADDR'|'COMPR'|'MULR'|'RMO'|'SUBR')
    ;

FORMATO2REGNUM
	: ('SHIFTL'|'SHIFTR')
	;

FORMATO2NUMNOREG
	: 'SVC'
	;

REG
    : ('A'|'L'|'B'|'S'|'T'|'F')
    ;

WORD
	: 'WORD'
	;

RESB
	: 'RESB'
	;

RESW
	: 'RESW'
	;

DIRBAS
	: 'BASE'
	;

BYTDIR
	: 'BYTE'
	;

RSUB
	: 'RSUB'
	;

EQDIR
	: 'EQU'
	;

ORG
	: 'ORG'
	;

USE
	: 'USE'
	 ;

EXTREF
	: 'EXTREF'
	;

EXTDEF
	: 'EXTDEF'
	;

CSECT
	: 'CSECT'
	;

PARENI
	:	'('		//token de parentesis derecho
	;
PAREND
	:	')'		//token de parentesis izquierdo.
	;
MAS 
	: '+'		//token de signo mas
	;
MENOS 
	: '-'		//token de signo menos
	;
POR
	: '*'		//token de signo por
	;

ENTRE
	: '/'		//token de signo entre
	;

CONS
    : ((('a'..'f')|('A'..'F')|('0'..'9'))+)('H'|)  
    ;

ETIQ
    : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9')*
    ;



NEWLINE: ('\r'? '\n' | '\r')+ ;

WS
	: (' '|'\t')+ {Skip();}	//tokens que identifican las secuencas de escape.
	;