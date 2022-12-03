extern _end
extern print
extern str_append
extern str_split
extern to_string

global day2_1
global day2_2

section .text

day2_1:
mov r10, 0
call day2
ret

day2_2:
mov r10, 1
call day2
ret

day2:
mov cl, 10
call str_split

xor rdi, rdi ; total

    .loop:
sub rax, 1
jc .loop_end
mov rcx, qword [rbx]
cmp rcx, 0
je .loop_inc
cmp rcx, 3
je .input_valid
    .input_invalid:
mov rax, 21
mov rbx, invalid_input_msg
call print
call _end
    .input_valid:
mov rcx, qword [rbx+8]
xor rdx, rdx
mov dl, byte [rcx]
sub rdx, 'A'
cmp rdx, 0
jl .input_invalid
cmp rdx, 2
jg .input_invalid
xor rsi, rsi
mov sil, byte [rcx+2]
sub rsi, 'X'
cmp rsi, 0
jl .input_invalid
cmp rsi, 2
jg .input_invalid
imul rdx, 3
add rdx, rsi
cmp r10, 0
jne .pt2
mov sil, byte [pt1_win_data+rdx]
jmp .pt_end
    .pt2:
mov sil, byte [pt2_win_data+rdx]
    .pt_end:
add rdi, rsi
    .loop_inc:
add rbx, 16
jmp .loop
    .loop_end:

mov rax, rdi
call to_string
mov rdx, 10
call str_append
call print

ret

section .data

invalid_input_msg:
db "Invalid input format", 10

pt1_win_data:
db 4 ; rock rock
db 8 ; rock paper
db 3 ; rock scissors
db 1 ; paper rock
db 5 ; paper paper
db 9 ; paper scissors
db 7 ; scissors rock
db 2 ; scissors paper
db 6 ; scissors scissors

pt2_win_data:
db 3 ; rock lose
db 4 ; rock draw
db 8 ; rock win
db 1 ; paper lose
db 5 ; paper draw
db 9 ; paper win
db 2 ; scissors lose
db 6 ; scissors draw
db 7 ; scissors win
