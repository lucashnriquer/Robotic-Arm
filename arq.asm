.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\macros\macros.asm
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib


.data

;____________Prints para facilitar o uso do programa:

print1 db 0ah, "Digite o X inicial:", 0h
print2 db "Digite o Y inicial:", 0h
print3 db "Digite o X final:", 0h
print4 db "Digite o Y final:", 0h
print5 db "Quantidade de furos desejada:", 0h
print6 db 0ah, "Sequencia de furos realizados:", 0ah, 0ah
print7 db 0ah, "Deseja inserir outras coordenadas?: (s) ou (n)", 0ah
printpar1 db "("
printv db ","
printpar2 db ")", 0ah

;0ah = "\n"
;0h = " "


;____________Declaracao das variaveis:

strinput db 10 dup(?)
strresp db 5 dup(?)
strx db 10 dup(?)
stry db 10 dup(?)

write_count dd 0
tamx dd 0
tamy dd 0
countfor dd 0
intpontos dd 0

x1 REAL8 0.0
y1 REAL8 0.0
x2 REAL8 0.0
y2 REAL8 0.0
distx REAL8 0.0
disty REAL8 0.0
qpontos REAL8 0.0
um REAL8 1.0


.code
start:

bigbang:

    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

;__________________________________________________________________________________ Le o x1

    push STD_OUTPUT_HANDLE                                                              ;os unicos parametros que precisa mudar em cada print sao: a variavel string e o tamanho dela
    call GetStdHandle                                                                   ;no caso de printar uma variavel ja declarada (como o print1), e melhor usar o sizeof no parametro do tamanho
    invoke WriteConsole, eax, addr print1, sizeof print1, addr write_count, NULL        ;no caso de printar uma string lida atraves do ReadConsole, precisa pegar o tamanho dela com o StrLen

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr x1
    

;__________________________________________________________________________________ Le o y1

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print2, sizeof print2, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr y1
    
;__________________________________________________________________________________ Le o x2

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print3, sizeof print3, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr x2

;__________________________________________________________________________________ Le o y2

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print4, sizeof print4, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr y2

;__________________________________________________________________________________ Le a quantidade de furos

    
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print5, sizeof print5, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr qpontos


;__________________________________________________________________________________ Equacao principal

    finit           ;inicia a pilha do FPU
    fld um          ;push da variavel "um"
    fld qpontos     ;push da variavel "qpontos"
    fsub st,st(1)   ;subtrai os dois valores da pilha e da o push do resultado
    fst qpontos     ;pop do resultado e armazena na variavel "qpontos"

    finit           ;para cada operacao e necessario iniciar de novo a pilha
    fld x1
    fld x2
    fsub st, st(1)
    fdiv qpontos
    fst distx

    finit
    fld y1
    fld y2
    fsub st, st(1)
    fdiv qpontos
    fst disty

;__________________________________________________________________________________ Print o primeiro ponto

    invoke FloatToStr, x1, addr strx
    invoke FloatToStr, y1, addr stry    ;necessario pois o WriteConsole so printa strings

    invoke StrLen, addr strx
    mov tamx, eax
    invoke StrLen, addr stry
    mov tamy, eax

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print6, sizeof print6, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar1, sizeof printpar1, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr strx, tamx, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printv, sizeof printv, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr stry, tamy, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar2, sizeof printpar2, addr write_count, NULL

    invoke StrToFloat, addr strx, addr x1
    invoke StrToFloat, addr stry, addr y1

;__________________________________________________________________________________ Transformar o valor de qpontos em int para comparar no laço de repeticao

    invoke FloatToStr, qpontos, addr strinput

    mov esi, offset strinput        ;Tirar o enter
    next:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl finish
        cmp al, 58
        jl next
    finish:
        dec esi
        xor al, al
        mov [esi], al

    invoke atodw, addr strinput     ;string to int
    mov intpontos, eax

;__________________________________________________________________________________ Início do laço de repetição

piaodacasapropria:

    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

    finit
    fld distx
    fld x1
    faddp st(1),st
    fst x1

    finit
    fld disty
    fld y1
    faddp st(1), st
    fst y1


;__________________________________________________________________________________ Print dos pontos restantes

    invoke FloatToStr, x1, addr strx
    invoke FloatToStr, y1, addr stry

    invoke StrLen, addr strx
    mov tamx, eax
    invoke StrLen, addr stry
    mov tamy, eax
    
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar1, sizeof printpar1, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr strx, tamx, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printv, sizeof printv, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr stry, tamy, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar2, sizeof printpar2, addr write_count, NULL

    invoke StrToFloat, addr strx, addr x1
    invoke StrToFloat, addr stry, addr y1

    inc countfor           
    mov ebx, countfor
    cmp ebx, intpontos      ;comparacao do contador do laco de repeticao
    jl piaodacasapropria

;__________________________________________________________________________________ Pergunta se deseja iniciar o programa de novo

    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

    mov countfor, eax
    mov intpontos, ebx

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print7, sizeof print7, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strresp, sizeof strresp, addr write_count, NULL

    cmp strresp, 's'
    je bigbang


    invoke ExitProcess, 0
    
end start
.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\macros\macros.asm
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib


.data

;____________Prints para facilitar o uso do programa:

print1 db 0ah, "Digite o X inicial:", 0h
print2 db "Digite o Y inicial:", 0h
print3 db "Digite o X final:", 0h
print4 db "Digite o Y final:", 0h
print5 db "Quantidade de furos desejada:", 0h
print6 db 0ah, "Sequencia de furos realizados:", 0ah, 0ah
print7 db 0ah, "Deseja inserir outras coordenadas?: (s) ou (n)", 0ah
printpar1 db "("
printv db ","
printpar2 db ")", 0ah

;0ah = "\n"
;0h = " "


;____________Declaracao das variaveis:

strinput db 10 dup(?)
strresp db 5 dup(?)
strx db 10 dup(?)
stry db 10 dup(?)

write_count dd 0
tamx dd 0
tamy dd 0
countfor dd 0
intpontos dd 0

x1 REAL8 0.0
y1 REAL8 0.0
x2 REAL8 0.0
y2 REAL8 0.0
distx REAL8 0.0
disty REAL8 0.0
qpontos REAL8 0.0
um REAL8 1.0


.code
start:

bigbang:

    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

;__________________________________________________________________________________ Le o x1

    push STD_OUTPUT_HANDLE                                                              ;os unicos parametros que precisa mudar em cada print sao: a variavel string e o tamanho dela
    call GetStdHandle                                                                   ;no caso de printar uma variavel ja declarada (como o print1), e melhor usar o sizeof no parametro do tamanho
    invoke WriteConsole, eax, addr print1, sizeof print1, addr write_count, NULL        ;no caso de printar uma string lida atraves do ReadConsole, precisa pegar o tamanho dela com o StrLen

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr x1
    

;__________________________________________________________________________________ Le o y1

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print2, sizeof print2, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr y1
    
;__________________________________________________________________________________ Le o x2

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print3, sizeof print3, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr x2

;__________________________________________________________________________________ Le o y2

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print4, sizeof print4, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr y2

;__________________________________________________________________________________ Le a quantidade de furos

    
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print5, sizeof print5, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strinput, sizeof strinput, addr write_count, NULL
    invoke StrToFloat, addr strinput, addr qpontos


;__________________________________________________________________________________ Equacao principal

    finit           ;inicia a pilha do FPU
    fld um          ;push da variavel "um"
    fld qpontos     ;push da variavel "qpontos"
    fsub st,st(1)   ;subtrai os dois valores da pilha e da o push do resultado
    fst qpontos     ;pop do resultado e armazena na variavel "qpontos"

    finit           ;para cada operacao e necessario iniciar de novo a pilha
    fld x1
    fld x2
    fsub st, st(1)
    fdiv qpontos
    fst distx

    finit
    fld y1
    fld y2
    fsub st, st(1)
    fdiv qpontos
    fst disty

;__________________________________________________________________________________ Print o primeiro ponto

    invoke FloatToStr, x1, addr strx
    invoke FloatToStr, y1, addr stry    ;necessario pois o WriteConsole so printa strings

    invoke StrLen, addr strx
    mov tamx, eax
    invoke StrLen, addr stry
    mov tamy, eax

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print6, sizeof print6, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar1, sizeof printpar1, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr strx, tamx, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printv, sizeof printv, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr stry, tamy, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar2, sizeof printpar2, addr write_count, NULL

    invoke StrToFloat, addr strx, addr x1
    invoke StrToFloat, addr stry, addr y1

;__________________________________________________________________________________ Transformar o valor de qpontos em int para comparar no laço de repeticao

    invoke FloatToStr, qpontos, addr strinput

    mov esi, offset strinput        ;Tirar o enter
    next:
        mov al, [esi]
        inc esi
        cmp al, 48
        jl finish
        cmp al, 58
        jl next
    finish:
        dec esi
        xor al, al
        mov [esi], al

    invoke atodw, addr strinput     ;string to int
    mov intpontos, eax

;__________________________________________________________________________________ Início do laço de repetição

piaodacasapropria:

    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

    finit
    fld distx
    fld x1
    faddp st(1),st
    fst x1

    finit
    fld disty
    fld y1
    faddp st(1), st
    fst y1


;__________________________________________________________________________________ Print dos pontos restantes

    invoke FloatToStr, x1, addr strx
    invoke FloatToStr, y1, addr stry

    invoke StrLen, addr strx
    mov tamx, eax
    invoke StrLen, addr stry
    mov tamy, eax
    
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar1, sizeof printpar1, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr strx, tamx, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printv, sizeof printv, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr stry, tamy, addr write_count, NULL

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr printpar2, sizeof printpar2, addr write_count, NULL

    invoke StrToFloat, addr strx, addr x1
    invoke StrToFloat, addr stry, addr y1

    inc countfor           
    mov ebx, countfor
    cmp ebx, intpontos      ;comparacao do contador do laco de repeticao
    jl piaodacasapropria

;__________________________________________________________________________________ Pergunta se deseja iniciar o programa de novo

    xor eax,eax
    xor ebx,ebx
    xor ecx,ecx
    xor edx,edx

    mov countfor, eax
    mov intpontos, ebx

    push STD_OUTPUT_HANDLE
    call GetStdHandle
    invoke WriteConsole, eax, addr print7, sizeof print7, addr write_count, NULL

    push STD_INPUT_HANDLE
    call GetStdHandle
    invoke ReadConsole, eax, addr strresp, sizeof strresp, addr write_count, NULL

    cmp strresp, 's'
    je bigbang


    invoke ExitProcess, 0
    
end start
