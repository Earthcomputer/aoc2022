extern alloc
extern exit
extern parse_int
extern print
extern str_append
extern str_split
extern str_split_str
extern to_string

global day14_1
global day14_2

;%define debug

%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define min_x qword [rbp-24]
%define max_x qword [rbp-32]
%define min_y qword [rbp-40]
%define max_y qword [rbp-48]
%define grid qword [rbp-56]
%define from_x qword [rbp-64]
%define to_x qword [rbp-72]
%define from_y qword [rbp-80]
%define to_y qword [rbp-88]
%define lines_left qword [rbp-96]
%define line qword [rbp-104]
%define parts_left qword [rbp-112]
%define part qword [rbp-120]
%define debug_char byte [rbp-128]
%define part2 byte [rbp-127]

section .text

day14_1:
xor rcx, rcx
call day14
ret

day14_2:
mov rcx, 1
call day14
ret

day14:
push rbp
mov rbp, rsp
sub rsp, 136
mov part2, cl

mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx

; figure out the min and max x and y
mov rax, qword [min_int]
mov rbx, qword [max_int]
mov min_x, rbx
mov max_x, rax
mov min_y, rbx
mov max_y, rax

%define coord_parts r12
mov rax, num_lines
mov lines_left, rax
mov rax, lines
mov line, rax
    .get_minmax_loop:
sub lines_left, 1
jc .get_minmax_loop_end
mov rax, line
mov rax, qword [rax]
cmp rax, 0
je .get_minmax_loop_inc
mov rax, line
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, 4
mov rdx, arrow
call str_split_str
mov parts_left, rax
mov part, rbx
    .get_minmax_line_loop:
sub parts_left, 1
jc .get_minmax_loop_inc
mov rax, part
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, ','
call str_split
cmp rax, 2
jne .syntax_error
mov coord_parts, rbx
mov rax, qword [coord_parts]
mov rbx, qword [coord_parts+8]
call parse_int
cmp rax, 0
jne .syntax_error
mov rax, min_x
cmp rbx, min_x
cmovl rax, rbx
mov min_x, rax
mov rax, max_x
cmp rbx, max_x
cmovg rax, rbx
mov max_x, rax
mov rax, qword [coord_parts+16]
mov rbx, qword [coord_parts+24]
call parse_int
cmp rax, 0
jne .syntax_error
mov rax, min_y
cmp rbx, min_y
cmovl rax, rbx
mov min_y, rax
mov rax, max_y
cmp rbx, max_y
cmovg rax, rbx
mov max_y, rax
add part, 16
jmp .get_minmax_line_loop
    .get_minmax_loop_inc:
add line, 16
jmp .get_minmax_loop
    .get_minmax_loop_end:

%xdefine width max_x
%undef max_x
%xdefine height max_y
%undef max_y
mov rax, min_x
sub width, rax
add width, 1
mov rax, min_y
sub height, rax
add height, 1

; sand can pile up above the top of the walls by up to half the width
mov rax, width
add rax, 1
shr rax, 1
sub min_y, rax
add height, rax

; sand can fall off either side
sub min_x, 1
add width, 2

cmp part2, 0
je .max_x_good
; the maximum y is 2 lower than the lowest
add height, 2
; can pile left and right of 500 by up to the height
mov rax, 500
sub rax, height
cmp rax, min_x
jge .min_x_good
mov min_x, rax
    .min_x_good:
mov rax, 500
add rax, height
mov rbx, min_x
add rbx, width
sub rbx, 1
cmp rax, rbx
jle .max_x_good
sub rax, min_x
add rax, 1
mov width, rax
    .max_x_good:

; allocate the grid
mov rax, width
mul height
call alloc
mov grid, rax

; draw the walls
mov rax, num_lines
mov lines_left, rax
mov rax, lines
mov line, rax
    .wall_draw_loop:
sub lines_left, 1
jc .wall_draw_loop_end
mov rax, line
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, 4
mov rdx, arrow
call str_split_str
cmp rax, 2
jl .wall_draw_loop_inc
mov parts_left, rax
sub parts_left, 1
mov part, rbx
    .wall_draw_line_loop:
sub parts_left, 1
jc .wall_draw_loop_inc

; parse line segment
mov rax, part
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, ','
call str_split
mov coord_parts, rbx
mov rax, qword [coord_parts]
mov rbx, qword [coord_parts+8]
call parse_int
sub rbx, min_x
mov from_x, rbx
mov rax, qword [coord_parts+16]
mov rbx, qword [coord_parts+24]
call parse_int
sub rbx, min_y
mov from_y, rbx
mov rax, part
mov rbx, qword [rax+24]
mov rax, qword [rax+16]
mov rcx, ','
call str_split
mov coord_parts, rbx
mov rax, qword [coord_parts]
mov rbx, qword [coord_parts+8]
call parse_int
sub rbx, min_x
mov to_x, rbx
mov rax, qword [coord_parts+16]
mov rbx, qword [coord_parts+24]
call parse_int
sub rbx, min_y
mov to_y, rbx

; draw the line segment
mov rax, to_x
cmp from_x, rax
jne .horizontal_line
mov rbx, from_y
mov rcx, to_y
cmp rbx, rcx
jle .vert_line_loop
xchg rbx, rcx
    .vert_line_loop:
cmp rbx, rcx
jg .wall_draw_line_loop_inc
mov rax, rbx
mul width
add rax, from_x
mov rdx, grid
mov byte [rdx+rax], 1
add rbx, 1
jmp .vert_line_loop
    .horizontal_line:
mov rbx, from_x
mov rcx, to_x
cmp rbx, rcx
jle .hor_line_loop
xchg rbx, rcx
    .hor_line_loop:
cmp rbx, rcx
jg .wall_draw_line_loop_inc
mov rax, from_y
mul width
add rax, rbx
mov rdx, grid
mov byte [rdx+rax], 1
add rbx, 1
jmp .hor_line_loop

    .wall_draw_line_loop_inc:
add part, 16
jmp .wall_draw_line_loop
    .wall_draw_loop_inc:
add line, 16
jmp .wall_draw_loop
    .wall_draw_loop_end:

cmp part2, 0
je .no_floor
mov rax, height
sub rax, 1
mul width
add rax, grid
mov rbx, width
    .place_floor_loop:
sub rbx, 1
jc .no_floor
mov byte [rax+rbx], 1
jmp .place_floor_loop
    .no_floor:

; simulate the sand
%define sand_x r8
%define sand_y r9
%define num_sand r10
mov num_sand, -1

    .simulation_loop:

%ifdef debug
push num_sand
mov from_y, 0
    .debug_y_loop:
mov rax, height
cmp from_y, rax
jge .debug_y_end
mov from_x, 0
    .debug_x_loop:
mov rax, width
cmp from_x, rax
jge .debug_y_inc
mov rax, from_y
mul width
add rax, from_x
mov rdx, grid
mov cl, '.'
cmp byte [rdx+rax], 0
je .debug_not_wall
mov cl, '#'
    .debug_not_wall:
mov debug_char, cl
mov rax, 1
lea rbx, debug_char
call print
    .debug_x_inc:
add from_x, 1
jmp .debug_x_loop
    .debug_y_inc:
mov debug_char, 10
mov rax, 1
lea rbx, debug_char
call print
add from_y, 1
jmp .debug_y_loop
    .debug_y_end:
pop num_sand
%endif

add num_sand, 1
mov sand_x, 500
sub sand_x, min_x
xor sand_y, sand_y

    .sand_fall_loop:
add sand_y, 1
cmp sand_y, height
jge .simulation_end
mov rax, sand_y
mul width
add rax, sand_x
mov rdx, grid
cmp byte [rdx+rax], 0
je .sand_fall_loop
sub sand_x, 1
sub rax, 1
cmp byte [rdx+rax], 0
je .sand_fall_loop
add sand_x, 2
add rax, 2
cmp byte [rdx+rax], 0
je .sand_fall_loop
sub sand_x, 1
sub sand_y, 1
mov rax, sand_y
mul width
add rax, sand_x
mov rdx, grid
mov byte [rdx+rax], 1
cmp part2, 0
je .simulation_loop
mov rax, sand_x
add rax, min_x
cmp rax, 500
jne .simulation_loop
mov rax, sand_y
add rax, min_y
cmp rax, 0
jne .simulation_loop
add num_sand, 1
    .simulation_end:

mov rax, num_sand
call to_string
mov rdx, 10
call str_append
call print

jmp .end
    .syntax_error:
mov rax, 13
mov rbx, syntax_error_msg
call print
call exit

    .end:
mov rsp, rbp
pop rbp
ret

section .data

min_int:
dq 0h8000000000000000
max_int:
dq 0h7fffffffffffffff

syntax_error_msg:
db "Syntax error", 10

arrow:
db " -> "
