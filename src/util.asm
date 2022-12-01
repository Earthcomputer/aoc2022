extern _end

global alloc
global free
global input
global print
global realloc

section .text

; inputs
;  rax: length of string
;  rbx: the string
; side effects
;  clobbers rax, rcx, rdx, rsi, rdi
print:
mov rdx, rax
mov rsi, rbx
mov rax, 1 ; write
mov rdi, 1 ; stdout
syscall
ret

; outputs
;  rax: the length of the result
;  rbx: the result
; side effects:
;  clobbers rcx, rsi, rdi, rdx, r10, r8, r9
input:
mov rax, 256
call alloc
mov rsi, rax
xor eax, eax ; read
xor edi, edi ; stdin
mov edx, 256
syscall
mov rbx, rsi
cmp rax, 0
je input_end
cmp byte [rbx+rax-1], 10
jne input_end
sub rax, 1

    input_end:
ret

; inputs
;  rax: the pointer to realloc
;  rbx: the current size of the allocation
;  rcx: the size to reallocate to
; outputs
;  rax: the address of the allocation
; side effects:
;  clobbers rcx, rsi, rdi, rdx, r10, r8, r9
realloc:
push rbp
mov rbp, rsp
sub rsp, 24

cmp rbx, rcx
jge realloc_end

mov qword [rbp-8], rax
mov qword [rbp-16], rbx
mov rax, rcx
call alloc
mov rcx, qword [rbp-8]
mov rbx, qword [rbp-16]

    realloc_copy_loop:
sub rbx, 1
jc realloc_copy_end
mov dl, byte [rcx+rbx]
mov byte [rax+rbx], dl
jmp realloc_copy_loop

    realloc_copy_end:
mov qword [rbp-8], rax
mov rax, rcx
mov rbx, qword [rbp-16]
call free
mov rax, qword [rbp-8]

    realloc_end:
mov rsp, rbp
pop rbp
ret

; inputs
;  rax: the number of bytes to allocate
; outputs:
;  rax: the address of the allocation
; side effects:
;  clobbers rcx, rsi, rdi, rdx, r10, r8, r9
alloc:
add rax, 0hfff
and rax, 0hfffffffffffff000
mov rsi, rax
mov rax, 9 ; mmap
xor rdi, rdi
mov rdx, 3 ; PROT_READ | PROT_WRITE
mov r10, 34 ; MAP_PRIVATE | MAP_ANONYMOUS
mov r8, -1
xor r9, r9
syscall
cmp rax, -1
jne alloc_end
mov rax, 19
mov rbx, alloc_failure_msg
call print
call _end
    alloc_end:
ret

; inputs
;  rax: the address to free
;  rbx: the number of bytes to free
; side effects
;  clobbers rax, rbx, rcx, rdi, rsi
free:
add rbx, 0hfff
and rbx, 0hfffffffffffff000
mov rdi, rax
mov rsi, rbx
mov rax, 11 ; munmap
syscall
cmp rax, 0
je free_end
mov rax, 21
mov rbx, free_failure_msg
call print
call _end
    free_end:
ret

section .data

alloc_failure_msg:
db "Allocation failure", 10

free_failure_msg:
db "Deallocation failure", 10
