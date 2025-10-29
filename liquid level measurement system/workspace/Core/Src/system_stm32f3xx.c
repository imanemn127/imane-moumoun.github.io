#include "stm32f3xx.h"
#include "system_stm32f3xx.h"

/* Global variable to hold the system core clock frequency */
uint32_t SystemCoreClock = 8000000;

/* These are used by HAL internally */
const uint8_t AHBPrescTable[16] = {
  0, 0, 0, 0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13
};

const uint8_t APBPrescTable[8] = {
  0, 0, 0, 0, 1, 2, 3, 4
};

/**
  * @brief  Setup the microcontroller system.
  *         Initialize the FPU, Reset the RCC configuration, configure HSI as system clock source.
  * @retval None
  */
void SystemInit(void)
{
  /* FPU settings ------------------------------------------------------------*/
#if (__FPU_PRESENT == 1) && (__FPU_USED == 1)
  SCB->CPACR |= ((3UL << 10 * 2) | (3UL << 11 * 2));  // set CP10 and CP11 full access
#endif

  /* Reset the RCC clock configuration to default reset state ------------*/
  RCC->CR |= RCC_CR_HSION;

  RCC->CFGR = 0x00000000;
  RCC->CR &= (uint32_t)0xFEF6FFFF;
  RCC->CR &= (uint32_t)0xFFFBFFFF;
  RCC->CR &= (uint32_t)0xFFFDFFFF;
  RCC->CFGR = 0x00000000;
  RCC->CIR = 0x00000000;

  /* Configure Vector Table location */
#ifdef VECT_TAB_SRAM
  SCB->VTOR = SRAM_BASE;
#else
  SCB->VTOR = FLASH_BASE;
#endif
}

/**
  * @brief  Update SystemCoreClock variable according to current clock settings.
  * @retval None
  */
void SystemCoreClockUpdate(void)
{
  // Simple default implementation (HSI = 8 MHz)
  SystemCoreClock = HSI_VALUE;
}
