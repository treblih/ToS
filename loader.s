.code16
.text
# .org 0x100

    movw $0xb800, %ax
    movw %ax, %gs
    movb $0xf, %ah
    movb $67, %al
    movw %ax, %gs:((80 * 0 + 39) * 2)
    jmp .
