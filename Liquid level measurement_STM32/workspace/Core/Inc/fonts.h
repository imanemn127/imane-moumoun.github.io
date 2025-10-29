#ifndef __FONTS_H__
#define __FONTS_H__

#include <stdint.h>

typedef struct {
	uint8_t FontWidth;
	uint8_t FontHeight;
	const uint16_t *data;
} FontDef;

// Police par défaut : 7x10
extern FontDef Font_7x10;

#endif
