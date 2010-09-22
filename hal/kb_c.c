/*
 * =====================================================================================
 *
 *       Filename:  kb_c.c
 *
 *    Description:  
 *
 *        Created:  19.09.10
 *       Revision:  
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include <kb.h>

static uint32_t alt_l;
static uint32_t alt_r;
static uint32_t ctrl_l;
static uint32_t ctrl_r;
static uint32_t shift_l;
static uint32_t shift_r;

/* Thx to Forrest Yu, January, 2004 */
static uint32_t keymap[0x80 * 3] = {
/* scan-code			!shift		shift		e0 	*/
/* ==================================================================== */
/* 0x00 - none		*/	0,		0,		0,
/* 0x01 - ESC		*/	ESC,		ESC,		0,
/* 0x02 - '1'		*/	'1',		'!',		0,
/* 0x03 - '2'		*/	'2',		'@',		0,
/* 0x04 - '3'		*/	'3',		'#',		0,
/* 0x05 - '4'		*/	'4',		'$',		0,
/* 0x06 - '5'		*/	'5',		'%',		0,
/* 0x07 - '6'		*/	'6',		'^',		0,
/* 0x08 - '7'		*/	'7',		'&',		0,
/* 0x09 - '8'		*/	'8',		'*',		0,
/* 0x0A - '9'		*/	'9',		'(',		0,
/* 0x0B - '0'		*/	'0',		')',		0,
/* 0x0C - '-'		*/	'-',		'_',		0,
/* 0x0D - '='		*/	'=',		'+',		0,
/* 0x0E - BS		*/	'\b',	        '\b',	        0,
/* 0x0F - TAB		*/	TAB,		TAB,		0,
/* 0x10 - 'q'		*/	'q',		'Q',		0,
/* 0x11 - 'w'		*/	'w',		'W',		0,
/* 0x12 - 'e'		*/	'e',		'E',		0,
/* 0x13 - 'r'		*/	'r',		'R',		0,
/* 0x14 - 't'		*/	't',		'T',		0,
/* 0x15 - 'y'		*/	'y',		'Y',		0,
/* 0x16 - 'u'		*/	'u',		'U',		0,
/* 0x17 - 'i'		*/	'i',		'I',		0,
/* 0x18 - 'o'		*/	'o',		'O',		0,
/* 0x19 - 'p'		*/	'p',		'P',		0,
/* 0x1A - '['		*/	'[',		'{',		0,
/* 0x1B - ']'		*/	']',		'}',		0,
/* 0x1C - CR/LF		*/	'\n',		'\n',		'\n',
/* 0x1D - l. Ctrl	*/	CTRL_L,		CTRL_L,		CTRL_R,
/* 0x1E - 'a'		*/	'a',		'A',		0,
/* 0x1F - 's'		*/	's',		'S',		0,
/* 0x20 - 'd'		*/	'd',		'D',		0,
/* 0x21 - 'f'		*/	'f',		'F',		0,
/* 0x22 - 'g'		*/	'g',		'G',		0,
/* 0x23 - 'h'		*/	'h',		'H',		0,
/* 0x24 - 'j'		*/	'j',		'J',		0,
/* 0x25 - 'k'		*/	'k',		'K',		0,
/* 0x26 - 'l'		*/	'l',		'L',		0,
/* 0x27 - ';'		*/	';',		':',		0,
/* 0x28 - '\''		*/	'\'',		'"',		0,
/* 0x29 - '`'		*/	'`',		'~',		0,
/* 0x2A - l. SHIFT	*/	SHIFT_L,	SHIFT_L,	0,
/* 0x2B - '\'		*/	'\\',		'|',		0,
/* 0x2C - 'z'		*/	'z',		'Z',		0,
/* 0x2D - 'x'		*/	'x',		'X',		0,
/* 0x2E - 'c'		*/	'c',		'C',		0,
/* 0x2F - 'v'		*/	'v',		'V',		0,
/* 0x30 - 'b'		*/	'b',		'B',		0,
/* 0x31 - 'n'		*/	'n',		'N',		0,
/* 0x32 - 'm'		*/	'm',		'M',		0,
/* 0x33 - ','		*/	',',		'<',		0,
/* 0x34 - '.'		*/	'.',		'>',		0,
/* 0x35 - '/'		*/	'/',		'?',		'/',
/* 0x36 - r. SHIFT	*/	SHIFT_R,	SHIFT_R,	0,
/* 0x37 - '*'		*/	'*',		'*',    	0,
/* 0x38 - ALT		*/	ALT_L,		ALT_L,  	ALT_R,
/* 0x39 - ' '		*/	' ',		' ',		0,
/* 0x3A - CapsLock	*/	CAPS_LOCK,	CAPS_LOCK,	0,
/* 0x3B - F1		*/	F1,		F1,		0,
/* 0x3C - F2		*/	F2,		F2,		0,
/* 0x3D - F3		*/	F3,		F3,		0,
/* 0x3E - F4		*/	F4,		F4,		0,
/* 0x3F - F5		*/	F5,		F5,		0,
/* 0x40 - F6		*/	F6,		F6,		0,
/* 0x41 - F7		*/	F7,		F7,		0,
/* 0x42 - F8		*/	F8,		F8,		0,
/* 0x43 - F9		*/	F9,		F9,		0,
/* 0x44 - F10		*/	F10,		F10,		0,
/* 0x45 - NumLock	*/	NUM_LOCK,	NUM_LOCK,	0,
/* 0x46 - ScrLock	*/	SCROLL_LOCK,	SCROLL_LOCK,	0,
/* 0x47 - Home		*/	HOME,	        '7',		HOME,
/* 0x48 - CurUp		*/	UP,		'8',		UP,
/* 0x49 - PgUp		*/	PAGEUP,	        '9',		PAGEUP,
/* 0x4A - '-'		*/	'-',	        '-',		0,
/* 0x4B - Left		*/	LEFT,	        '4',		LEFT,
/* 0x4C - MID		*/	MID,	        '5',		0,
/* 0x4D - Right		*/	RIGHT,	        '6',		RIGHT,
/* 0x4E - '+'		*/	'+',	        '+',		0,
/* 0x4F - End		*/	END,	        '1',		END,
/* 0x50 - Down		*/	DOWN,	        '2',		DOWN,
/* 0x51 - PgDown	*/	PAGEDOWN,	'3',		PAGEDOWN,
/* 0x52 - Insert	*/	INS,	        '0',		INSERT,
/* 0x53 - Delete	*/	'.',	        '.',		DELETE,
/* 0x54 - Enter		*/	0,		0,		0,
/* 0x55 - ???		*/	0,		0,		0,
/* 0x56 - ???		*/	0,		0,		0,
/* 0x57 - F11		*/	F11,		F11,		0,
/* 0x58 - F12		*/	F12,		F12,		0,
/* 0x59 - ???		*/	0,		0,		0,
/* 0x5A - ???		*/	0,		0,		0,
/* 0x5B - ???		*/	0,		0,		GUI_L,
/* 0x5C - ???		*/	0,		0,		GUI_R,
/* 0x5D - ???		*/	0,		0,		APPS,
/* 0x5E - ???		*/	0,		0,		0,
/* 0x5F - ???		*/	0,		0,		0,
/* 0x60 - ???		*/	0,		0,		0,
/* 0x61 - ???		*/	0,		0,		0,
/* 0x62 - ???		*/	0,		0,		0,
/* 0x63 - ???		*/	0,		0,		0,
/* 0x64 - ???		*/	0,		0,		0,
/* 0x65 - ???		*/	0,		0,		0,
/* 0x66 - ???		*/	0,		0,		0,
/* 0x67 - ???		*/	0,		0,		0,
/* 0x68 - ???		*/	0,		0,		0,
/* 0x69 - ???		*/	0,		0,		0,
/* 0x6A - ???		*/	0,		0,		0,
/* 0x6B - ???		*/	0,		0,		0,
/* 0x6C - ???		*/	0,		0,		0,
/* 0x6D - ???		*/	0,		0,		0,
/* 0x6E - ???		*/	0,		0,		0,
/* 0x6F - ???		*/	0,		0,		0,
/* 0x70 - ???		*/	0,		0,		0,
/* 0x71 - ???		*/	0,		0,		0,
/* 0x72 - ???		*/	0,		0,		0,
/* 0x73 - ???		*/	0,		0,		0,
/* 0x74 - ???		*/	0,		0,		0,
/* 0x75 - ???		*/	0,		0,		0,
/* 0x76 - ???		*/	0,		0,		0,
/* 0x77 - ???		*/	0,		0,		0,
/* 0x78 - ???		*/	0,		0,		0,
/* 0x78 - ???		*/	0,		0,		0,
/* 0x7A - ???		*/	0,		0,		0,
/* 0x7B - ???		*/	0,		0,		0,
/* 0x7C - ???		*/	0,		0,		0,
/* 0x7D - ???		*/	0,		0,		0,
/* 0x7E - ???		*/	0,		0,		0,
/* 0x7F - ???		*/	0,		0,		0
};

/* void kb_read(TTY * p_tty) */
void __kb_buf_decode()
{
	/* scan_code -> keycol -> keyval */
	uint8_t scan_code;		
	uint8_t num_lock = __get_lock_key(NUM_LOCK);
	uint32_t keyval = 0;
	uint32_t *keycol;
	int code_with_e0 = 0;
	int column = 0;
	int make;

	/*
	 * if there is anything in buf, we do next.
	 * so the read_keyboard_buf() below need no judge count, diff with write_tty()
	 */
	if (__get_kb_buf_cnt()) {		
		scan_code = __kb_buf_read();
		if (scan_code == 0xe0) {
			scan_code = __kb_buf_read();
			/* print screen press */
			if (scan_code == 0x2a) {
				if (__kb_buf_read() == 0xe0) {
					if (__kb_buf_read() == 0x37) {
						keyval = PRINTSCREEN;
						make = 1;
					}
				}
			}
			/* print screen release */
			if (scan_code == 0xB7) {
				if (__kb_buf_read() == 0xE0) {
					if (__kb_buf_read() == 0xAA) {
						keyval = PRINTSCREEN;
						make = 0;
					}
				}
			}
			/* not print screen, it's one starts with e0 */
			if (keyval == 0) {
				code_with_e0 = 1;
			}
		} else if (scan_code == 0xe1) {
			uint8_t pausebrk_scode[] =
			    { 0xe1, 0x1d, 0x45, 0xe1, 0x9d, 0xc5 };
			int is_pausebreak = 1;
			for (int i = 1; i < 6; i++) {
				if (__kb_buf_read() != pausebrk_scode[i]) {
					is_pausebreak = 0;
					break;
				}
			}
			if (is_pausebreak) {
				keyval = PAUSEBREAK;
			}
		}
		/* there's no else */

		if ((keyval != PAUSEBREAK) && (keyval != PRINTSCREEN)) {
			/* make is for ctrl/break code judge */
			make = (scan_code & 0x80) ? 0 : 1;
			/* care about the line num */
			keycol = &keymap[(scan_code & 0x7f) * 3];

			if (shift_l || shift_r) {
				column = 1;
			}
			if (code_with_e0) {
				column = 2;
				code_with_e0 = 0;
			}
			if ((scan_code >= 0x47 && scan_code <= 0x53)
			    && ((column == 0) && num_lock)) {
				column = 1;
			}

			keyval = keycol[column];

			/* judge for ctrl key */
			switch (keyval) {
			case SHIFT_L:
				shift_l = make;
				break;
			case SHIFT_R:
				shift_r = make;
				break;
			case CTRL_L:
				ctrl_l = make;
				break;
			case CTRL_R:
				ctrl_r = make;
				break;
			case ALT_L:
				alt_l = make;
				break;
			case ALT_R:
				alt_r = make;
				break;

			/* if it's make code, change it */
			case CAPS_LOCK:
				if (make) {
					__reverse_lock_key(CAPS_LOCK);
					__led_init();
				}
				break;
			case NUM_LOCK:
				if (make) {
					__reverse_lock_key(NUM_LOCK);
					__led_init();
				}
				break;
			case SCROLL_LOCK:
				if (make) {
					__reverse_lock_key(SCROLL_LOCK);
					__led_init();
				}
				break;
			case UP:
				/* scroll_screen(p_tty->p_console, SCROLL_UP); */
				break;
			case DOWN:
				/* scroll_screen(p_tty->p_console, SCROLL_DOWN); */
				break;
			case F1:
			case F2:
			case F3:
			case F4:
				//  if (alt_l || alt_r) {
				/* select_tty(tty_table + (keyval - F1)); */
				break;
				// }
			case 'l':
				if (ctrl_l || ctrl_r) {
					/* clean_screen(p_tty->p_console); */
				}
				break;
			default:
				if (make) {
					/* kbuf_to_tbuf(keyval, p_tty); */
				}
				break;
			}
		}
	}
}
