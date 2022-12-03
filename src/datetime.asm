global day_in_month_and_hours_in_day
global seconds_since_epoch

section .text

; outputs
;  rax: seconds since epoch
; side effects
;  clobbers rcx, rdi
seconds_since_epoch:
mov rax, 201 ; time
xor rdi, rdi
syscall
ret

; inputs
;  rax: seconds since epoch
; outputs
;  rax: day in month (0-30)
;  rbx: hour in day (0-23)
; side effects:
;  clobbers rcx, rdx
day_in_month_and_hours_in_day:
xor rdx, rdx
mov rcx, 3600 ; seconds per hour
div rcx
xor rdx, rdx
mov rcx, 24 ; hours per day
div rcx
mov rbx, rdx
sub rax, 11017 ; days since epoch at 1st March 2000
mov rcx, 146097 ; days in 400 years
cqo
idiv rcx
cmp rdx, 0
jge .positive_modulus
add rdx, 146097 ; days in 400 years
    .positive_modulus:
mov rax, rdx
xor rdx, rdx
mov rcx, 36524 ; days in normal century
div rcx
cmp rax, 4
jne .non_fifth_century
mov rdx, 36524
    .non_fifth_century:
mov rax, rdx
xor rdx, rdx
mov rcx, 1461 ; days in 4 years (with leap year)
div rcx
mov rax, rdx
xor rdx, rdx
mov rcx, 365 ; days in non-leap year
div rcx
cmp rax, 4
jne .non_fifth_year
mov rdx, 365
    .non_fifth_year:
xor rax, rax
mov al, byte [day_in_month+rdx]
ret

section .data

day_in_month:
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ; March
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 ; April
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ; May
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 ; June
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ; July
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ; August
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 ; September
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ; October
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29 ; November
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ; December
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ; January
db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 ; February
