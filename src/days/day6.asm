extern print
extern str_append
extern to_string

global day6_1
global day6_2

%define block_size rsi
%define input_len rax
%define input_str rbx
%define block_end rcx
%define pos1 r11
%define pos2 r12

section .text

day6_1:
mov block_size, 4
call day6
ret

day6_2:
mov block_size, 14
call day6
ret

day6:
lea block_end, [block_size-1]
    .loop:
cmp block_end, input_len
jge .loop_end
lea pos1, [block_end+1]
sub pos1, block_size
    .inner_loop:
cmp pos1, block_end
jge .loop_end
lea pos2, [pos1+1]
    .inner_loop2:
cmp pos2, block_end
jg .inner_loop_inc
mov dl, byte [input_str+pos1]
cmp dl, byte [input_str+pos2]
je .loop_inc
add pos2, 1
jmp .inner_loop2
    .inner_loop_inc:
add pos1, 1
jmp .inner_loop
    .loop_inc:
add block_end, 1
jmp .loop
    .loop_end:
add block_end, 1
mov rax, block_end
call to_string
mov rdx, 10
call str_append
call print
ret
