;Wartości predefiniowane:

STDIN equ 0
STDOUT equ 1
STDERR equ 2

SYS_READ equ 0
SYS_WRITE equ 1
SYS_EXIT equ 60




;MAKRA:
%macro PrintText 1 ;makro która za argument bierze sobie adres pierwszego bajtu w tekscie. Należy pamiętać aby teks kończył się na bajcie który ma warość '0'

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, %1 
	mov rcx, %1 ; wpisuje adres pierwszego bajta do rax
	call _PoliczdlugoscDB ; liczy ilosc bajtow w tekscie
	syscall
%endmacro

%macro Exit 1 ;makro słóżące do wyjścia z programu
	mov rdi, %1
	call _exit
%endmacro	

;%macro Dodawanie 2
;	
;%enmacro

%macro CyszczenieBuforanaAdresie 2;
	mov r11, %1   ;Adresu bufora
	mov r12, %2   ;Ilość bajtów
	call _wyzerujBufor


%endmacro	


%macro GetNumberToAdres 1 ; Pojawi się interfejs w który będzie można wpisać liczbę ( a tak na prawde dowolne co zdefiniowane w ASCI
	mov rsi, %1
	call _getNumber
%endmacro
	
%macro ConvertAsciToNumber 1; Funkcja potrzebna do przekształcenie ASCI do liczby czytanej przez rejestr
	call _PoliczdlugoscDB %1 ;liczy dlługość liczby i wynik jest zapisany w 
	
%endmacro




section .data
	tekst1 db 1,0,0,0,0,0,0,0 ;To sobie koniecznie zapamiętaj masz 8 bajtów i ta jedynka to jest najmladszy bajt czyli jak wstawisz jakąś liczbę to jest to liczna '00000001', moznes też użyć 'tekst1 dq 1'
	tekst2 db "RKS",10,0 ; jakieś ciągi znaków
	tekst3 db "Klub",10,0


section .bss
	name resb 64 ;reserwuje 16 bajtow (nie wiem o co mi tutaj chodziło, chyba tam można dać po prostu 16 zamiast 64)
	namelength resb 64 
	number1 resb 8
	number2 resb 8

section .text
	global _start

	
_start:


	GetNumberToAdres number1 ;P
	GetNumberToAdres number2
	
	PrintText number1
	PrintText number2


	
	Exit 0










;Funkcje:
_wyzerujBufor:
	
        add r11, r12

	_loop:
		mov [r11], 0
        	sub r11, 1
        	sub r12, 1
        	cmp r12, 1
       		je _loop
        	ret



_PoliczdlugoscDB: ; funkcja powiązana z makrem PrintText, służy do policzenia długości tekstu
	
	mov rdx, 0 ; ustawia licznik na 0
	_countingloop:  
		cmp byte [rcx], 0 ;sprawdza czy warotsc w adresie jest rowna 0
		je _jestrowne ; skok pomocniczy jakby okazalo się, że 1 bajt to 0
		inc rcx ; inkrementuje adres
		inc rdx ; inkrementuje rdx czyli liczy co potrzeba
		jmp _countingloop ; powrot do pętli
	_jestrowne:
		ret ; odwrót z funkcji

	

;Wywoływanie funkcji wypisujacerj tekst3 (trzeba policzyc bajty)	
_printtekst: ; najbardziej prymitywana wersja funkcji print text
	mov rax, 1
        mov rdi, 1
        mov rsi, tekst3
        mov rdx, 5
	syscall
	ret

_printprinttekst: ; to służy tolko aby pokazać, że można wywołać funkcje w funkcji
	call _printtekst
	ret

_getName: ;funkcja która pobiera wartości wpisane na konsoli do bajtów zaczynających się od adresu name
	mov rax, 0 ; sys_read
        mov rdi, 0 ; typ input
        mov rsi, name
        mov rdx, 16
	syscall
	ret
_getNumber: ;tworzy wywołanie systemowe, które zapisuje numer do wskazanego adresu (to jest funkcja, która służy do obsługi makra get Number
	mov rax, SYS_READ ; sys_read
        mov rdi, STDIN ; typ input
        mov rdx, 8
	syscall
	ret

_exit: ; wiadomo
        mov rax, 60
        syscall




; Funkcje do poćwiczenia sobie stosu:
;_powrot:
;	call _printtekst
;	call _exit	
;
;
;testfunction1:
;	mov rax, [tekst1] ;warotść z pod adresu teskt1 
;        mov rdi, [tekst1]
;        mov rsi, tekst2
;        PoliczDlugoscDlaSYSWRITE tekst2 ;TA FUNKCJA JUŻ NIE ISTNIEJE !!!
;        syscall ; wypisywanie "RKS" na ekranie
;	 pop rax
;        jmp rax ; powrót do gółownego porgramu ( teraz się wykona call _printtekst)
;








; MAKRA W ASM:
; 1. Makra z ilomaśtam argumentami
;%macro exit 0 ----> liczba '0' oznacza zero argumentow
;	mov rax, 60
;	mov rsi, 0
;	syscall
;%endmacro
;
;%macro printDigit 1
;	mov rax, %1
;	call _printRAXDigit
;%endmacro
;
;%macro printDigitSum 2
;	mov rax, %1
;	add rax, %2
;	call _printRAXDigit
;%endmacro
;
;	printDigit 3
;	printDigit 4
;	printDigitSum 3,2
;
;
;
; 2. Umieszczanie etykiet w makrach
;%macro freeze 0
;%%loop:
;	jmp %%loop
;%endmacro  -------> to musi być tak rozpisane bo inaczej za każdym razem jak wywołujesz makro to etykieta loop byłaby toworzona nna nowo i nadpisywałaby istniejące adresy
;
;DEFINIOWANIE WARTOŚCI W ASM:
;STDIN equ 0
;STDOUT egu 1
;STDERR equ 2
;
;SYS _READ equ 0
;SYS _WRITE equ 1
;SYS _EXIT equ 60
;
;
;
;3. DODAWANIE ZEWNĘTRZNYCH PLIKÓW W ASM
;
;%include "linux64.inc"
;
;section .data
;	text db "Hello, World!", 10,0
;section .text 
;	global _start
;_start:
;	print text	
;	exit
;
;
;
;
;4. ZASADA DZIAŁANIA STOSU WYWOŁAŃ:
;
;push [adres] ---> wpycha adres na stos (to jest też -> mov rbx, [adres] -> sub rsp, 8 -> mov [rsp], rbx )
;pop [rejsetr] ---> wywala ze stosu ( to jest też -> mov rbx, [adres] -> add rsp, 8 -> mov [rsp], rbx )
;
;
;
;5. Ważne wskaźniki
;rip -> następna instrukcja (raczej nie kożystaj z tego bo to straszny rozpierdol)
;rsp -> wskazuje na górę stosu 
;rbp -> jakieś gówno do związane ze stosem
;
;
;
;6. Warunkowe skoki
;Przykładowe flagi:
;je -> a = b
;jne -> a =/= b
;jg -> a>b
;
;Przykładowe zastosowanie:
;cmp rax, 23
;jg _doThis



