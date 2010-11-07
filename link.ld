ENTRY(_start)
SECTIONS
{
    .text 0x100100 :
    {
        text = .; _text = .; __text = .;
        *(.text)
    }

    .data :
    {
        . = ALIGN(4096);
        data = .; _data = .; __data = .;
        *(.data)
        *(.rodata)
    }

    .bss :
    {
        . = ALIGN(4096);
        bss = .; _bss = .; __bss = .;
        *(.bss)
    }

    end = .; _end = .; __end = .;
}
