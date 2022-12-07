extern alloc
extern exit
extern parse_int
extern print
extern str_append
extern str_equal
extern str_split
extern str_starts_with
extern to_string

global day7_1
global day7_2

%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define parse_info qword [rbp-64]
%define root_node qword [rbp-112]
%define part_specific_func qword [rbp-120]

%define size_of_parse_info 16
%define parse_info_current_dir(struct) qword [struct]
%define parse_info_root_dir(struct) qword [struct+8]

%define size_of_node 48
%define file_type(struct) byte [struct]
%define file_parent(struct) qword [struct+8]
%define file_name_len(struct) qword [struct+16]
%define file_name(struct) qword [struct+24]
%define file_size(struct) qword [struct+32]
%define file_children(struct) qword [struct+32]
%define file_next(struct) qword [struct+40]

%define file_type_dir 0
%define file_type_normal 1

section .text

day7_1:
mov rcx, solve_pt1
call day7
ret

%define total qword [rbp-16]
%define file qword [rbp-8]
solve_pt1:
push rbp
mov rbp, rsp
sub rsp, 24

mov total, 0
cmp file_type(rax), file_type_dir
jne .dir_end
mov file, rax
call disk_usage
cmp rax, 100000
jg .disk_usage_too_large
mov total, rax
    .disk_usage_too_large:
mov rax, file

mov rax, file_children(rax)
mov file, rax
    .dir_loop:
cmp file, 0
je .dir_end
mov rax, file
call solve_pt1
add total, rax
mov rax, file
mov rax, file_next(rax)
mov file, rax
jmp .dir_loop
    .dir_end:
mov rax, total

mov rsp, rbp
pop rbp
ret

day7_2:
mov rcx, solve_pt2
call day7
ret

solve_pt2:
mov rcx, rax
call disk_usage
cmp rax, 70000000
jle .pt2_possible
mov rax, 61
mov rbx, root_too_big_msg
call print
call exit

    .pt2_possible:
mov rbx, 70000000
sub rbx, rax
cmp rbx, 30000000
jl .pt2_needs_more_space
mov rax, 21
mov rbx, already_enough_space_msg
call print
call exit
    .pt2_needs_more_space:
mov rax, 30000000
sub rax, rbx
mov rbx, rcx
call solve_pt2_recursive
ret

%define min_size qword [rbp-24]
%define total qword [rbp-16]
%define file qword [rbp-8]
; inputs
;  rax: min file size
;  rbx: the root file
; outputs
;  rax: smallest size >= input size within the root, or 0 if no such directory
solve_pt2_recursive:
push rbp
mov rbp, rsp
sub rsp, 32

mov min_size, rax
mov total, 0
cmp file_type(rbx), file_type_dir
jne .dir_end
mov file, rbx
mov rax, rbx
call disk_usage
cmp rax, min_size
jl .dir_end
mov total, rax
mov rax, file

mov rax, file_children(rax)
mov file, rax
    .dir_loop:
cmp file, 0
je .dir_end
mov rax, min_size
mov rbx, file
call solve_pt2_recursive
cmp rax, min_size
jl .dir_inc
cmp rax, total
jge .dir_inc
mov total, rax
    .dir_inc:
mov rax, file
mov rax, file_next(rax)
mov file, rax
jmp .dir_loop
    .dir_end:
mov rax, total

mov rsp, rbp
pop rbp
ret

day7:
push rbp
mov rbp, rsp
sub rsp, 128

mov part_specific_func, rcx

mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx

lea rax, root_node
mov file_type(rax), file_type_dir
mov file_parent(rax), 0
mov file_name_len(rax), 1
mov file_name(rax), root_dir
mov file_children(rax), 0
mov file_next(rax), 0

lea rbx, parse_info
mov parse_info_current_dir(rbx), rax
mov parse_info_root_dir(rbx), rax

    .parse_loop:
cmp num_lines, 0
je .parse_loop_end
mov rax, num_lines
mov rbx, lines
lea rcx, parse_info
call parse_instruction
mov num_lines, rax
mov lines, rbx
jmp .parse_loop
    .parse_loop_end:

lea rax, root_node
call part_specific_func
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret

%define parse_info qword [rbp-24]
%define name_len qword [rbp-32]
%define name qword [rbp-40]
%define size qword [rbp-48]
; inputs
;  rax: num_lines
;  rbx: lines
;  rcx: parse_info struct
; outputs
;  rax: num_lines
;  rbx: lines
parse_instruction:
push rbp
mov rbp, rsp
sub rsp, 56
mov num_lines, rax
mov lines, rbx
mov parse_info, rcx

mov rsi, qword [rbx]
mov rax, rsi
mov rbx, qword [rbx+8]
mov rcx, 2
mov rdx, command_prefix
call str_starts_with
cmp rax, 0
je .inc_line

sub rsi, 2
mov rax, rsi
add rbx, 2
mov rcx, 2
mov rdx, ls
call str_equal
cmp rax, 0
jne .ls
mov rax, rsi
mov rcx, 3
mov rdx, cd
call str_starts_with
cmp rax, 0
je .inc_line
sub rsi, 3
mov rax, rsi
add rbx, 3

; cd:
mov rcx, 1
mov rdx, root_dir
call str_equal
cmp rax, 0
je .cd_not_root_dir

; cd /
mov rax, parse_info
mov rbx, parse_info_root_dir(rax)
mov parse_info_current_dir(rax), rbx
jmp .inc_line

    .cd_not_root_dir:
mov rax, rsi
mov rcx, 2
mov rdx, parent_dir
call str_equal
cmp rax, 0
je .cd_not_parent_dir

; cd ..
mov rax, parse_info
mov rbx, parse_info_current_dir(rax)
mov rcx, file_parent(rbx)
cmp rcx, 0
jne .cd_parent_valid
mov rax, 41
mov rbx, parent_of_root_msg
call print
call exit
    .cd_parent_valid:
mov parse_info_current_dir(rax), rcx
jmp .inc_line

    .cd_not_parent_dir:
mov name_len, rsi
mov name, rbx
; search for existing dir
mov r8, parse_info
mov r9, parse_info_current_dir(r8)
mov r10, file_children(r9)
    .cd_existing_loop:
cmp r10, 0
je .cd_new_dir
cmp file_type(r10), file_type_dir
jne .cd_existing_loop_inc
mov rax, rsi
mov rcx, file_name_len(r10)
mov rdx, file_name(r10)
call str_equal
cmp rax, 0
je .cd_existing_loop_inc
; found existing dir in r10
mov parse_info_current_dir(r8), r10
jmp .inc_line
    .cd_existing_loop_inc:
mov r10, file_next(r10)
jmp .cd_existing_loop
    .cd_new_dir:

mov rax, size_of_node
call alloc
mov rbx, parse_info
mov rcx, parse_info_current_dir(rbx)
mov file_type(rax), file_type_dir
mov file_parent(rax), rcx
mov rdx, name_len
mov file_name_len(rax), rdx
mov rdx, name
mov file_name(rax), rdx
mov file_children(rax), 0
mov rdx, file_children(rcx)
mov file_next(rax), rdx
mov file_children(rcx), rax
mov parse_info_current_dir(rbx), rax
jmp .inc_line

    .ls:
sub num_lines, 1
add lines, 16
cmp num_lines, 0
je .ls_end
mov rax, lines
mov rbx, qword [rax+8]
mov rsi, qword [rax]
mov rax, rsi
mov rcx, 2
mov rdx, command_prefix
call str_starts_with
cmp rax, 0
jne .ls_end
mov rax, rsi
mov rcx, ' '
call str_split
cmp rax, 2
jne .ls
mov rsi, rbx
mov rax, qword [rsi+16]
mov name_len, rax
mov rax, qword [rsi+24]
mov name, rax
mov rax, qword [rsi]
mov rbx, qword [rsi+8]
mov rcx, 3
mov rdx, dir
call str_equal
cmp rax, 0
jne .ls_dir

; <file size> <file name>
mov rax, qword [rsi]
call parse_int
cmp rax, 0
jne .ls
mov size, rbx

mov r8, parse_info
mov r9, parse_info_current_dir(r8)
mov r10, file_children(r9)

    .ls_file_existence_loop:
cmp r10, 0
je .ls_new_file
cmp file_type(r10), file_type_normal
jne .ls_file_existence_loop_inc
mov rax, name_len
mov rbx, name
mov rcx, file_name_len(r10)
mov rdx, file_name(r10)
call str_equal
cmp rax, 0
jne .ls
    .ls_file_existence_loop_inc:
mov r10, file_next(r10)
jmp .ls_file_existence_loop

    .ls_new_file:
mov rax, size_of_node
call alloc
mov r8, parse_info
mov r9, parse_info_current_dir(r8)
mov file_type(rax), file_type_normal
mov file_parent(rax), r9
mov rbx, name_len
mov file_name_len(rax), rbx
mov rbx, name
mov file_name(rax), rbx
mov rbx, size
mov file_size(rax), rbx
mov rbx, file_children(r9)
mov file_next(rax), rbx
mov file_children(r9), rax
jmp .ls

    .ls_dir:
mov r8, parse_info
mov r9, parse_info_current_dir(r8)
mov r10, file_children(r9)

    .ls_dir_existence_loop:
cmp r10, 0
je .ls_new_dir
cmp file_type(r10), file_type_dir
jne .ls_dir_existence_loop_inc
mov rax, name_len
mov rbx, name
mov rcx, file_name_len(r10)
mov rdx, file_name(r10)
call str_equal
cmp rax, 0
jne .ls
    .ls_dir_existence_loop_inc:
mov r10, file_next(r10)
jmp .ls_dir_existence_loop

    .ls_new_dir:
mov rax, size_of_node
call alloc
mov r8, parse_info
mov r9, parse_info_current_dir(r8)
mov file_type(rax), file_type_dir
mov file_parent(rax), r9
mov rbx, name_len
mov file_name_len(rax), rbx
mov rbx, name
mov file_name(rax), rbx
mov file_children(rax), 0
mov rbx, file_children(r9)
mov file_next(rax), rbx
mov file_children(r9), rax
jmp .ls

    .ls_end:
mov rax, num_lines
mov rbx, lines
jmp .end

    .inc_line:
mov rax, num_lines
mov rbx, lines
sub rax, 1
add rbx, 16
    .end:
mov rsp, rbp
pop rbp
ret

; inputs
;  rax: the file
; outputs
;  rax: the disk usage
; side effects
;  none
disk_usage:
push rbp
mov rbp, rsp
sub rsp, 24

cmp file_type(rax), file_type_normal
jne .disk_usage_dir
mov rax, file_size(rax)
jmp .end

    .disk_usage_dir:
mov qword [rbp-16], 0
mov rax, file_children(rax)
mov qword [rbp-8], rax
    .disk_usage_loop:
cmp qword [rbp-8], 0
je .disk_usage_end
mov rax, qword [rbp-8]
call disk_usage
add qword [rbp-16], rax
mov rax, qword [rbp-8]
mov rax, file_next(rax)
mov qword [rbp-8], rax
jmp .disk_usage_loop
    .disk_usage_end:
mov rax, qword [rbp-16]

    .end:
mov rsp, rbp
pop rbp
ret

section .data

root_dir:
db "/"

command_prefix:
db "$ "

cd:
db "cd "

ls:
db "ls"

parent_dir:
db ".."

dir:
db "dir"

parent_of_root_msg:
db "Cannot get parent file of root directory", 10

root_too_big_msg:
db "The root directory contains more memory than the file system", 10

already_enough_space_msg:
db "Already enough space", 10
