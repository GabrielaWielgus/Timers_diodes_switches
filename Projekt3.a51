PROG SEGMENT CODE

LED BIT P2.0
SWITCH BIT P3.0
	
Cel DATA 30h ;2,4,8...
Ilosc EQU 6 ;ilosc diod-2, ostatnia zawsze 0h,pierwsza zawsze FE

CSEG AT 0
JMP start
RSEG PROG
	
	start:
		CLR TR0 ;ZATRZYMUJE TIMER
		MOV P2,#0FFh
		MOV A,#0h
	MAIN:
		JNB	SWITCH,TIMER
		JB SWITCH, start
	TIMER:
		JB SWITCH, STOP
		CLR TR0 ;ZATRZYMUJE TIMER - zeby rejestr TL0 byl taki sam
		MOV TMOD,#01 ; 16-bitowy timer 0
		MOV TH0,#76
		MOV TL0,#01
		CLR TF0 ;zeruje flage przepelnienia
		SETB TR0 ; startujemy timer 0
		JNB TF0,$ ;Jezeli TF0 nie jest ustawione to nie ma przepelnienia
		JB TF0,SKOK ; skacze, jezeli flaga przepelniona
		
	SKOK:
		INC A ;DODAJE DO AKUMULATORA 1 PO KAZDYM PRZEPELNIENIU
		MOV 20h,A ;ilosc przepelnien do komorki pod adresem 20h
		MOV R4, 20h ;przypisanie ilosci przepelnien, nie trzeba uzyc akumulatora mozna zostawic rejestr, ale w zadaniu akumuator
		JMP TIMER ; po dodaniu wraca do timera
	LICZ:
		MOV R0, #Cel ;2,4,8...
		MOV R1, #Ilosc ;ile diod
		
		MOV R4, 20h ;musi byc powtorzenie, bo inkrementuje w petli
		ACALL CZEKAJ	
			
		MOV P2,#0FEh ;zapalenie pierwszej diody
		MOV B,#1 ;jedynka przypisana do B
		
		MOV R4, 20h ;musi byc powtorzenie, bo inkrementuje w petli
		ACALL CZEKAJ
				
	INIT:
		MOV A,#2 ;dwojka przypisana do akumulatora
		MUL AB ;wymnozenie A*B
		MOV Cel,A
		MOV A,P2 
		MOV B,Cel
		SUBB A,B
		MOV P2,A
		
		MOV R4, 20h ;musi byc powtorzenie, bo inkrementuje w petli
		ACALL CZEKAJ
		
	DJNZ R1,INIT
		MOV P2,#0h ;zapalenie ostatniej diody
		
		MOV R4, 20h ;musi byc powtorzenie, bo inkrementuje w petli
		ACALL CZEKAJ
			
		SJMP start
	
	STOP:
		CLR TR0 ;ZATRZYMUJE TIMER
		JMP LICZ

	CZEKAJ: ; petla czekaj wykona sie tyle razy ile razy bylo przepelnienie rejestr R4/akumulator
		CPL TF0 ;zeruje flage przepelnienia
		MOV TH0,#76
		MOV TL0,#01
		SETB TR0 ; startujemy timer 0
		JNB TF0,$ ;Jezeli TF0 nie jest ustawione to nie ma przepelnie
	DJNZ R4,CZEKAJ
	RET
	
END
	