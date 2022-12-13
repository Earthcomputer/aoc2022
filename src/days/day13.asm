extern alloc
extern exit
extern parse_int
extern print
extern realloc
extern str_append
extern str_split
extern to_string

global day13_1
global day13_2

%define size_of_node 16
%define node_type(struct) qword [struct]
%define node_value(struct) qword [struct+8]
%define node_size(struct) qword [struct+8]
%define node_element(struct, i) qword [struct+16+8*i]

%define node_type_int 0
%define node_type_list 1

section .text

day13_1:
%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define left qword [rbp-24]
%define index qword [rbp-32]
%define total qword [rbp-40]
push rbp
mov rbp, rsp
sub rsp, 48

mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx

mov index, 0
mov total, 0

    .loop:
sub num_lines, 1
jc .loop_end
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
cmp rax, 0
je .loop_inc
add index, 1
call parse_line
cmp rax, 0
jne .parsing_failure
cmp rcx, 0
jne .parsing_failure
mov left, rdx

add lines, 16
sub num_lines, 1
jc .loop_end

mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
call parse_line
cmp rax, 0
jne .parsing_failure
cmp rcx, 0
jne .parsing_failure

mov rax, left
mov rbx, rdx
call compare_nodes
xor rbx, rbx
cmp rax, 0
cmove rbx, index
add total, rbx

    .loop_inc:
add lines, 16
jmp .loop

    .parsing_failure:
mov rax, 16
mov rbx, parsing_failure_msg
call print
call exit

    .loop_end:

mov rax, total
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret
%undef total
%undef index
%undef left
%undef lines
%undef num_lines

day13_2:
%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define digit_node qword [rbp-32]
%define inner_list_node qword [rbp-56]
%define separator_node qword [rbp-80]
%define line_index qword [rbp-88]
%define two_index qword [rbp-96]
%define six_index qword [rbp-104]
push rbp
mov rbp, rsp
sub rsp, 112

mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx

lea rax, separator_node
mov node_type(rax), node_type_list
mov node_size(rax), 1
lea rbx, inner_list_node
mov node_element(rax, 0), rbx
mov node_type(rbx), node_type_list
mov node_size(rbx), 1
lea rax, digit_node
mov node_element(rbx, 0), rax
mov node_type(rax), node_type_int
mov node_value(rax), 2

mov line_index, 0
mov two_index, 1
    .two_loop:
mov rbx, line_index
cmp rbx, num_lines
jge .two_loop_end
shl rbx, 4
mov rcx, lines
mov rax, qword [rcx+rbx]
mov rbx, qword [rcx+8+rbx]
cmp rax, 0
je .two_loop_inc
call parse_line
cmp rax, 0
jne .parsing_failure
cmp rcx, 0
jne .parsing_failure
mov rbx, rdx
lea rax, separator_node
call compare_nodes
add two_index, rax

    .two_loop_inc:
add line_index, 1
jmp .two_loop
    .two_loop_end:

mov line_index, 0
mov six_index, 2
lea rax, digit_node
mov node_value(rax), 6
    .six_loop:
mov rbx, line_index
cmp rbx, num_lines
jge .six_loop_end
shl rbx, 4
mov rcx, lines
mov rax, qword [rcx+rbx]
mov rbx, qword [rcx+8+rbx]
cmp rax, 0
je .six_loop_inc
call parse_line
cmp rax, 0
jne .parsing_failure
cmp rcx, 0
jne .parsing_failure
mov rbx, rdx
lea rax, separator_node
call compare_nodes
add six_index, rax

    .six_loop_inc:
add line_index, 1
jmp .six_loop

    .parsing_failure:
mov rax, 16
mov rbx, parsing_failure_msg
call print
call exit

    .six_loop_end:

mov rax, two_index
mul six_index
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret
%undef six_index
%undef two_index
%undef line_index
%undef separator_node
%undef inner_list_node
%undef digit_node
%undef lines
%undef num_lines

; inputs
;  rax: length of line
;  rbx: line
; outputs
;  rax: length of remainder
;  rbx: remainder
;  rcx: 0 if successful, 1 otherwise
;  rdx: pointer to result
parse_line:
%define line_length qword [rbp-8]
%define line qword [rbp-16]
%define value qword [rbp-24]
%define capacity qword [rbp-24]
%define node qword [rbp-32]
push rbp
mov rbp, rsp
sub rsp, 40
mov line_length, rax
mov line, rbx
cmp rax, 0
je .fail

cmp byte [rbx], '['
je .parse_list

mov rcx, rax
mov rdx, rbx
    .find_int_end:
cmp rcx, 0
je .find_int_end_end
mov sil, byte [rdx]
cmp sil, '-'
je .find_int_end_inc
cmp sil, '+'
je .find_int_end_inc
cmp sil, '0'
jl .find_int_end_end
cmp sil, '9'
jg .find_int_end_end
    .find_int_end_inc:
sub rcx, 1
add rdx, 1
jmp .find_int_end
    .find_int_end_end:
mov line_length, rcx
mov line, rdx
mov rax, rdx
sub rax, rbx
call parse_int
cmp rax, 0
jne .fail
mov value, rbx
mov rax, size_of_node
call alloc
mov node_type(rax), node_type_int
mov rbx, value
mov node_value(rax), rbx
mov rdx, rax
xor rcx, rcx
mov rbx, line
mov rax, line_length
jmp .end

    .parse_list:
sub line_length, 1
add line, 1
cmp line_length, 0
je .fail
mov rax, size_of_node
call alloc
mov node, rax
mov capacity, size_of_node
mov node_type(rax), node_type_list
mov node_size(rax), 0
mov rax, line
cmp byte [rax], ']'
je .list_end
    .list_loop:
mov rax, node
mov rbx, capacity
lea rcx, [rbx+8]
call realloc
mov node, rax
mov capacity, rbx
add node_size(rax), 1

mov rax, line_length
mov rbx, line
call parse_line
cmp rcx, 0
jne .fail
mov line_length, rax
mov line, rbx
mov rax, node
mov rbx, capacity
mov qword [rax+rbx-8], rdx

cmp line_length, 0
je .fail
mov rax, line
mov al, byte [rax]
cmp al, ']'
je .list_end
cmp al, ','
jne .fail
sub line_length, 1
add line, 1
jmp .list_loop

    .list_end:
sub line_length, 1
add line, 1
mov rax, line_length
mov rbx, line
xor rcx, rcx
mov rdx, node
jmp .end

    .fail:
mov rcx, 1
    .end:
mov rsp, rbp
pop rbp
ret
%undef node
%undef capacity
%undef value
%undef line
%undef line_length

; inputs
;  rax: left node
;  rbx: right node
; outputs
;  rax: 0 if left <= right, 1 if left > right
compare_nodes:
push rbp
mov rbp, rsp
sub rsp, 32
cmp node_type(rax), node_type_int
jne .left_list
cmp node_type(rbx), node_type_int
jne .left_int_right_list

xor rdx, rdx
mov rsi, 1
mov rcx, node_value(rbx)
cmp node_value(rax), rcx
cmovg rdx, rsi
mov rax, rdx
jmp .end

.left_int_right_list:
lea rcx, [rbp-24]
mov node_type(rcx), node_type_list
mov node_size(rcx), 1
mov node_element(rcx, 0), rax
mov rax, rcx
call compare_nodes
jmp .end

    .left_list:
cmp node_type(rbx), node_type_int
jne .left_list_right_list

lea rcx, [rbp-24]
mov node_type(rcx), node_type_list
mov node_size(rcx), 1
mov node_element(rcx, 0), rbx
mov rbx, rcx
call compare_nodes
jmp .end

    .left_list_right_list:
%define left qword [rbp-8]
%define right qword [rbp-16]
%define index qword [rbp-24]
mov left, rax
mov right, rbx
mov index, 0

    .list_compare_loop:
mov rax, left
mov rax, node_size(rax)
cmp index, rax
jl .below_left_size
xor rax, rax
jmp .end
    .below_left_size:
mov rax, right
mov rax, node_size(rax)
cmp index, rax
jl .below_right_size
mov rax, 1
jmp .end
    .below_right_size:

mov rcx, index
mov rax, left
mov rax, node_element(rax, rcx)
mov rbx, right
mov rbx, node_element(rbx, rcx)
call compare_nodes
cmp rax, 0
jne .end

mov rcx, index
mov rax, right
mov rax, node_element(rax, rcx)
mov rbx, left
mov rbx, node_element(rbx, rcx)
call compare_nodes
cmp rax, 0
je .list_compare_loop_inc
xor rax, rax
jmp .end
    .list_compare_loop_inc:
add index, 1
jmp .list_compare_loop

%undef index
%undef right
%undef left

    .end:
mov rsp, rbp
pop rbp
ret

section .data

parsing_failure_msg:
db "Parsing failure", 10
