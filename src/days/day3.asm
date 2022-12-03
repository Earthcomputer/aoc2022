extern _end
extern print
extern str_append
extern str_split
extern to_string

global day3_1
global day3_2

section .text

day3_1:
mov rcx, 10
call str_split
xor r12, r12

    .loop:
sub rax, 1
jc .loop_end
mov rcx, qword [rbx]
mov rdx, rcx
and rdx, 1
cmp rdx, 0
je .valid_input
mov rax, 14
mov rbx, invalid_input_msg
call print
call _end
    .valid_input:
shr rcx, 1
mov r9, rcx
mov rdx, qword [rbx+8]
call str_to_bitset
mov r8, rsi
mov rcx, r9
add rdx, rcx
call str_to_bitset
and rsi, r8
cmp rsi, 0
je .loop
tzcnt rsi, rsi
add r12, rsi
add rbx, 16
jmp .loop
    .loop_end:
mov rax, r12
call to_string
mov rdx, 10
call str_append
call print
ret

day3_2:
mov rcx, 10
call str_split
xor rdx, rdx
mov rcx, 3
div rcx
mul rcx
xor r12, r12

    .loop:
sub rax, 3
jc .loop_end
mov rcx, qword [rbx]
mov rdx, qword [rbx+8]
call str_to_bitset
mov r13, rsi
mov rcx, qword [rbx+16]
mov rdx, qword [rbx+24]
call str_to_bitset
and r13, rsi
mov rcx, qword [rbx+32]
mov rdx, qword [rbx+40]
call str_to_bitset
and r13, rsi
tzcnt r13, r13
add r12, r13
add rbx, 48
jmp .loop
    .loop_end:
mov rax, r12
call to_string
mov rdx, 10
call str_append
call print
ret

; inputs
;  rcx: length
;  rdx: string
; outputs
;  rsi: bitset
; side effects
;  clobbers rcx, rdi, r10, r11
str_to_bitset:
xor rsi, rsi
xor rdi, rdi
    .loop:
sub rcx, 1
jc .loop_end
mov dil, byte [rdx+rcx]
cmp dil, 'a'
jl .uppercase_test
cmp dil, 'z'
jg .invalid_input
sub dil, 96
mov r10, 1
mov r11, rcx
mov cl, dil
shl r10, cl
mov rcx, r11
or rsi, r10
jmp .loop

    .uppercase_test:
cmp dil, 'A'
jl .invalid_input
cmp dil, 'Z'
jg .invalid_input
sub dil, 38
mov r10, 1
mov r11, rcx
mov cl, dil
shl r10, cl
mov rcx, r11
or rsi, r10
jmp .loop

    .invalid_input:
mov rax, 14
mov rbx, invalid_input_msg
call print
call _end

    .loop_end:
ret

section .data

invalid_input_msg:
db "Invalid input", 10
