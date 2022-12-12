extern alloc
extern parse_int
extern print
extern str_append
extern str_equal
extern str_split
extern str_split_str
extern str_starts_with
extern to_string

global day11_1
global day11_2

%define num_lines qword [rbp-8]
%define lines qword [rbp-16]
%define monkey_count qword [rbp-24]
%define monkeys qword [rbp-32]
%define monkey qword [rbp-40]
%define num_items qword [rbp-48]
%define items qword [rbp-56]
%define item qword [rbp-64]
%define round_number qword [rbp-72]
%define monkey_index qword [rbp-80]
%define relief_divisor qword [rbp-88]
%define num_rounds qword [rbp-96]
%define total_modulus qword [rbp-104]

%define size_of_monkey 72
%define monkey_first_item(struct) qword [struct]
%define monkey_last_item(struct) qword [struct+8]
%define monkey_op_type(struct) byte [struct+16]
%define monkey_op_left_type(struct) byte [struct+17]
%define monkey_op_right_type(struct) byte [struct+18]
%define monkey_op_left(struct) qword [struct+24]
%define monkey_op_right(struct) qword [struct+32]
%define monkey_divisibility_test(struct) qword [struct+40]
%define monkey_if_true(struct) qword [struct+48]
%define monkey_if_false(struct) qword [struct+56]
%define monkey_inspect_count(struct) qword [struct+64]

%define size_of_item 16
%define item_worry_level(struct) qword [struct]
%define item_next(struct) qword [struct+8]

%define operand_type_imm 0
%define operand_type_input 1

section .text

day11_1:
mov rcx, 3
mov rdx, 20
call day11
ret

day11_2:
mov rcx, 1
mov rdx, 10000
call day11
ret

day11:
push rbp
mov rbp, rsp
sub rsp, 112
mov relief_divisor, rcx
mov num_rounds, rdx
mov total_modulus, rcx

mov rcx, 10
call str_split
mov num_lines, rax
mov lines, rbx
mov rsi, rax
mov rdi, rbx

xor r10, r10
    .monkey_count_loop:
sub rsi, 1
jc .monkey_count_end
mov rax, qword [rdi]
mov rbx, qword [rdi+8]
mov rcx, 7
mov rdx, monkey_prefix
call str_starts_with
cmp rax, 0
je .monkey_count_inc
add r10, 1
    .monkey_count_inc:
add rdi, 16
jmp .monkey_count_loop
    .monkey_count_end:
mov monkey_count, r10
mov rax, size_of_monkey
mul r10
call alloc
mov monkeys, rax

    .parse_loop:
sub num_lines, 1
jc .parse_loop_end

; find monkey prefix and the monkey struct
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
cmp rax, 9
jl .parse_loop_inc
mov rcx, 7
mov rdx, monkey_prefix
call str_starts_with
cmp rax, 0
je .parse_loop_inc
mov rax, lines
mov rax, qword [rax]
sub rax, 8
add rbx, 7
call parse_int
cmp rax, 0
jne .parse_loop_inc
cmp rbx, 0
jl .parse_loop_inc
cmp rbx, monkey_count
jge .parse_loop_inc
mov rcx, monkeys
mov monkey, rcx
mov rax, size_of_monkey
mul rbx
add monkey, rax

add lines, 16
sub num_lines, 1
jc .parse_loop_end

; starting items
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, 18
mov rdx, starting_items_prefix
call str_starts_with
cmp rax, 0
je .parse_loop_inc
mov rax, lines
mov rax, qword [rax]
sub rax, 18
add rbx, 18
mov rcx, 2
mov rdx, comma_space
call str_split_str
cmp rax, 0
jle .parse_no_items
mov num_items, rax
mov items, rbx
mov rcx, size_of_item
mul rcx
call alloc
mov item, rax
mov rdx, monkey
mov monkey_first_item(rdx), rax
    .parse_item_loop:
sub num_items, 1
jc .parse_item_loop_end
mov rax, items
mov rbx, qword [rax+8]
mov rax, qword [rax]
call parse_int
cmp rax, 0
xor rcx, rcx
cmovne rbx, rcx
mov rax, item
mov item_worry_level(rax), rbx
lea rbx, [rax+size_of_item]
mov item_next(rax), rbx
add items, 16
add item, size_of_item
jmp .parse_item_loop
    .parse_item_loop_end:
mov rax, item
sub rax, size_of_item
mov item_next(rax), 0
mov rbx, monkey
mov monkey_last_item(rbx), rax
jmp .parse_end_items
    .parse_no_items:
mov rdx, monkey
mov monkey_first_item(rdx), 0
mov monkey_last_item(rdx), 0
    .parse_end_items:

add lines, 16
sub num_lines, 1
jc .parse_loop_end

; operation
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, 19
mov rdx, operation_prefix
call str_starts_with
cmp rax, 0
je .parse_loop_inc
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
sub rax, 19
add rbx, 19
mov rcx, ' '
call str_split
cmp rax, 3
jne .parse_loop_inc
;reuse the item slot since we're not using it here
%define op_parts item
mov op_parts, rbx
mov r8, monkey
cmp qword [rbx+16], 1
jne .parse_loop_inc
mov rcx, qword [rbx+24]
mov cl, byte [rcx]
mov monkey_op_type(r8), cl
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
mov rcx, 3
mov rdx, old_keyword
call str_equal
mov monkey_op_left_type(r8), al
cmp rax, 0
jne .left_not_number
mov rbx, op_parts
mov rax, qword [rbx]
mov rbx, qword [rbx+8]
call parse_int
cmp rax, 0
jne .parse_loop_inc
mov monkey_op_left(r8), rbx
    .left_not_number:
mov rbx, op_parts
mov rax, qword [rbx+32]
mov rbx, qword [rbx+40]
mov rcx, 3
mov rdx, old_keyword
call str_equal
mov monkey_op_right_type(r8), al
cmp rax, 0
jne .right_not_number
mov rbx, op_parts
mov rax, qword [rbx+32]
mov rbx, qword [rbx+40]
call parse_int
cmp rax, 0
jne .parse_loop_inc
mov monkey_op_right(r8), rbx
    .right_not_number:
%undef op_parts

add lines, 16
sub num_lines, 1
jc .parse_loop_end

; divisibility test
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, 21
mov rdx, test_prefix
call str_starts_with
cmp rax, 0
je .parse_loop_inc
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
sub rax, 21
add rbx, 21
call parse_int
cmp rax, 0
jne .parse_loop_inc
mov rax, total_modulus
mul rbx
mov total_modulus, rax
mov rax, monkey
mov monkey_divisibility_test(rax), rbx

add lines, 16
sub num_lines, 1
jc .parse_loop_end

; if true
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, 29
mov rdx, if_true_prefix
call str_starts_with
cmp rax, 0
je .parse_loop_inc
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
sub rax, 29
add rbx, 29
call parse_int
cmp rax, 0
jne .parse_loop_inc
cmp rbx, 0
jl .parse_loop_inc
cmp rbx, monkey_count
jge .parse_loop_inc
mov rax, monkey
mov monkey_if_true(rax), rbx

add lines, 16
sub num_lines, 1
jc .parse_loop_end

; if false
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
mov rcx, 30
mov rdx, if_false_prefix
call str_starts_with
cmp rax, 0
je .parse_loop_inc
mov rax, lines
mov rbx, qword [rax+8]
mov rax, qword [rax]
sub rax, 30
add rbx, 30
call parse_int
cmp rax, 0
jne .parse_loop_inc
cmp rbx, 0
jl .parse_loop_inc
cmp rbx, monkey_count
jge .parse_loop_inc
mov rax, monkey
mov monkey_if_false(rax), rbx

    .parse_loop_inc:
add lines, 16
jmp .parse_loop
    .parse_loop_end:

mov round_number, 0
    .round_loop:
add round_number, 1
mov rax, num_rounds
cmp round_number, rax
jg .round_loop_end
mov monkey_index, 0
    .monkey_loop:
mov rax, monkey_count
cmp monkey_index, rax
jge .round_loop
mov rax, monkey_index
mov rbx, size_of_monkey
mul rbx
mov rbx, monkeys
add rax, rbx
mov monkey, rax
mov rax, monkey_first_item(rax)
mov item, rax
    .item_loop:
cmp item, 0
je .monkey_loop_inc
%define worry_level r8
%define left_operand rax
%define right_operand r10
mov rax, item
mov worry_level, item_worry_level(rax)
mov r9, monkey
add monkey_inspect_count(r9), 1
mov left_operand, monkey_op_left(r9)
cmp monkey_op_left_type(r9), operand_type_imm
cmovne left_operand, worry_level
mov right_operand, monkey_op_right(r9)
cmp monkey_op_right_type(r9), operand_type_imm
cmovne right_operand, worry_level
cmp monkey_op_type(r9), '+'
jne .not_plus
add left_operand, right_operand
jmp .op_end
    .not_plus:
cmp monkey_op_type(r9), '*'
jne .op_end
mul right_operand
    .op_end:
xor rdx, rdx
mov rbx, total_modulus
div rbx
mov rax, rdx
xor rdx, rdx
mov rbx, relief_divisor
div rbx
mov worry_level, rax
%undef right_operand
%undef left_operand
mov rbx, monkey_divisibility_test(r9)
cmp rbx, 0
je .skip_div
xor rdx, rdx
div rbx
    .skip_div:
%define next_monkey r10
mov next_monkey, monkey_if_true(r9)
cmp rdx, 0
cmovne next_monkey, monkey_if_false(r9)
mov rax, item
mov item_worry_level(rax), worry_level
%undef worry_level
mov rax, next_monkey
mov rbx, size_of_monkey
mul rbx
mov next_monkey, monkeys
add next_monkey, rax
mov rax, item
cmp monkey_first_item(next_monkey), 0
je .next_monkey_first_item
mov rax, monkey_last_item(next_monkey)
mov rbx, item
mov item_next(rax), rbx
jmp .next_monkey_fix_item_refs
    .next_monkey_first_item:
mov monkey_first_item(next_monkey), rax
    .next_monkey_fix_item_refs:
mov rax, item
mov monkey_last_item(next_monkey), rax
    .item_loop_inc:
mov rax, item
mov rbx, item_next(rax)
mov item_next(rax), 0
mov item, rbx
jmp .item_loop
    .monkey_loop_inc:
mov rax, monkey
mov monkey_first_item(rax), 0
mov monkey_last_item(rax), 0
add monkey_index, 1
jmp .monkey_loop
    .round_loop_end:

%define max_count r8
%define second_max_count r9

mov max_count, -1
mov second_max_count, -1
mov rax, monkey_count
mov rbx, monkeys
    .result_loop:
sub rax, 1
jc .result_loop_end
mov rcx, monkey_inspect_count(rbx)
cmp rcx, max_count
jle .not_max
xchg rcx, max_count
    .not_max:
cmp rcx, second_max_count
jle .not_second_max
xchg rcx, second_max_count
    .not_second_max:
add rbx, size_of_monkey
jmp .result_loop
    .result_loop_end:

mov rax, max_count
mul second_max_count
call to_string
mov rdx, 10
call str_append
call print

mov rsp, rbp
pop rbp
ret

section .data

monkey_prefix:
db "Monkey "

starting_items_prefix:
db "  Starting items: "

comma_space:
db ", "

operation_prefix:
db "  Operation: new = "

old_keyword:
db "old"

test_prefix:
db "  Test: divisible by "

if_true_prefix:
db "    If true: throw to monkey "

if_false_prefix:
db "    If false: throw to monkey "
