cmake_minimum_required(VERSION 3.22)
project(RK_sw C ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# STM32G431 = Cortex-M4F（硬浮点）
set(CPU_FLAGS -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard)
set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS} ${CPU_FLAGS} -ffunction-sections -fdata-sections")
set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} ${CPU_FLAGS}")

# 驱动库（HAL + CMSIS，按外设分）—— 返回 STARTUP_FILE / LINKER_SCRIPT
add_subdirectory(Drivers)

# FreeRTOS 内核 + CMSIS-RTOS V2
add_subdirectory(FreeRTOS)

# 应用：main.c（最外层） + Core 配置层（CubeMX 生成的外设配置/中断/MSP/时基）
add_executable(${PROJECT_NAME}
    main.c
    Core/Src/gpio.c
    Core/Src/dma.c
    Core/Src/adc.c
    Core/Src/fdcan.c
    Core/Src/i2c.c
    Core/Src/opamp.c
    Core/Src/spi.c
    Core/Src/tim.c
    Core/Src/usart.c
    Core/Src/stm32g4xx_it.c
    Core/Src/stm32g4xx_hal_msp.c
    Core/Src/stm32g4xx_hal_timebase_tim.c
    Core/Src/app_freertos.c
    Core/Src/sysmem.c
    Core/Src/syscalls.c
    ${STARTUP_FILE}                    # startup_stm32g431xx.s（引导文件，必须有）
)

target_include_directories(${PROJECT_NAME} PRIVATE
    Core/Inc                           # main.h / 外设头 / stm32g4xx_it.h / FreeRTOSConfig.h
)

target_link_libraries(${PROJECT_NAME} PRIVATE
    drivers
    freertos
    m
)

target_link_options(${PROJECT_NAME} PRIVATE
    ${CPU_FLAGS}
    -T${LINKER_SCRIPT}                 # STM32G431xx_FLASH.ld
    -Wl,--gc-sections
    --specs=nano.specs                 # syscalls.c/sysmem.c 提供 newlib 系统调用
)

# 构建后生成 .bin / .hex，打印占用，并输出成功提示
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.bin
    COMMAND ${CMAKE_OBJCOPY} -O ihex   $<TARGET_FILE:${PROJECT_NAME}> ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${PROJECT_NAME}>
    COMMAND ${CMAKE_COMMAND} -E echo "=== BUILD SUCCESS: ${PROJECT_NAME} ==="
    COMMENT "Generating ${PROJECT_NAME}.bin and ${PROJECT_NAME}.hex"
)
