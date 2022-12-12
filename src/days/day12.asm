extern alloc
extern print
extern str_append
extern to_string

global day12_1
global day12_2

%define input qword [rbp-8]
%define width qword [rbp-16]
%define height qword [rbp-24]
%define reachable qword [rbp-32]
%define next_reachable qword [rbp-40]
%define part2 qword [rbp-48]

section .text

day12_1:
xor rcx, rcx
call day12
ret

day12_2:
mov rcx, 1
call day12
ret

day12:
push rbp
mov rbp, rsp
sub rsp, 56
mov input, rbx
mov part2, rcx

xor rcx, rcx
    .find_width:
cmp rcx, rax
jge .find_width_end
cmp byte [rbx+rcx], 10
je .find_width_end
add rcx, 1
jmp .find_width
    .find_width_end:
mov width, rcx
add rcx, 1
xor rdx, rdx
add rax, 1
div rcx
mov height, rax
mov rcx, width
mul rcx
mov next_reachable, rax
shl rax, 1
call alloc
mov reachable, rax
add next_reachable, rax

%define x r8
%define y r9

; find the start position
mov x, width
    .find_start_x_loop:
sub x, 1
jc .find_start_x_loop_end
mov y, height
    .find_start_y_loop:
sub y, 1
jc .find_start_x_loop
mov rax, y
mov rbx, width
add rbx, 1
mul rbx
add rax, x
mov rbx, input
cmp byte [rbx+rax], 'S'
je .found_start
cmp part2, 0
je .find_start_y_loop
cmp byte [rbx+rax], 'a'
jne .find_start_y_loop
    .found_start:
mov rax, y
mul width
add rax, x
mov rbx, reachable
mov byte [rbx+rax], 1
mov rbx, next_reachable
mov byte [rbx+rax], 1
jmp .find_start_y_loop
    .find_start_x_loop_end:

%define steps r10
%define max_steps r11
%define input_ptr r12
%define next_reachable_ptr r13
%define current_elevation_byte sil
%define current_elevation rsi

; iterate neighbors
xor steps, steps
mov rax, width
mul height
mov max_steps, rax
    .main_loop:
mov rax, reachable
mov rbx, next_reachable
mov next_reachable, rax
mov reachable, rbx
add steps, 1
cmp steps, max_steps
jg .main_loop_end
mov x, width
    .main_x_loop:
sub x, 1
jc .main_loop
mov y, height
    .main_y_loop:
sub y, 1
jc .main_x_loop
mov rax, y
mul width
add rax, x
mov rbx, reachable
cmp byte [rbx+rax], 1
jne .main_y_loop
mov rbx, next_reachable
lea next_reachable_ptr, [rbx+rax]
mov rax, y
mov rbx, width
add rbx, 1
mul rbx
add rax, x
mov rbx, input
lea input_ptr, [rbx+rax]
xor current_elevation, current_elevation
mov current_elevation_byte, byte [input_ptr]
cmp byte [input_ptr], 'S'
jne .origin_not_s
mov current_elevation, 'a'
    .origin_not_s:

cmp y, 0
je .no_up
mov rax, input_ptr
sub rax, width
sub rax, 1
xor rbx, rbx
mov bl, byte [rax]
cmp rbx, 'S'
jne .up_not_s
mov rbx, 'a'
jmp .up_elev_cmp_end
    .up_not_s:
cmp rbx, 'E'
jne .up_elev_cmp_end
mov rbx, 'z'
    .up_elev_cmp_end:
sub rbx, current_elevation
cmp rbx, 1
jg .no_up
cmp byte [rax], 'E'
je .main_loop_end
mov rax, next_reachable_ptr
sub rax, width
mov byte [rax], 1
    .no_up:

mov rax, height
sub rax, 1
cmp y, rax
je .no_down
mov rax, input_ptr
add rax, width
add rax, 1
xor rbx, rbx
mov bl, byte [rax]
cmp rbx, 'S'
jne .down_not_s
mov rbx, 'a'
jmp .down_elev_cmp_end
    .down_not_s:
cmp rbx, 'E'
jne .down_elev_cmp_end
mov rbx, 'z'
    .down_elev_cmp_end:
sub rbx, current_elevation
cmp rbx, 1
jg .no_down
cmp byte [rax], 'E'
je .main_loop_end
mov rax, next_reachable_ptr
add rax, width
mov byte [rax], 1
    .no_down:

cmp x, 0
je .no_left
mov rax, input_ptr
xor rbx, rbx
mov bl, byte [rax-1]
cmp rbx, 'S'
jne .left_not_s
mov rbx, 'a'
jmp .left_elev_cmp_end
    .left_not_s:
cmp rbx, 'E'
jne .left_elev_cmp_end
mov rbx, 'z'
    .left_elev_cmp_end:
sub rbx, current_elevation
cmp rbx, 1
jg .no_left
cmp byte [rax-1], 'E'
je .main_loop_end
mov byte [next_reachable_ptr-1], 1
    .no_left:

mov rax, width
sub rax, 1
cmp x, rax
je .main_y_loop
mov rax, input_ptr
xor rbx, rbx
mov bl, byte [rax+1]
cmp rbx, 'S'
jne .right_not_s
mov rbx, 'a'
jmp .right_elev_cmp_end
    .right_not_s:
cmp rbx, 'E'
jne .right_elev_cmp_end
mov rbx, 'z'
    .right_elev_cmp_end:
sub rbx, current_elevation
cmp rbx, 1
jg .main_y_loop
cmp byte [rax+1], 'E'
je .main_loop_end
mov byte [next_reachable_ptr+1], 1
jmp .main_y_loop

    .main_loop_end:
mov rax, steps
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret
