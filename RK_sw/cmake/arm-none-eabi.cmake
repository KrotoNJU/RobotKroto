# ARM 交叉编译工具链文件（bare-metal，STM32G431）
# 用法：
#   cmake -S . -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE=cmake/arm-none-eabi.cmake
#   cmake --build build

set(CMAKE_SYSTEM_NAME Generic)      # 无操作系统，避免 CMake 加 Windows/主机链接标志
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER   arm-none-eabi-gcc)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY      arm-none-eabi-objcopy)
set(CMAKE_SIZE         arm-none-eabi-size)

# 交叉编译时用静态库做编译器探测，而不是链接宿主机可执行文件
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
