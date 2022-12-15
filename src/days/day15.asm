extern alloc
extern max_int
extern parse_int
extern print
extern str_append
extern str_split
extern to_string

global day15_1
global day15_2

%define size_of_sensor 32
%define sensor_x(struct) qword [struct]
%define sensor_y(struct) qword [struct+8]
%define sensor_beacon_x(struct) qword [struct+16]
%define sensor_beacon_y(struct) qword [struct+24]

%define size_of_x_list 16
%define x_list_value(struct) qword [struct]
%define x_list_next(struct) qword [struct+8]

%define part1_y 2000000
%define part2_range 4000000

; abs <register> <temp1>
%macro abs 2
mov %2, %1
neg %1
cmp %1, %2
cmovl %1, %2
%endmacro

; sensor_range <sensor> <y_position> <out_left> <out_right> <out_is_valid> <temp1> <temp2>
%macro sensor_range 7
mov %6, sensor_beacon_x(%1)
sub %6, sensor_x(%1)
abs %6, %5
mov %7, sensor_beacon_y(%1)
sub %7, sensor_y(%1)
abs %7, %5
add %6, %7
mov %7, sensor_y(%1)
sub %7, %2
abs %7, %5
sub %6, %7
jc %%out_of_range
mov %5, 1
mov %3, sensor_x(%1)
sub %3, %6
mov %4, sensor_x(%1)
add %4, %6
jmp %%end
    %%out_of_range:
xor %5, %5
mov %3, qword [max_int]
mov %4, sensor_x(%1)
    %%end:
%endmacro

section .text

day15_1:
%define num_sensors qword [rbp-8]
%define sensors qword [rbp-16]
%define old_right qword [rbp-24]
%define left qword [rbp-32]
%define right qword [rbp-40]
%define result qword [rbp-48]
%define existing_beacon_xs qword [rbp-56]
push rbp
mov rbp, rsp
sub rsp, 64
call parse_input
mov num_sensors, rax
mov sensors, rbx
mov rcx, part1_y
call sort_sensors
mov result, 0
mov existing_beacon_xs, 0
mov num_sensors, rax
cmp rax, 0
je .sensor_loop_end
mov rax, sensors
sensor_range rax, part1_y, rdi, rbx, rcx, rdx, rsi
mov old_right, rdi
sub old_right, 1
    .sensor_loop:
sub num_sensors, 1
jc .sensor_loop_end
mov rax, sensors
cmp sensor_beacon_y(rax), part1_y
jne .beacon_check_end
mov rax, sensor_beacon_x(rax)
mov rbx, existing_beacon_xs
    .beacon_check_loop:
cmp rbx, 0
je .beacon_not_exists
cmp rax, x_list_value(rbx)
je .beacon_check_end
mov rbx, x_list_next(rbx)
jmp .beacon_check_loop
    .beacon_not_exists:
sub result, 1
mov rax, size_of_x_list
call alloc
mov rbx, sensors
mov rbx, sensor_beacon_x(rbx)
mov x_list_value(rax), rbx
mov rbx, existing_beacon_xs
mov x_list_next(rax), rbx
mov existing_beacon_xs, rax
    .beacon_check_end:
mov rax, sensors
sensor_range rax, part1_y, rsi, rdi, rbx, rcx, rdx
mov left, rsi
mov right, rdi
mov rax, old_right
cmp right, rax
jle .sensor_loop_inc
add old_right, 1
mov rax, old_right
mov rbx, left
cmp rbx, rax
cmovl rbx, rax
mov left, rbx
mov rax, right
sub rax, left
add rax, 1
add result, rax
mov rax, right
mov old_right, rax
    .sensor_loop_inc:
add sensors, size_of_sensor
jmp .sensor_loop
    .sensor_loop_end:

mov rax, result
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret
%undef existing_beacon_xs
%undef result
%undef right
%undef left
%undef old_right
%undef sensors
%undef num_sensors

day15_2:
%define num_sensors qword [rbp-8]
%define sensors qword [rbp-16]
%define y qword [rbp-24]
%define num_relevant_sensors r8
%define relevant_sensor r9
%define old_right r10
%define left r11
%define right r12
push rbp
mov rbp, rsp
sub rsp, 32
call parse_input
mov num_sensors, rax
mov sensors, rbx
mov y, part2_range+1
    .y_loop:
sub y, 1
jc .y_loop_end
mov rax, num_sensors
mov rbx, sensors
mov rcx, y
call sort_sensors
cmp rax, 0
je .y_loop
mov num_relevant_sensors, rax
mov relevant_sensor, sensors
xor old_right, old_right
    .sensor_loop:
sub num_relevant_sensors, 1
jc .y_loop
mov rax, relevant_sensor
mov rbx, y
sensor_range rax, rbx, left, right, rcx, rdx, rsi
lea rax, [old_right+1]
cmp rax, left
jl .y_loop_end
cmp right, part2_range
jge .y_loop
cmp old_right, right
cmovl old_right, right
    .sensor_loop_inc:
add relevant_sensor, size_of_sensor
jmp .sensor_loop
    .y_loop_end:
lea rax, [old_right+1]
mov rbx, 4000000
mul rbx
add rax, y
call to_string
mov rdx, 10
call str_append
call print
mov rsp, rbp
pop rbp
ret
%undef right
%undef left
%undef old_right
%undef relevant_sensor
%undef num_relevant_sensors
%undef y
%undef sensors
%undef num_sensors

; inputs
;  rax: input length
;  rbx: input
; outputs
;  rax: number of sensors
;  rbx: sensor list
parse_input:
%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define num_sensors qword [rbp-24]
%define sensors qword [rbp-32]
%define parts qword [rbp-40]
%define current_sensor qword [rbp-48]
push rbp
mov rbp, rsp
sub rsp, 56

mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx
mov num_sensors, 0
mov rdx, size_of_sensor
mul rdx
call alloc
mov sensors, rax
lea rbx, [rax-size_of_sensor]
mov current_sensor, rbx

    .parse_loop:
sub num_lines, 1
jc .parse_loop_end

mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, ' '
call str_split
cmp rax, 10
jne .parse_loop_inc
add num_sensors, 1
add current_sensor, size_of_sensor
mov parts, rbx

mov rax, qword [rbx+32]
mov rbx, qword [rbx+40]
cmp rax, 4
jl .parse_loop_inc
sub rax, 3
add rbx, 2
call parse_int
cmp rax, 0
jne .parse_loop_inc
mov rax, current_sensor
mov sensor_x(rax), rbx

mov rax, parts
mov rbx, qword [rax+56]
mov rax, qword [rax+48]
cmp rax, 4
jl .parse_loop_inc
sub rax, 3
add rbx, 2
call parse_int
cmp rax, 0
jne .parse_loop_inc
mov rax, current_sensor
mov sensor_y(rax), rbx

mov rax, parts
mov rbx, qword [rax+136]
mov rax, qword [rax+128]
cmp rax, 4
jl .parse_loop_inc
sub rax, 3
add rbx, 2
call parse_int
cmp rax, 0
jne .parse_loop_inc
mov rax, current_sensor
mov sensor_beacon_x(rax), rbx

mov rax, parts
mov rbx, qword [rax+152]
mov rax, qword [rax+144]
cmp rax, 3
jl .parse_loop_inc
sub rax, 2
add rbx, 2
call parse_int
cmp rax, 0
jne .parse_loop_inc
mov rax, current_sensor
mov sensor_beacon_y(rax), rbx

    .parse_loop_inc:
add lines, 16
jmp .parse_loop
    .parse_loop_end:

mov rax, num_sensors
mov rbx, sensors
mov rsp, rbp
pop rbp
ret
%undef current_sensor
%undef parts
%undef sensors
%undef num_sensors
%undef lines
%undef num_lines

; inputs
;  rax: num sensors
;  rbx: sensors
;  rcx: y position
; outputs
;  rax: num valid sensors
sort_sensors:
%define num_sensors rsi
%define sensors rbx
%define y_position rcx
%define i rdi
%define j r8
%define num_valid r9
%define value_left r10
%define value_right r11
%define other_left r12
%define other_right r13
%define temp1 r14
%define temp2 r15
%define value ymm0
cmp rax, 0
je .end
mov num_sensors, rax
sensor_range rbx, y_position, value_left, value_right, num_valid, temp1, temp2

xor i, i
    .outer_loop:
add i, 1
cmp i, num_sensors
jge .outer_loop_end
mov rax, i
mov rdx, size_of_sensor
mul rdx
add rax, sensors
vmovdqu value, [rax]
sensor_range rax, y_position, value_left, value_right, rdx, temp1, temp2
add num_valid, rdx

mov j, i
    .inner_loop:
sub j, 1
jc .inner_loop_end
mov rax, j
mov rdx, size_of_sensor
mul rdx
add rax, sensors
sensor_range rax, y_position, other_left, other_right, rdx, temp1, temp2
cmp other_left, value_left
jl .inner_loop_end
jg .inner_test_end
cmp other_right, value_right
jge .inner_loop_end
    .inner_test_end:
vmovdqu ymm1, [rax]
vmovdqu [rax+size_of_sensor], ymm1
jmp .inner_loop
    .inner_loop_end:
lea rax, [j+1]
mov rdx, size_of_sensor
mul rdx
add rax, sensors
vmovdqu [rax], value
jmp .outer_loop
    .outer_loop_end:
mov rax, num_valid
    .end:
ret
%undef value
%undef temp2
%undef temp1
%undef other_right
%undef other_left
%undef value_right
%undef value_left
%undef num_valid
%undef j
%undef i
%undef y_position
%undef sensors
%undef num_sensors
