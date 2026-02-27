.section .data
p1:     .ascii "Enter first string: "
p1len = . - p1

p2:     .ascii "Enter second string: "
p2len = . - p2

out:    .ascii "Hamming Distance: "
outlen = . - out

nl:     .byte 10

.section .bss
.lcomm s1, 256
.lcomm s2, 256
.lcomm buffer, 20

.section .text
.global _start
_start:
    # Prompt 1
    mov $1, %rax
    mov $1, %rdi
    lea p1(%rip), %rsi
    mov $p1len, %rdx
    syscall

    # Read s1
    mov $0, %rax
    mov $0, %rdi
    lea s1(%rip), %rsi
    mov $255, %rdx
    syscall                    # rax = bytes read

    # Null-terminate s1
    lea s1(%rip), %r10
    test %rax, %rax
    jz prompt2

    mov %rax, %r8
    dec %r8
    movb (%r10,%r8,1), %al
    cmpb $10, %al
    jne s1_no_nl
    movb $0, (%r10,%r8,1)
    jmp prompt2
s1_no_nl:
    movb $0, (%r10,%rax,1)

prompt2:
    # Prompt 2
    mov $1, %rax
    mov $1, %rdi
    lea p2(%rip), %rsi
    mov $p2len, %rdx
    syscall

    # Read s2
    mov $0, %rax
    mov $0, %rdi
    lea s2(%rip), %rsi
    mov $255, %rdx
    syscall

    # Null-terminate s2
    lea s2(%rip), %r11
    test %rax, %rax
    jz compute

    mov %rax, %r8
    dec %r8
    movb (%r11,%r8,1), %al
    cmpb $10, %al
    jne s2_no_nl
    movb $0, (%r11,%r8,1)
    jmp compute
s2_no_nl:
    movb $0, (%r11,%rax,1)

compute:
    lea s1(%rip), %rsi
    lea s2(%rip), %rdi
    xor %r12, %r12             # total = 0  (R12 survives syscall)

char_loop:
    movb (%rsi), %al
    movb (%rdi), %bl

    test %al, %al
    jz done
    test %bl, %bl
    jz done

    xor %bl, %al               # differing bits

    mov $8, %rdx
bit_loop:
    test $1, %al
    jz skip_inc
    inc %r12
skip_inc:
    shr $1, %al
    dec %rdx
    jnz bit_loop

    inc %rsi
    inc %rdi
    jmp char_loop

done:
    # Print label
    mov $1, %rax
    mov $1, %rdi
    lea out(%rip), %rsi
    mov $outlen, %rdx
    syscall

    # Convert R12 to ASCII and print
    mov %r12, %rax
    lea buffer(%rip), %r8
    lea 19(%r8), %rsi          # end of buffer
    movb $0, (%rsi)

    test %rax, %rax
    jne convert
    dec %rsi
    movb $'0', (%rsi)
    jmp print_num

convert:
    mov $10, %rbx
convert_loop:
    xor %rdx, %rdx
    div %rbx                   # rax=quot, rdx=rem
    add $'0', %dl
    dec %rsi
    movb %dl, (%rsi)
    test %rax, %rax
    jnz convert_loop

print_num:
    mov $1, %rax
    mov $1, %rdi
    lea buffer(%rip), %r9
    lea 19(%r9), %rdx          # end
    sub %rsi, %rdx             # len
    syscall

    # newline
    mov $1, %rax
    mov $1, %rdi
    lea nl(%rip), %rsi
    mov $1, %rdx
    syscall

    # exit
    mov $60, %rax
    xor %rdi, %rdi
    syscall