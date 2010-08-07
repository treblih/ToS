.code16
.text
.org 0x100

    movw $0xb800, %ax
    movw %ax, %gs
    movb $0xf, %ah
    movb $67, %al
    movw 80(%gs), %ax
    jmp .
