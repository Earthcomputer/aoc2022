extern exit
extern parse_int
extern print
extern str_append
extern str_split
extern to_string

global day4_1
global day4_2

section .text

day4_1:
push rbp
mov rbp, rsp
sub rsp, 40

mov rcx, 10
call str_split

xor r15, r15 ; count

mov qword [rbp-8], rax
mov qword [rbp-16], rbx
    .loop:
mov rax, qword [rbp-8]
sub rax, 1
jc .end
mov qword [rbp-8], rax
mov rax, qword [rbp-16]
mov rbx, qword [rax+8]
mov rax, qword [rax]
cmp rax, 0
je .inc
mov rcx, ','
call str_split
cmp rax, 2
jne .invalid
mov rax, qword [rbx+16]
mov qword [rbp-24], rax
mov rax, qword [rbx+24]
mov qword [rbp-32], rax
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
mov rcx, '-'
call str_split
cmp rax, 2
jne .invalid
mov r11, qword [rbx+16]
mov r12, qword [rbx+24]
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
call parse_int
cmp rax, 0
jne .invalid
mov r13, rbx
mov rax, r11
mov rbx, r12
call parse_int
cmp rax, 0
jne .invalid
mov r14, rbx
mov rax, qword [rbp-24]
mov rbx, qword [rbp-32]
mov rcx, '-'
call str_split
cmp rax, 2
jne .invalid
mov rax, qword [rbx+16]
mov qword [rbp-24], rax
mov rax, qword [rbx+24]
mov qword [rbp-32], rax
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
call parse_int
cmp rax, 0
jne .invalid
mov r11, rbx
mov rax, qword [rbp-24]
mov rbx, qword [rbp-32]
call parse_int
cmp rax, 0
jne .invalid

; r13-r14,r11-rbx
; if r13 < r11
;  r14 >= rbx
; elif r13 > r11
;  r14 <= rbx
; else true
cmp r13, r11
jge .cond1
cmp r14, rbx
jl .inc
add r15, 1
jmp .inc
    .cond1:
je .cond2
cmp r14, rbx
jg .inc
add r15, 1
jmp .inc
    .cond2:
add r15, 1
    .inc:
mov rax, qword [rbp-16]
add rax, 16
mov qword [rbp-16], rax
jmp .loop

    .invalid:
mov rax, 14
mov rbx, invalid_input_msg
call print
call exit

    .end:
mov rax, r15
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret

day4_2:
push rbp
mov rbp, rsp
sub rsp, 40

mov rcx, 10
call str_split

xor r15, r15 ; count

mov qword [rbp-8], rax
mov qword [rbp-16], rbx
    .loop:
mov rax, qword [rbp-8]
sub rax, 1
jc .end
mov qword [rbp-8], rax
mov rax, qword [rbp-16]
mov rbx, qword [rax+8]
mov rax, qword [rax]
cmp rax, 0
je .inc
mov rcx, ','
call str_split
cmp rax, 2
jne .invalid
mov rax, qword [rbx+16]
mov qword [rbp-24], rax
mov rax, qword [rbx+24]
mov qword [rbp-32], rax
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
mov rcx, '-'
call str_split
cmp rax, 2
jne .invalid
mov r11, qword [rbx+16]
mov r12, qword [rbx+24]
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
call parse_int
cmp rax, 0
jne .invalid
mov r13, rbx
mov rax, r11
mov rbx, r12
call parse_int
cmp rax, 0
jne .invalid
mov r14, rbx
mov rax, qword [rbp-24]
mov rbx, qword [rbp-32]
mov rcx, '-'
call str_split
cmp rax, 2
jne .invalid
mov rax, qword [rbx+16]
mov qword [rbp-24], rax
mov rax, qword [rbx+24]
mov qword [rbp-32], rax
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
call parse_int
cmp rax, 0
jne .invalid
mov r11, rbx
mov rax, qword [rbp-24]
mov rbx, qword [rbp-32]
call parse_int
cmp rax, 0
jne .invalid

; r13-r14,r11-rbx
; r14 >= r11 && r13 <= rbx
cmp r14, r11
jl .inc
cmp r13, rbx
jg .inc
add r15, 1
    .inc:
mov rax, qword [rbp-16]
add rax, 16
mov qword [rbp-16], rax
jmp .loop

    .invalid:
mov rax, 14
mov rbx, invalid_input_msg
call print
call exit

    .end:
mov rax, r15
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret

section .data

invalid_input_msg:
db "Invalid input", 10
