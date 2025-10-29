#ifndef __SYSTEM_STM32F3XX_H
#define __SYSTEM_STM32F3XX_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

/* Exported types ------------------------------------------------------------*/
/* Exported constants --------------------------------------------------------*/
#define HSE_VALUE    ((uint32_t)8000000) /*!< Value of the External oscillator in Hz */
#define HSI_VALUE    ((uint32_t)8000000) /*!< Value of the Internal oscillator in Hz */

/* Exported macro ------------------------------------------------------------*/
/* Exported functions ------------------------------------------------------- */

extern uint32_t SystemCoreClock;          /*!< System Clock Frequency (Core Clock) */
extern const uint8_t AHBPrescTable[16];   /*!< AHB prescaler table */
extern const uint8_t APBPrescTable[8];    /*!< APB prescaler table */

void SystemInit(void);
void SystemCoreClockUpdate(void);

#ifdef __cplusplus
}
#endif

#endif /* __SYSTEM_STM32F3XX_H */
