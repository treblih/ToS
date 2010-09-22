/*
 * =====================================================================================
 *
 *       Filename:  kb.h
 *
 *    Description:  
 *
 *        Created:  22.09.10 16:45
 *       Revision:  none
 *       Compiler:  GCC 4.4
 *
 *         Author:  Yang Zhang, treblih.divad@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#ifndef KB_H
#define KB_H

#include <stdint.h>

/* Thx to Forrest Yu, January, 2004 */
/* Special keys */
#define ESC		0x101
#define TAB		0x102
#define ENTER		0x103
#define BACKSPACE	0x104

#define GUI_L		0x105
#define GUI_R		0x106
#define APPS		0x107

/* Shift, Ctrl, Alt */
#define SHIFT_L		0x108
#define SHIFT_R		0x109
#define CTRL_L		0x10A
#define CTRL_R		0x10B
#define ALT_L		0x10C
#define ALT_R		0x10D

/* Lock keys */
#define CAPS_LOCK	0x10E
#define	NUM_LOCK	0x10F
#define SCROLL_LOCK	0x110

/* Function keys */
#define F1		0x111
#define F2		0x112
#define F3		0x113
#define F4		0x114
#define F5		0x115
#define F6		0x116
#define F7		0x117
#define F8		0x118
#define F9		0x119
#define F10		0x11A
#define F11		0x11B
#define F12		0x11C

/* Control Pad */
#define PRINTSCREEN	0x11D
#define PAUSEBREAK	0x11E
#define INSERT		0x11F
#define DELETE		0x120
#define HOME		0x121
#define END		0x122
#define PAGEUP		0x123
#define PAGEDOWN	0x124
#define UP		0x125
#define DOWN		0x126
#define LEFT		0x127
#define RIGHT		0x128

/* ACPI keys */
#define POWER		0x129
#define SLEEP		0x12A
#define WAKE		0x12B

/* Num Pad */
#define PAD_SLASH	0x12C
#define PAD_STAR	0x12D
#define PAD_MINUS	0x12E
#define PAD_PLUS	0x12F
#define PAD_ENTER	0x130
#define PAD_DOT		0x131
#define PAD_0		0x132
#define PAD_1		0x133
#define PAD_2		0x134
#define PAD_3		0x135
#define PAD_4		0x136
#define PAD_5		0x137
#define PAD_6		0x138
#define PAD_7		0x139
#define PAD_8		0x13A
#define PAD_9		0x13B
#define PAD_UP		PAD_8			/* Up		*/
#define PAD_DOWN	PAD_2			/* Down		*/
#define PAD_LEFT	PAD_4			/* Left		*/
#define PAD_RIGHT	PAD_6			/* Right	*/
#define PAD_HOME	PAD_7			/* Home		*/
#define PAD_END		PAD_1			/* End		*/
#define PAD_PAGEUP	PAD_9			/* Page Up	*/
#define PAD_PAGEDOWN	PAD_3			/* Page Down	*/
#define INS		PAD_0			/* Ins		*/
#define MID		PAD_5			/* Middle key	*/
#define PAD_DEL		PAD_DOT			/* Del		*/

extern uint32_t __kb_buf_read();
extern ssize_t __get_kb_buf_cnt();
extern uint8_t __get_lock_key(int);
extern void __reverse_lock_key(int);
extern void __led_init();


#endif /* end of include guard: KB_H */
