#ifndef __SSD1306_H__
#define __SSD1306_H__

#include "stm32f3xx_hal.h"
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "fonts.h"

// Définir la largeur et la hauteur de l'écran OLED
#define SSD1306_WIDTH 128
#define SSD1306_HEIGHT 64

// Adresse I2C du SSD1306 (0x3C ou 0x3D typiquement)
#define SSD1306_I2C_ADDR 0x78

// Déclaration de l'I2C utilisé
extern I2C_HandleTypeDef hi2c1;

// Structure de gestion de l'écran
typedef struct {
	uint8_t CurrentX;
	uint8_t CurrentY;
	uint8_t Inverted;
	uint8_t Initialized;
} SSD1306_t;

// Prototypes
uint8_t SSD1306_Init(void);
void SSD1306_Fill(uint8_t color);
void SSD1306_UpdateScreen(void);
void SSD1306_DrawPixel(uint8_t x, uint8_t y, uint8_t color);
char SSD1306_Putc(char ch, FontDef Font, uint8_t color);
char SSD1306_Puts(char* str, FontDef Font, uint8_t color);
void SSD1306_GotoXY(uint8_t x, uint8_t y);
void SSD1306_Clear(void);

#endif
