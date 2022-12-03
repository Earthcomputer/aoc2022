extern exit
extern parse_int
extern print
extern str_append
extern str_split
extern to_string

global day1_1
global day1_2

section .text

day1_1:
mov r12, 0
call day1
ret

day1_2:
mov r12, 1
call day1
ret

; expects a bool in r12 for whether it's part 2
day1:
mov cl, 10
call str_split
mov r8, rax ; number of lines
mov r9, rbx ; lines
xor r10, r10 ; max sum
xor r11, r11 ; current sum
xor r13, r13 ; second max sum
xor r14, r14 ; third max sum

    .loop:
sub r8, 1
jc .loop_end
mov rax, qword [r9]
cmp rax, 0
je .empty_line
mov rbx, qword [r9+8]
call parse_int
cmp rax, 0
je .valid_number
mov rax, 15
mov rbx, invalid_number_msg
call print
call exit
    .valid_number:
add r11, rbx
jmp .loop_inc
    .empty_line:
call triple_compare
xor r11, r11
    .loop_inc:
add r9, 16
jmp .loop

    .loop_end:
call triple_compare
mov rax, r10
cmp r12, 0
je .pt1
add rax, r13
add rax, r14
    .pt1:
call to_string
mov dl, 10
call str_append
call print

ret

; inputs
;  r11: value to compare
;  r10: first value
;  r13: second value
;  r14: third value
; side effects
;  clobbers r11
triple_compare:
cmp r11, r10
jle .fail1
xchg r10, r11
    .fail1:
cmp r11, r13
jle .fail2
xchg r13, r11
    .fail2:
cmp r11, r14
jle .fail3
mov r14, r11
    .fail3:
ret

section .data

invalid_number_msg:
db "Invalid number", 10
