.text 
.globl sum_array
.type sum_array, @function

# int sum_array(int *arr, long n)
# arr in rdi, n in rsi
# return in eax
sum_array:
    xorl %eax,%eax        # sum = 0
    xorq %rcx,%rcx        # i = 0

.Lloop:
    cmpq %rsi,%rcx        # compare i with n
    jge .Ldone             # if i >= n, exit loop

    addl (%rdi,%rcx,4), %eax  # sum += array[i]
    incq %rcx              # i++
    jmp .Lloop             # repeat loop

.Ldone:
    ret 