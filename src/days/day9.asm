extern alloc
extern parse_int
extern print
extern str_append
extern str_split
extern to_string

global day9_1
global day9_2

%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define positions_visited qword [rbp-24]
%define step_amount qword [rbp-32]
%define step_x qword [rbp-40]
%define step_y qword [rbp-48]
%define visited_count qword [rbp-56]

%define head_x qword [rbp-72]
%define head_y qword [rbp-64]
%define tail_x qword [rsp+8]
%define tail_y qword [rsp+16]

%define size_of_pos_list 24
%define pos_list_x(struct) qword [struct]
%define pos_list_y(struct) qword [struct+8]
%define pos_list_next(struct) qword [struct+16]

section .text

day9_1:
mov rcx, 96
call day9
ret

day9_2:
mov rcx, 224
call day9
ret

day9:
push rbp
mov rbp, rsp
sub rsp, rcx

mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx

lea rax, tail_x
lea rbx, head_y
    .zero_snake_loop:
mov qword [rax], 0
add rax, 8
cmp rax, rbx
jle .zero_snake_loop

mov rax, size_of_pos_list
call alloc
mov positions_visited, rax
mov visited_count, 1

    .line_loop:
sub num_lines, 1
jc .line_loop_end

mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
cmp rax, 3
jl .line_loop_inc
sub rax, 2
add rbx, 2
call parse_int
cmp rax, 0
jne .line_loop_inc
mov step_amount, rbx

mov rax, lines
mov rax, qword [rax+8]
mov al, byte [rax]
cmp al, 'U'
jne .not_u
mov step_x, 0
mov step_y, -1
jmp .move_head_loop
    .not_u:
cmp al, 'D'
jne .not_d
mov step_x, 0
mov step_y, 1
jmp .move_head_loop
    .not_d:
cmp al, 'L'
jne .not_l
mov step_x, -1
mov step_y, 0
jmp .move_head_loop
    .not_l:
cmp al, 'R'
jne .line_loop_inc
mov step_x, 1
mov step_y, 0

    .move_head_loop:
sub step_amount, 1
jc .line_loop_inc

mov rax, head_x
add rax, step_x
mov head_x, rax
mov rax, head_y
add rax, step_y
mov head_y, rax

lea rbx, head_x
lea rcx, tail_x
    .move_snake_loop:
sub rbx, 16
cmp rbx, rcx
jl .move_snake_loop_end

mov rax, qword [rbx+16]
sub rax, qword [rbx]
cmp rax, -2
je .move_tail
cmp rax, 2
je .move_tail
mov rax, qword [rbx+24]
sub rax, qword [rbx+8]
cmp rax, -2
je .move_tail
cmp rax, 2
jne .move_snake_loop

    .move_tail:
mov rax, qword [rbx+16]
cmp rax, qword [rbx]
je .tail_x_end
jl .tail_x_less
add qword [rbx], 1
jmp .tail_x_end
    .tail_x_less:
sub qword [rbx], 1
    .tail_x_end:

mov rax, qword [rbx+24]
cmp rax, qword [rbx+8]
je .move_snake_loop
jl .tail_y_less
add qword [rbx+8], 1
jmp .move_snake_loop
    .tail_y_less:
sub qword [rbx+8], 1
jmp .move_snake_loop

    .move_snake_loop_end:

mov rax, positions_visited
    .tail_existence_loop:
cmp rax, 0
je .tail_doesnt_exist
mov rbx, tail_x
cmp rbx, pos_list_x(rax)
jne .tail_existence_inc
mov rbx, tail_y
cmp rbx, pos_list_y(rax)
je .move_head_loop
    .tail_existence_inc:
mov rax, pos_list_next(rax)
jmp .tail_existence_loop

    .tail_doesnt_exist:
mov rax, size_of_pos_list
call alloc
mov rbx, tail_x
mov pos_list_x(rax), rbx
mov rbx, tail_y
mov pos_list_y(rax), rbx
mov rbx, positions_visited
mov pos_list_next(rax), rbx
mov positions_visited, rax
add visited_count, 1

jmp .move_head_loop

    .line_loop_inc:
add lines, 16
jmp .line_loop
    .line_loop_end:

mov rax, visited_count
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret
