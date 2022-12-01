global _start
global _end

extern alloc
extern free
extern input
extern parse_int
extern print
extern str_append
extern str_concat
extern to_string

extern day1_1
extern day1_2

section .text

_start:
mov rbp, rsp
sub rsp, 64

mov rax, 32
mov rbx, day_number_msg
call print

call input
call parse_int
cmp rax, 0
jne _start_day_msg_error
cmp rbx, 1
jl _start_day_msg_error
cmp rbx, 25
jg _start_day_msg_error
jmp _start_day_msg_success

    _start_day_msg_error:
mov rax, 12
mov rbx, invalid_day_msg
call print
jmp _end

    _start_day_msg_success:
mov qword [rbp-8], rbx
mov rax, 29
mov rbx, part_msg
call print

call input
call parse_int
cmp rax, 0
jne _start_part_msg_error
cmp rbx, 1
je _start_part_msg_success
cmp rbx, 2
je _start_part_msg_success

    _start_part_msg_error:
mov rax, 20
mov rbx, invalid_part_msg
call print
jmp _end

    _start_part_msg_success:
mov qword [rbp-16], rbx

mov rax, 22
mov rbx, input_file_msg
call print
call input
mov rcx, rax
xor rdx, rdx
call str_append

mov rax, 2 ; open
mov rdi, rbx
xor rsi, rsi ; O_RDONLY
xor rdx, rdx ; mode?
syscall
test rax, rax
jns _start_file_open_success

    _start_failed_to_open_file:
mov rax, 20
mov rbx, failed_to_open_file_msg
call print
jmp _end
    _start_file_open_success:
mov qword [rbp-24], rax
mov rax, 4096
call alloc
mov qword [rbp-32], rax
mov rax, 4096
call alloc
mov qword [rbp-40], rax
mov qword [rbp-48], 0
mov qword [rbp-56], 4096

    _start_read_file_loop:
xor rax, rax ; read
mov rdi, qword [rbp-24]
mov rsi, qword [rbp-32]
mov rdx, 4096
syscall
cmp rax, -1
je _start_failed_to_open_file
cmp rax, 0
je _start_read_file_end
mov rdx, rax
mov rax, qword [rbp-48]
mov rbx, qword [rbp-40]
mov rcx, qword [rbp-56]
call str_concat
mov qword [rbp-48], rax
mov qword [rbp-40], rbx
mov qword [rbp-56], rcx
jmp _start_read_file_loop

    _start_read_file_end:
mov rax, 6 ; close
mov rdi, qword [rbp-24]
syscall

mov rbx, qword [rbp-16]
sub rbx, 1
mov rax, qword [rbp-8]
sub rax, 1
shl rax, 1
add rax, rbx
mov rax, [days_table+rax*8]
cmp rax, 0
jne _start_valid_function
mov rax, 43
mov rbx, day_unimplemented_msg
call print
jmp _end

    _start_valid_function:
mov rcx, rax
mov rax, qword [rbp-48]
mov rbx, qword [rbp-40]
call rcx

_end:
mov rax, 60 ; exit
xor rdi, rdi
syscall

section .data

day_number_msg:
db "Enter the day number (1 to 25): "

part_msg:
db "Enter the day part (1 or 2): "

input_file_msg:
db "Enter the input file: "

invalid_day_msg:
db "Invalid day", 10

invalid_part_msg:
db "Invalid part number", 10

failed_to_open_file_msg:
db "Failed to open file", 10

day_unimplemented_msg:
db "That function has not been implemented yet", 10


days_table:
dq day1_1
dq day1_2
dq 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0