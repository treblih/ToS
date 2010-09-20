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

#include <stdint.h>

/* void kb_read(TTY * p_tty) */
void __kb_buf_decode()
{
	/* scan_code -> keycol -> keyval */
	uint8_t scan_code;		
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
					caps_lock = !caps_lock;
					init_led();
				}
				break;
			case NUM_LOCK:
				if (make) {
					num_lock = !num_lock;
					init_led();
				}
				break;
			case SCROLL_LOCK:
				if (make) {
					scroll_lock = !scroll_lock;
					init_led();
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
