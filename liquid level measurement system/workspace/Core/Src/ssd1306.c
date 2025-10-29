#include "ssd1306.h"

uint8_t SSD1306_Buffer[SSD1306_WIDTH * SSD1306_HEIGHT / 8];
static SSD1306_t SSD1306;

void SSD1306_WriteCommand(uint8_t command) {
    uint8_t buffer[2] = {0x00, command};
    HAL_I2C_Master_Transmit(&hi2c1, SSD1306_I2C_ADDR, buffer, 2, HAL_MAX_DELAY);
}

uint8_t SSD1306_Init(void) {
	HAL_Delay(100);

	uint8_t init_sequence[] = {
		0xAE, // Display off
		0x20, 0x00, // Memory addressing mode = Horizontal
		0xB0, // Page Start Address
		0xC8, // COM Output Scan Direction
		0x00, // low column addr
		0x10, // high column addr
		0x40, // start line addr
		0x81, 0x7F, // contrast
		0xA1, // segment remap
		0xA6, // normal display
		0xA8, 0x3F, // multiplex ratio
		0xA4, // display follows RAM
		0xD3, 0x00, // display offset
		0xD5, 0x80, // display clock divide ratio
		0xD9, 0xF1, // pre-charge
		0xDA, 0x12, // COM pins
		0xDB, 0x40, // VCOMH
		0x8D, 0x14, // charge pump
		0xAF // Display on

	};

	SSD1306_WriteCommand(0x21); // Set column address
	SSD1306_WriteCommand(0x00); // Column start address = 0
	SSD1306_WriteCommand(0x7F); // Column end address = 127

	SSD1306_WriteCommand(0x22); // Set page address
	SSD1306_WriteCommand(0x00); // Page start address = 0
	SSD1306_WriteCommand(0x07); // Page end address = 7

	SSD1306_WriteCommand(0x00); // Set lower column address
	SSD1306_WriteCommand(0x10); // Set higher column address


	for (uint8_t i = 0; i < sizeof(init_sequence); i++) {
		uint8_t d[2] = {0x00, init_sequence[i]};
		HAL_I2C_Master_Transmit(&hi2c1, SSD1306_I2C_ADDR, d, 2, HAL_MAX_DELAY);
	}

	SSD1306_Fill(0);
	SSD1306_UpdateScreen();

	SSD1306.CurrentX = 0;
	SSD1306.CurrentY = 0;
	SSD1306.Initialized = 1;

	return 1;
}

void SSD1306_UpdateScreen(void) {
    for (uint8_t page = 0; page < 8; page++) {
        // Commande pour définir la page (ceci est correct)
        SSD1306_WriteCommand(0xB0 + page);

        /*
         * AJOUT POUR COMPATIBILITÉ SH1106
         * On spécifie que l'écriture pour cette page doit commencer à la colonne 2.
         * La commande pour le SH1106 est de définir le quartet bas PUIS le quartet haut
         * de l'adresse de la colonne.
         *
         * Colonne 2: Quartet haut = 0, Quartet bas = 2.
         * Commande quartet haut : 0x10 | 0 = 0x10
         * Commande quartet bas  : 0x00 | 2 = 0x02
        */
        SSD1306_WriteCommand(0x02); // Quartet bas de l'adresse de colonne (colonne 2)
        SSD1306_WriteCommand(0x10); // Quartet haut de l'adresse de colonne (0)


        // Envoie les 128 colonnes de la page
        uint8_t data[129];
        data[0] = 0x40; // Control byte pour indiquer un flux de données
        // Copie des données du buffer local
        for (uint8_t col = 0; col < 128; col++) {
            data[col + 1] = SSD1306_Buffer[col + page * 128];
        }
        HAL_I2C_Master_Transmit(&hi2c1, SSD1306_I2C_ADDR, data, 129, HAL_MAX_DELAY);
    }
}


void SSD1306_Fill(uint8_t color) {
	memset(SSD1306_Buffer, (color ? 0xFF : 0x00), sizeof(SSD1306_Buffer));
}

void SSD1306_DrawPixel(uint8_t x, uint8_t y, uint8_t color) {

    if (x >= SSD1306_WIDTH || y >= SSD1306_HEIGHT) return;

    if (color) {
        SSD1306_Buffer[x + (y / 8) * SSD1306_WIDTH] |=  (1 << (y % 8));
    } else {
        SSD1306_Buffer[x + (y / 8) * SSD1306_WIDTH] &= ~(1 << (y % 8));
    }
}


void SSD1306_GotoXY(uint8_t x, uint8_t y) {
	SSD1306.CurrentX = x;
	SSD1306.CurrentY = y;
}

char SSD1306_Putc(char ch, FontDef Font, uint8_t color) {
    // Vérification que le caractère est dans la plage gérée (32-126)
    if (ch < ' ' || ch > '~') return 0;

    // Calcul de la position du caractère dans les données de la police
    // L'offset est (code ASCII - 32) * nombre de lignes par caractère
    int base = (ch - ' ') * Font.FontHeight;

    // Boucle sur chaque ligne (hauteur) du caractère
    for (uint8_t i = 0; i < Font.FontHeight; i++) {
        // Récupère les données de la ligne
        uint16_t line = Font.data[base + i];

        // Boucle sur chaque pixel (largeur) de la ligne
        for (uint8_t j = 0; j < Font.FontWidth; j++) {
            // Teste le bit correspondant au pixel de gauche à droite
            if ((line << j) & 0x8000) { // CORRECTION : Teste le bit le plus à gauche (MSB)
                SSD1306_DrawPixel(SSD1306.CurrentX + j, SSD1306.CurrentY + i, color);
            } else {
                SSD1306_DrawPixel(SSD1306.CurrentX + j, SSD1306.CurrentY + i, !color);
            }
        }
    }

    // Met à jour la position du curseur pour le prochain caractère
    SSD1306.CurrentX += Font.FontWidth;
    return ch;
}


char SSD1306_Puts(char* str, FontDef Font, uint8_t color) {
    while (*str) {
        if (SSD1306_Putc(*str, Font, color) != *str) {
            // En cas d’erreur de dessin
            return *str;
        }
        str++;
    }
    return *str;
}

void SSD1306_Clear(void) {
	SSD1306_Fill(0);
	SSD1306_UpdateScreen();
}
