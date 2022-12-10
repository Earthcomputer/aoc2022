extern parse_int
extern print
extern str_append
extern str_equal
extern str_split
extern str_starts_with
extern to_string_signed

global day10_1
global day10_2

%define num_lines r8
%define lines r9
%define time r10
%define x_reg r11
%define result r12
%define examine_func r13
%define print_result r14

section .text

day10_1:
mov examine_func, examine_pt1
mov print_result, 1
call day10
ret

day10_2:
mov examine_func, examine_pt2
xor print_result, print_result
call day10
ret

day10:
mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx

xor time, time
mov x_reg, 1
xor result, result

    .loop:
sub num_lines, 1
jc .loop_end
mov rax, qword [lines]
mov rbx, qword [lines+8]
mov rcx, 4
mov rdx, noop
call str_equal
cmp rax, 0
je .not_noop
add time, 1
call examine_func
jmp .loop_inc
    .not_noop:
mov rax, qword [lines]
mov rcx, 5
mov rdx, addx
call str_starts_with
cmp rax, 0
je .loop_inc
mov rax, qword [lines]
sub rax, 5
add rbx, 5
call parse_int
cmp rax, 0
jne .loop_inc
add time, 1
call examine_func
add time, 1
call examine_func
add x_reg, rbx
    .loop_inc:
add lines, 16
jmp .loop
    .loop_end:

cmp print_result, 0
je .end
mov rax, result
call to_string_signed
mov rdx, 10
call str_append
call print
    .end:
ret

examine_pt1:
mov rax, time
mov rcx, 20
xor rdx, rdx
div rcx
cmp rdx, 0
jne .end
mov rax, time
mov rcx, 40
xor rdx, rdx
div rcx
cmp rdx, 0
je .end
mov rax, time
mul x_reg
add result, rax
    .end:
ret

examine_pt2:
push rbp
mov rbp, rsp
sub rsp, 72
mov qword [rbp-8], rbx
mov qword [rbp-16], num_lines
mov qword [rbp-24], lines
mov qword [rbp-32], time
mov qword [rbp-40], x_reg
mov qword [rbp-48], result
mov qword [rbp-56], examine_func
mov rax, time
mov rbx, 40
xor rdx, rdx
div rbx
sub rdx, x_reg
cmp rdx, 0
je .hash
cmp rdx, 1
je .hash
cmp rdx, 2
je .hash
mov byte [rbp-64], '.'
jmp .print
    .hash:
mov byte [rbp-64], '#'
    .print:
mov rax, 1
lea rbx, [rbp-64]
call print
mov rax, qword [rbp-32] ; time
mov rbx, 40
xor rdx, rdx
div rbx
cmp rdx, 0
jne .no_newline
mov byte [rbp-64], 10
mov rax, 1
lea rbx, [rbp-64]
call print
    .no_newline:
mov rbx, qword [rbp-8]
mov num_lines, qword [rbp-16]
mov lines, qword [rbp-24]
mov time, qword [rbp-32]
mov x_reg, qword [rbp-40]
mov result, qword [rbp-48]
mov examine_func, qword [rbp-56]
mov rsp, rbp
pop rbp
ret

section .data

noop:
db "noop"

addx:
db "addx "
