SECTIONS
{
  . = 0x500;
  .text :
  {
    _ftext = .;     /* Program will be loaded to 0x7c00. */
  } = 0
}
