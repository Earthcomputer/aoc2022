extern alloc
extern print
extern str_append
extern to_string

global day8_1
global day8_2

%define input_len rax
%define input rbx
%define width rcx
%define height r10
%define seen_array r11
%define tree_height sil
%define width_plus_1 r9
%define x rdi
%define y r8

section .text

detect_tree_seen:
mov rax, y
mul width_plus_1
add rax, x
cmp byte [input+rax], tree_height
jle .end
mov tree_height, byte [input+rax]
mov rax, y
mul width
add rax, x
mov byte [seen_array+rax], 1
    .end:
ret

day8_1:
; detect width
xor width, width
    .detect_width_loop:
cmp width, input_len
jge .detect_width_end
cmp byte [input+width], 10
je .detect_width_end
add width, 1
jmp .detect_width_loop
    .detect_width_end:

; detect height
lea rax, [input_len+width-2]
%undef input_len
xor rdx, rdx
lea width_plus_1, [width+1]
div width_plus_1
mov height, rax

push input
push width
push height
mul width ; height already in rax
call alloc
mov seen_array, rax
pop height
pop width
pop input

lea width_plus_1, [width+1]

mov x, width
    .x_loop:
sub x, 1
jc .x_loop_end

; scan downwards
xor y, y
mov tree_height, -1
    .y_loop_1:
cmp y, height
jge .y_loop_1_end
call detect_tree_seen
add y, 1
jmp .y_loop_1
    .y_loop_1_end:

; scan upwards
mov y, height
mov tree_height, -1
    .y_loop_2:
sub y, 1
jc .x_loop
call detect_tree_seen
jmp .y_loop_2

jmp .x_loop
    .x_loop_end:

mov y, height
    .y_loop:
sub y, 1
jc .y_loop_end

; scan rightwards
xor x, x
mov tree_height, -1
    .x_loop_1:
cmp x, width
jge .x_loop_1_end
call detect_tree_seen
add x, 1
jmp .x_loop_1
    .x_loop_1_end:

; scan leftwards
mov x, width
mov tree_height, -1
    .x_loop_2:
sub x, 1
jc .y_loop
call detect_tree_seen
jmp .x_loop_2

jmp .y_loop
    .y_loop_end:

mov rax, width
mul height
%define length rax
%define sum r10
%undef height ; which was r10
%define tmp rdx
%define tmp_byte dl
%undef input ; which was rdx

xor sum, sum
xor tmp, tmp
    .count_loop:
sub length, 1
jc .count_loop_end
mov tmp_byte, byte [seen_array+length]
add sum, tmp
jmp .count_loop
    .count_loop_end:

mov rax, sum
call to_string
mov rdx, 10
call str_append
call print
ret

%define input_len rax
%define input rbx
%define width rcx
%define temp rdi
%define temp_byte dil
%define height rsi
%define treehouse_x r8
%define treehouse_y r9
; x and y are never used together
%define x r10
%define y r10
%define max_tree_height r11
%define trees_seen_in_direction r12
%define scenic_score r13
%define max_scenic_score r14

day8_2:
; detect width
xor width, width
    .detect_width_loop:
cmp width, input_len
jge .detect_width_end
cmp byte [input+width], 10
je .detect_width_end
add width, 1
jmp .detect_width_loop
    .detect_width_end:

; detect height
lea rax, [input_len+width-2]
%undef input_len
xor rdx, rdx
lea temp, [width+1]
div temp
mov height, rax

xor max_scenic_score, max_scenic_score

mov treehouse_x, width
    .treehouse_x_loop:
sub treehouse_x, 1
jc .treehouse_loop_end
mov treehouse_y, height
    .treehouse_y_loop:
sub treehouse_y, 1
jc .treehouse_x_loop

mov scenic_score, 1

mov rax, treehouse_y
lea temp, [width+1]
mul temp
add rax, treehouse_x
xor temp, temp
mov temp_byte, byte [input+rax]
mov max_tree_height, temp

; scan upwards
xor trees_seen_in_direction, trees_seen_in_direction
mov y, treehouse_y
    .up_loop:
sub y, 1
jc .up_loop_end
add trees_seen_in_direction, 1
mov rax, y
lea temp, [width+1]
mul temp
add rax, treehouse_x
xor temp, temp
mov temp_byte, byte [input+rax]
cmp temp, max_tree_height
jl .up_loop
    .up_loop_end:
mov rax, scenic_score
mul trees_seen_in_direction
mov scenic_score, rax

; scan downwards
xor trees_seen_in_direction, trees_seen_in_direction
mov y, treehouse_y
    .down_loop:
add y, 1
cmp y, height
jge .down_loop_end
add trees_seen_in_direction, 1
mov rax, y
lea temp, [width+1]
mul temp
add rax, treehouse_x
xor temp, temp
mov temp_byte, byte [input+rax]
cmp temp, max_tree_height
jl .down_loop
    .down_loop_end:
mov rax, scenic_score
mul trees_seen_in_direction
mov scenic_score, rax

; scan leftwards
xor trees_seen_in_direction, trees_seen_in_direction
mov x, treehouse_x
    .left_loop:
sub x, 1
jc .left_loop_end
add trees_seen_in_direction, 1
mov rax, treehouse_y
lea temp, [width+1]
mul temp
add rax, x
xor temp, temp
mov temp_byte, byte [input+rax]
cmp temp, max_tree_height
jl .left_loop
    .left_loop_end:
mov rax, scenic_score
mul trees_seen_in_direction
mov scenic_score, rax

; scan rightwards
xor trees_seen_in_direction, trees_seen_in_direction
mov x, treehouse_x
    .right_loop:
add x, 1
cmp x, width
jge .right_loop_end
add trees_seen_in_direction, 1
mov rax, treehouse_y
lea temp, [width+1]
mul temp
add rax, x
xor temp, temp
mov temp_byte, byte [input+rax]
cmp temp, max_tree_height
jl .right_loop
    .right_loop_end:
mov rax, scenic_score
mul trees_seen_in_direction
mov scenic_score, rax

cmp scenic_score, max_scenic_score
jle .treehouse_y_loop
mov max_scenic_score, scenic_score
jmp .treehouse_y_loop
    .treehouse_loop_end:

mov rax, max_scenic_score
call to_string
mov rdx, 10
call str_append
call print
ret
