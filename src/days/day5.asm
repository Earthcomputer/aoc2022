extern alloc
extern exit
extern parse_int
extern print
extern realloc
extern str_split

global day5_1
global day5_2

%define input_len qword [rbp-8]
%define input_str qword [rbp-16]
%define stack_len(i) dword [rbp-56+4*i]
%define stack(i) qword [rbp-136+8*i]
%define stack_cap(i) dword [rbp-176+4*i]
%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define num_stacks qword [rbp-184]
%define stack_index qword [rbp-192]
%define line qword [rbp-200]
%define char byte [rbp-201]
%define amount qword [rbp-208]
%define from_stack qword [rbp-216]
%define to_stack qword [rbp-224]
%define result(i) byte [rbp-176+i]
%define result_ptr [rbp-176]
%define move_func [rbp-232]

section .text

day5_1:
mov rcx, move_stack_pt1
call day5
ret

day5_2:
mov rcx, move_stack_pt2
call day5
ret

day5:
push rbp
mov rbp, rsp
sub rsp, 240
mov input_len, rax
mov input_str, rbx
mov move_func, rcx

mov qword [rbp-24], 0
mov qword [rbp-32], 0
mov qword [rbp-40], 0
mov qword [rbp-48], 0
mov qword [rbp-56], 0

mov num_stacks, 10
    .alloc_loop:
mov r11, num_stacks
sub r11, 1
mov num_stacks, r11
jc .alloc_loop_end
mov rax, 16
call alloc
mov r11, num_stacks
mov stack(r11), rax
jmp .alloc_loop
    .alloc_loop_end:
mov rax, 0h1000000010 ; 16, 16
mov qword [rbp-144], rax
mov qword [rbp-152], rax
mov qword [rbp-160], rax
mov qword [rbp-168], rax
mov qword [rbp-176], rax

mov rax, input_len
mov rbx, input_str
mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx

mov num_stacks, 0

    .stack_parse_loop:
mov rax, num_lines
sub rax, 1
mov num_lines, rax
jc .stack_parse_end
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
cmp rax, 2
jl .stack_parse_end
cmp byte [rbx], ' '
jne .stack_parse_row_len
cmp byte [rbx+1], ' '
jne .stack_parse_inc
    .stack_parse_row_len:
xor rdx, rdx
add rax, 1
mov rcx, 4
div rcx
cmp rax, 10
jle .stack_count_valid
mov rax, 43
mov rbx, above_stack_limit_msg
call print
call exit
    .stack_count_valid:
mov stack_index, rax
mov line, rbx
cmp rax, num_stacks
jle .stack_parse_row
mov num_stacks, rax
    .stack_parse_row:
mov rax, stack_index
sub rax, 1
mov stack_index, rax
jc .stack_parse_inc
mov rbx, line
mov dil, byte [rbx+1+4*rax]
cmp dil, ' '
je .stack_parse_row
mov char, dil
mov ebx, stack_cap(rax)
mov ecx, stack_len(rax)
add ecx, 1
mov stack_len(rax), ecx
cmp ebx, ecx
jge .parse_no_realloc
mov stack_cap(rax), ecx
mov rax, stack(rax)
call realloc
mov rbx, stack_index
mov stack(rbx), rax
    .parse_no_realloc:
mov rax, stack_index
mov rbx, stack(rax)
xor rcx, rcx
mov ecx, stack_len(rax)
mov dil, char
mov byte [rbx+rcx-1], dil
jmp .stack_parse_row
    .stack_parse_inc:
mov rax, lines
add rax, 16
mov lines, rax
jmp .stack_parse_loop
    .stack_parse_end:

mov rax, num_stacks
    .stacks_reverse_loop:
sub rax, 1
jc .stacks_reverse_end
xor rbx, rbx
mov ebx, stack_len(rax)
mov rcx, stack(rax)
shr rbx, 1
    .stack_reverse_loop:
sub rbx, 1
jc .stacks_reverse_loop
xor rdx, rdx
mov edx, stack_len(rax)
sub rdx, 1
sub rdx, rbx
mov sil, byte [rcx+rbx]
mov dil, byte [rcx+rdx]
mov byte [rcx+rbx], dil
mov byte [rcx+rdx], sil
jmp .stack_reverse_loop
    .stacks_reverse_end:

add lines, 16

    .insn_loop:
; parse the instruction
mov rax, num_lines
sub rax, 1
mov num_lines, rax
jc .insn_loop_end
mov rbx, lines
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
mov rcx, ' '
call str_split
cmp rax, 6
jne .insn_loop_inc
mov line, rbx
mov rax, qword [rbx+16]
mov rbx, qword [rbx+24]
call parse_int
cmp rax, 0
jne .invalid_input
mov amount, rbx
mov rbx, line
mov rax, qword [rbx+48]
mov rbx, qword [rbx+56]
call parse_int
cmp rax, 0
jne .invalid_input
sub rbx, 1
cmp rbx, 0
jl .invalid_input
cmp rbx, num_stacks
jge .invalid_input
mov from_stack, rbx
mov rbx, line
mov rax, qword [rbx+80]
mov rbx, qword [rbx+88]
call parse_int
cmp rax, 0
jne .invalid_input
sub rbx, 1
cmp rbx, 0
jl .invalid_input
cmp rbx, num_stacks
jge .invalid_input
mov to_stack, rbx

; allocate enough space in the target stack
mov rax, to_stack
xor rbx, rbx
mov ebx, stack_cap(rax)
xor rcx, rcx
mov ecx, stack_len(rax)
mov rax, stack(rax)
add rcx, amount
call realloc
mov rdx, to_stack
mov stack(rdx), rax
mov stack_cap(rdx), ebx
mov r10, rax
xor rax, rax
mov eax, stack_len(rdx)
mov r11, rax

; check for stack underflow
mov rsi, from_stack
mov rbx, stack(rsi)
mov eax, stack_len(rsi)
mov r12, rax
mov rax, to_stack
mov rcx, amount
cmp rcx, r12
jle .move
mov rax, 16
mov rbx, stack_underflow_msg
call print
call exit

; move the stuff from the old stack to the new stack
    .move:
call move_func
mov rax, r12
mov stack_len(rsi), eax
mov rax, r11
mov stack_len(rdx), eax

    .insn_loop_inc:
mov rax, lines
add rax, 16
mov lines, rax
jmp .insn_loop

    .invalid_input:
mov rax, 21
mov rbx, invalid_input_msg
call print
call exit

    .insn_loop_end:
mov rax, num_stacks
mov result(rax), 10
    .output_loop:
sub rax, 1
jc .output_loop_end
xor rbx, rbx
mov ebx, stack_len(rax)
cmp rbx, 0
jg .output_non_empty_stack
mov rax, 27
mov rbx, stack_empty_msg
call print
call exit
    .output_non_empty_stack:
mov rcx, stack(rax)
mov dl, byte [rcx+rbx-1]
mov result(rax), dl
jmp .output_loop
    .output_loop_end:

mov rax, num_stacks
add rax, 1
lea rbx, result_ptr
call print

mov rsp, rbp
pop rbp
ret

; inputs
;  rcx: number of letters to move
;  r12: length of source stack
;  rbx: source stack
;  r11: length of dest stack
;  r10: dest stack
; side effects
;  clobbers al, r14, r15
move_stack_pt1:
    .move_loop:
sub rcx, 1
jc .move_loop_end
sub r12, 1
mov al, byte [rbx+r12]
mov byte [r10+r11], al
add r11, 1
jmp .move_loop
    .move_loop_end:
ret

move_stack_pt2:
mov r15, rcx
sub r12, rcx
    .move_loop:
sub rcx, 1
jc .move_loop_end
lea r14, [rbx+r12]
mov al, byte [r14+rcx]
lea r14, [r10+r11]
mov byte [r14+rcx], al
jmp .move_loop
    .move_loop_end:
add r11, r15
ret

section .data

invalid_input_msg:
db "Invalid input format", 10

above_stack_limit_msg:
db "Input above stack limit, only 10 supported", 10

stack_underflow_msg:
db "Stack underflow", 10

stack_empty_msg:
db "Empty stack, cannot output", 10
