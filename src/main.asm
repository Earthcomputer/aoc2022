global _start
global exit

extern alloc
extern c_str_length
extern day_in_month_and_hours_in_day
extern free
extern input
extern parse_int
extern print
extern seconds_since_epoch
extern str_append
extern str_concat
extern str_equal
extern str_to_owned
extern to_string

extern day1_1
extern day1_2
extern day2_1
extern day2_2
extern day3_1
extern day3_2
extern day4_1
extern day4_2
extern day5_1
extern day5_2
extern day6_1
extern day6_2

section .text

_start:
mov rsi, [rsp]
sub rsi, 1
jc .args_end
    .args_loop:
sub rsi, 1
jc .args_end
mov rax, qword [rsp+16+8*rsi]
call c_str_length
mov rbx, qword [rsp+16+8*rsi]
mov rcx, 10
mov rdx, defaults_arg
call str_equal
cmp rax, 0
je .args_loop
mov byte [defaults], 1

    .args_end:
mov rbp, rsp
sub rsp, 64

cmp byte [defaults], 0
je .manual_day_input

call seconds_since_epoch
call day_in_month_and_hours_in_day
cmp rbx, 5
jl .before_5am
add rax, 1
    .before_5am:
cmp rax, 1
jl .show_manual_reason
cmp rax, 25
jg .show_manual_reason
mov rbx, rax
jmp .day_msg_success

    .show_manual_reason:
call to_string
mov r11, rax
mov r12, rbx
mov rax, 51
mov rbx, day_manual_reason_msg
call str_to_owned
mov rbx, rax
mov rax, 51
mov rcx, 51
mov rdx, r11
mov rsi, r12
call str_concat
mov rdx, 10
call str_append
mov r13, rbx
mov r14, rcx
call print
mov rax, r12
mov rbx, r11
call free
mov rax, r13
mov rbx, r14
call free


    .manual_day_input:
mov rax, 32
mov rbx, day_number_msg
call print

call input
call parse_int
cmp rax, 0
jne .day_msg_error
cmp rbx, 1
jl .day_msg_error
cmp rbx, 25
jg .day_msg_error
jmp .day_msg_success

    .day_msg_error:
mov rax, 12
mov rbx, invalid_day_msg
call print
call exit

    .day_msg_success:
mov qword [rbp-8], rbx
mov rax, 29
mov rbx, part_msg
call print

call input
call parse_int
cmp rax, 0
jne .part_msg_error
cmp rbx, 1
je .part_msg_success
cmp rbx, 2
je .part_msg_success

    .part_msg_error:
mov rax, 20
mov rbx, invalid_part_msg
call print
call exit

    .part_msg_success:
mov qword [rbp-16], rbx

cmp byte [defaults], 0
je .ask_input_file
mov rbx, input_txt_null
jmp .end_ask_input_file
    .ask_input_file:
mov rax, 22
mov rbx, input_file_msg
call print
call input
mov rcx, rax
xor rdx, rdx
call str_append
    .end_ask_input_file:

mov rax, 2 ; open
mov rdi, rbx
xor rsi, rsi ; O_RDONLY
xor rdx, rdx ; mode?
syscall
test rax, rax
jns .file_open_success

    .failed_to_open_file:
mov rax, 20
mov rbx, failed_to_open_file_msg
call print
call exit
    .file_open_success:
mov qword [rbp-24], rax
mov rax, 4096
call alloc
mov qword [rbp-32], rax
mov rax, 4096
call alloc
mov qword [rbp-40], rax
mov qword [rbp-48], 0
mov qword [rbp-56], 4096

    .read_file_loop:
xor rax, rax ; read
mov rdi, qword [rbp-24]
mov rsi, qword [rbp-32]
mov rdx, 4096
syscall
cmp rax, -1
je .failed_to_open_file
cmp rax, 0
je .read_file_end
mov rdx, rax
mov rax, qword [rbp-48]
mov rbx, qword [rbp-40]
mov rcx, qword [rbp-56]
call str_concat
mov qword [rbp-48], rax
mov qword [rbp-40], rbx
mov qword [rbp-56], rcx
jmp .read_file_loop

    .read_file_end:
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
jne .valid_function
mov rax, 43
mov rbx, day_unimplemented_msg
call print
call exit

    .valid_function:
mov rcx, rax
mov rax, qword [rbp-48]
mov rbx, qword [rbp-40]
call rcx
call exit
ret

exit:
mov rax, 60 ; exit
xor rdi, rdi
syscall
ret

section .data

defaults_arg:
db "--defaults"

day_number_msg:
db "Enter the day number (1 to 25): "

part_msg:
db "Enter the day part (1 or 2): "

day_manual_reason_msg:
db "Cannot auto-select day, because it would have been "

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

defaults:
db 0

input_txt_null:
db "input.txt", 0

days_table:
dq day1_1
dq day1_2
dq day2_1
dq day2_2
dq day3_1
dq day3_2
dq day4_1
dq day4_2
dq day5_1
dq day5_2
dq day6_1
dq day6_2
dq 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0