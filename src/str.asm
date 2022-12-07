global c_str_length
global parse_int
global str_append
global str_concat
global str_equal
global str_split
global str_starts_with
global str_to_owned
global to_string

extern alloc
extern realloc

section .text

; inputs
;  rax: length of string
;  rbx: the string
; outputs
;  rax: 0 if success, 1 if error
;  rbx: the result (if success)
; side effects:
;  clobbers rbx if not success, rcx, rdx, rsi, rdi
parse_int:
xor rcx, rcx ; result
mov rdx, 1 ; has not seen any digit
mov rdi, 1 ; multiplier

    .loop:
sub rax, 1
jc .end_loop
cmp byte [rbx+rax], '0'
jl .not_digit
cmp byte [rbx+rax], '9'
jg .not_digit
xor rsi, rsi
mov sil, byte [rbx+rax]
sub rsi, '0'
imul rsi, rdi
add rcx, rsi
imul rdi, 10
xor rdx, rdx
jmp .loop

    .not_digit:
cmp rax, 0
jne .error
cmp byte [rbx], '+'
je .end_loop
cmp byte [rbx], '-'
jne .error
neg rcx

    .end_loop:
mov rax, rdx
mov rbx, rcx
jmp .end

    .error:
mov rax, 1

    .end:
ret

; inputs
;  rax: the number to convert to a string
; outputs
;  rax: the length of the string
;  rbx: the string
;  rcx: the capacity
; side effects:
;  clobbers rdx, rsi, rdi, r10, r8, r9
to_string:
push rbp
mov rbp, rsp
sub rsp, 16

mov qword [rbp-8], rax
mov rax, 20
call alloc
mov rbx, rax
mov rax, qword [rbp-8]

xor rsi, rsi ; string length

    .length_loop:
xor rdx, rdx
mov rdi, 10
div rdi
add rsi, 1
cmp rax, 0
jne .length_loop

mov rcx, rsi ; index
mov rax, qword [rbp-8]
    .loop:
sub rcx, 1
xor rdx, rdx
mov rdi, 10
div rdi
add rdx, '0'
mov byte [rbx+rcx], dl
cmp rax, 0
jne .loop

mov rax, rsi

    .end:
mov rcx, 20

mov rsp, rbp
pop rbp
ret

; inputs
;  rax: length 1
;  rbx: string 1
;  rcx: capacity 1
;  rdx: length 2
;  rsi: string 2
; outputs
;  rax: length
;  rbx: string
;  rcx: capacity
; side effects:
;  clobbers rsi, rdi, rdx, r10, r8, r9
str_concat:
push rbp
mov rbp, rsp
sub rsp, 32
mov qword [rbp-8], rax
mov qword [rbp-16], rdx
mov qword [rbp-24], rsi

add rdx, rax
mov rax, rbx
mov rbx, rcx
mov rcx, rdx
call realloc
mov rbx, rax
add rax, qword [rbp-8]
mov rdx, qword [rbp-16]
mov rcx, qword [rbp-24]

    .copy_loop:
sub rdx, 1
jc .copy_end
mov sil, byte [rcx+rdx]
mov byte [rax+rdx], sil
jmp .copy_loop

    .copy_end:
mov rax, qword [rbp-8]
add rax, qword [rbp-16]
mov rcx, rax

mov rsp, rbp
pop rbp
ret

; inputs
;  rax: length
;  rbx: string
;  rcx: capacity
;  dl: character to append
; outputs
;  rax: length
;  rbx: string
;  rcx: capacity
; side effects:
;  clobbers rsi, rdi, rdx, r10, r8, r9
str_append:
push rbp
mov rbp, rsp
sub rsp, 8
mov byte [rbp-4], dl
mov rdx, 1
mov rsi, rbp
sub rsi, 4
call str_concat
mov rsp, rbp
pop rbp
ret

; inputs
;  rax: length
;  rbx: string
; outputs
;  rax: owned string
; side effects
;  clobbers rbx, rcx, rsi, rdi, rdx, r10, r8, r9
str_to_owned:
push rbp
mov rbp, rsp
sub rsp, 24
mov qword [rbp-8], rax
mov qword [rbp-16], rbx
call alloc
mov rbx, qword [rbp-8]
mov rcx, qword [rbp-16]

    .loop:
sub rbx, 1
jc .end
mov dl, byte [rcx+rbx]
mov byte [rax+rbx], dl
jmp .loop
    .end:
mov rsp, rbp
pop rbp
ret

; inputs
;  rax: length of string
;  rbx: string to split
;  cl: character to split on
; outputs
;  rax: number of parts
;  rbx: pointer to vector of parts. The vector contains string lengths and string pointers. The length of part i is
;       [rbx+i*16], and the string at part i is rbx+8+i*16.
; side effects
;  clobbers rcx, rsi, rdi, rdx, r10, r8, r9
str_split:
push rbp
mov rbp, rsp
sub rsp, 40
mov byte [rbp-24], cl
mov qword [rbp-8], rax
mov qword [rbp-16], rbx

mov rdx, 1 ; number of parts
xor rsi, rsi ; index

    .part_count_loop:
cmp rsi, rax
jge .part_count_end
cmp byte [rbx+rsi], cl
jne .part_count_inc
add rdx, 1
    .part_count_inc:
add rsi, 1
jmp .part_count_loop

    .part_count_end:
mov qword [rbp-32], rdx
mov rax, rdx
shl rax, 4
call alloc
mov rbx, rax

xor rdx, rdx ; vector index
xor rsi, rsi ; index
xor r10, r10 ; part start index
mov rax, qword [rbp-8] ; length
mov rdi, qword [rbp-16] ; string
mov cl, byte [rbp-24] ; split on

    .loop:
cmp rsi, rax
jge .loop_end
cmp byte [rdi+rsi], cl
jne .loop_inc
mov r9, rsi
sub r9, r10
mov qword [rbx+8*rdx], r9
add rdx, 1
mov r9, rdi
add r9, r10
mov qword [rbx+8*rdx], r9
add rdx, 1
mov r10, rsi
add r10, 1
    .loop_inc:
add rsi, 1
jmp .loop

    .loop_end:
sub rax, r10
mov qword [rbx+8*rdx], rax
add rdx, 1
add rdi, r10
mov qword [rbx+8*rdx], rdi

mov rax, qword [rbp-32]

mov rsp, rbp
pop rbp
ret

; inputs
;  rax: length 1
;  rbx: string 1
;  rcx: length 2
;  rdx: string 2
; outputs
;  rax: 1 if equal, 0 otherwise
; side effects
;  clobbers rcx
str_equal:
cmp rax, rcx
je .loop
xor rax, rax
jmp .end

    .loop:
sub rax, 1
jc .pass
mov cl, byte [rbx+rax]
cmp byte [rdx+rax], cl
je .loop

xor rax, rax
jmp .end

    .pass:
mov rax, 1

    .end:
ret

; inputs
;  rax: main string length
;  rbx: main string
;  rcx: sub string length
;  rdx: sub string
; outputs:
;  rax: 1 if main starts with sub, 0 otherwise
; side effects
;  clobbers rcx
str_starts_with:
cmp rcx, rax
jg .false
mov rax, rcx
call str_equal
jmp .end
    .false:
xor rax, rax
    .end:
ret

; inputs
;  rax: the null-terminated string
; outputs
;  rax: the length of the string, not including the null terminator
; side effects
;  clobbers rbx
c_str_length:
mov rbx, rax ; start pointer
jmp .loop_cond

    .loop:
add rax, 1
    .loop_cond:
cmp byte [rax], 0
jne .loop

sub rax, rbx
ret
