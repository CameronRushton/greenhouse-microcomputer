
/* Performs the initialization of the LCD device
 */
void LCD2PP_init ( void );


/* Writes an INSTRUCTION to the LCD
 * @param instruction	 A command to the LCD device. See Text and Notes
 * 		  				 for legal commands. eg. Set address of cursor.
 */
void LCD_instruction ( char instruction );

/* Writes a DATA character to the LCD
 * @param data 	 ASCII character to be displayed
 */	 
void LCD_display ( char data );

/* Writes an array of DATA characters to the LCD
 * @param str	   A pointer to a null-terminated sequence of ASCII characters.
 */
void LCD_displayStr (char *str);

