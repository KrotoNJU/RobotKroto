# ============================================================================
#  RK_sw/Drivers —— STM32G431xx 驱动库（HAL + CMSIS），按外设分文件夹
#
#  分层：
#    CMSIS/     ARM CMSIS 内核头 + STM32G4 器件头（纯头文件）
#    Include/   HAL/LL 全量头 + Legacy（共享接口层）
#    startup/   启动文件 + 链接脚本（单独拎出来）
#    System/    系统级 HAL（hal/rcc/flash/pwr/cortex/system_stm32g4xx）
#    GPIO/ DMA/ EXTI/ ADC/ FDCAN/ I2C/ OPAMP/ SPI/ TIM/ UART/  各外设 HAL 源
#
#  本文件只产出静态库 drivers，并把启动文件/链接脚本路径暴露给上层。
# ============================================================================

cmake_minimum_required(VERSION 3.22)

set(DRV_ROOT ${CMAKE_CURRENT_SOURCE_DIR})

# ----------------------------------------------------------------------------
# 源文件（按外设分组）
# ----------------------------------------------------------------------------
set(DRV_SYSTEM_SRC
    ${DRV_ROOT}/System/stm32g4xx_hal.c
    ${DRV_ROOT}/System/stm32g4xx_hal_rcc.c
    ${DRV_ROOT}/System/stm32g4xx_hal_rcc_ex.c
    ${DRV_ROOT}/System/stm32g4xx_hal_flash.c
    ${DRV_ROOT}/System/stm32g4xx_hal_flash_ex.c
    ${DRV_ROOT}/System/stm32g4xx_hal_flash_ramfunc.c
    ${DRV_ROOT}/System/stm32g4xx_hal_pwr.c
    ${DRV_ROOT}/System/stm32g4xx_hal_pwr_ex.c
    ${DRV_ROOT}/System/stm32g4xx_hal_cortex.c
    ${DRV_ROOT}/System/system_stm32g4xx.c
)

set(DRV_GPIO_SRC
    ${DRV_ROOT}/GPIO/stm32g4xx_hal_gpio.c
)

set(DRV_DMA_SRC
    ${DRV_ROOT}/DMA/stm32g4xx_hal_dma.c
    ${DRV_ROOT}/DMA/stm32g4xx_hal_dma_ex.c
)

set(DRV_EXTI_SRC
    ${DRV_ROOT}/EXTI/stm32g4xx_hal_exti.c
)

set(DRV_ADC_SRC
    ${DRV_ROOT}/ADC/stm32g4xx_hal_adc.c
    ${DRV_ROOT}/ADC/stm32g4xx_hal_adc_ex.c
    ${DRV_ROOT}/ADC/stm32g4xx_ll_adc.c
)

set(DRV_FDCAN_SRC
    ${DRV_ROOT}/FDCAN/stm32g4xx_hal_fdcan.c
)

set(DRV_I2C_SRC
    ${DRV_ROOT}/I2C/stm32g4xx_hal_i2c.c
    ${DRV_ROOT}/I2C/stm32g4xx_hal_i2c_ex.c
)

set(DRV_OPAMP_SRC
    ${DRV_ROOT}/OPAMP/stm32g4xx_hal_opamp.c
    ${DRV_ROOT}/OPAMP/stm32g4xx_hal_opamp_ex.c
)

set(DRV_SPI_SRC
    ${DRV_ROOT}/SPI/stm32g4xx_hal_spi.c
    ${DRV_ROOT}/SPI/stm32g4xx_hal_spi_ex.c
)

set(DRV_TIM_SRC
    ${DRV_ROOT}/TIM/stm32g4xx_hal_tim.c
    ${DRV_ROOT}/TIM/stm32g4xx_hal_tim_ex.c
)

set(DRV_UART_SRC
    ${DRV_ROOT}/UART/stm32g4xx_hal_uart.c
    ${DRV_ROOT}/UART/stm32g4xx_hal_uart_ex.c
)

# ----------------------------------------------------------------------------
# 头文件路径（PUBLIC：链接 drivers 的目标自动获得）
# ----------------------------------------------------------------------------
set(DRV_INC_DIRS
    ${DRV_ROOT}/Include                 # HAL/LL 全量头
    ${DRV_ROOT}/Include/Legacy          # stm32_hal_legacy.h
    ${DRV_ROOT}/CMSIS/Core              # core_cm4.h / cmsis_*.h
    ${DRV_ROOT}/CMSIS/Device            # stm32g4xx.h / stm32g431xx.h / system_stm32g4xx.h
    ${DRV_ROOT}/../Core/Inc             # stm32g4xx_hal_conf.h（CubeMX 配置，在 Core 层）
)

# ----------------------------------------------------------------------------
# 静态库
# ----------------------------------------------------------------------------
add_library(drivers STATIC
    ${DRV_SYSTEM_SRC}
    ${DRV_GPIO_SRC}
    ${DRV_DMA_SRC}
    ${DRV_EXTI_SRC}
    ${DRV_ADC_SRC}
    ${DRV_FDCAN_SRC}
    ${DRV_I2C_SRC}
    ${DRV_OPAMP_SRC}
    ${DRV_SPI_SRC}
    ${DRV_TIM_SRC}
    ${DRV_UART_SRC}
)

target_include_directories(drivers PUBLIC ${DRV_INC_DIRS})
target_compile_definitions(drivers PUBLIC USE_HAL_DRIVER STM32G431xx)

# STM32G431 = Cortex-M4F（硬浮点）
target_compile_options(drivers PUBLIC
    -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)

# 把启动文件 / 链接脚本路径暴露给上层
set(STARTUP_FILE  ${DRV_ROOT}/startup/startup_stm32g431xx.s PARENT_SCOPE)
set(LINKER_SCRIPT ${DRV_ROOT}/startup/STM32G431xx_FLASH.ld PARENT_SCOPE)
