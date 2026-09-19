# ============================================================================
#  RK_sw/FreeRTOS —— FreeRTOS 内核 + CMSIS-RTOS V2 中间件静态库
#
#  分层：
#    Source/         内核源文件（tasks/queue/…）
#    include/        内核头文件
#    CMSIS_RTOS_V2/  CMSIS-RTOS V2 封装（cmsis_os2.c）
#    portable/       移植层（GCC/ARM_CM4F 的 port + MemMang/heap_4）
#
#  FreeRTOSConfig.h 在 ../Core/Inc（CubeMX 配置），CMSIS 头在 ../Drivers/CMSIS。
# ============================================================================

cmake_minimum_required(VERSION 3.22)

set(FRTOS_ROOT ${CMAKE_CURRENT_SOURCE_DIR})

set(FREERTOS_SRC
    ${FRTOS_ROOT}/Source/croutine.c
    ${FRTOS_ROOT}/Source/event_groups.c
    ${FRTOS_ROOT}/Source/list.c
    ${FRTOS_ROOT}/Source/queue.c
    ${FRTOS_ROOT}/Source/stream_buffer.c
    ${FRTOS_ROOT}/Source/tasks.c
    ${FRTOS_ROOT}/Source/timers.c
    ${FRTOS_ROOT}/portable/GCC/ARM_CM4F/port.c
    ${FRTOS_ROOT}/portable/MemMang/heap_4.c
    ${FRTOS_ROOT}/CMSIS_RTOS_V2/cmsis_os2.c
)

add_library(freertos STATIC ${FREERTOS_SRC})

target_include_directories(freertos PUBLIC
    ${FRTOS_ROOT}/include
    ${FRTOS_ROOT}/portable/GCC/ARM_CM4F
    ${FRTOS_ROOT}/CMSIS_RTOS_V2
    ${FRTOS_ROOT}/../Core/Inc                       # FreeRTOSConfig.h
    ${FRTOS_ROOT}/../Drivers/CMSIS/Core             # cmsis_compiler.h / core_cm4.h
    ${FRTOS_ROOT}/../Drivers/CMSIS/Device           # stm32g4xx.h（CMSIS_device_header）
)

# STM32G431xx 让 stm32g4xx.h 分派到 stm32g431xx.h
target_compile_definitions(freertos PUBLIC STM32G431xx)

# STM32G431 = Cortex-M4F（硬浮点）
target_compile_options(freertos PUBLIC
    -mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard
)
