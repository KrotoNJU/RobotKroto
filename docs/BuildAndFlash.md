# 编译与烧录指令集

> RobotKroto（FOC 电机 / 嵌入式项目）
> 工具链：WinLibs（gcc + cmake） + arm-none-eabi-gcc（交叉编译） + ST-Link（烧录/调试）
> 目标芯片：STM32G431RBT6（Cortex-M4F，128KB Flash / 32KB RAM）
> 最后更新：2026-09-18

---

## 1. 环境变量（PATH）配置 —— 需要手动配置

winget 装的 WinLibs 是**便携包，不会自动写入 PATH**。不配置的话，命令行里 `cmake`、新版 `gcc`、`arm-none-eabi-gcc` 都找不到，甚至会错误解析到旧的 `C:\Windows\MinGW\bin\gcc`（6.3.0）。

### 需要加入 PATH 的目录

| 工具 | 目录 |
|------|------|
| WinLibs（gcc 16 + cmake + mingw32-make + gdb） | `C:\Users\Administrator\AppData\Local\Microsoft\WinGet\Packages\BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin` |
| Arm 交叉编译器 | `C:\Program Files (x86)\Arm GNU Toolchain arm-none-eabi\14.2 rel1\bin` |

### 配置方法

**方法 1（推荐，GUI）**：`Win + R` 输入 `sysdm.cpl` → 「高级」→「环境变量」→ 用户变量 `Path` → 新建，粘贴上面两条 → 确定后**重开终端**。

**方法 2（命令行，快速）**：
```cmd
setx PATH "%PATH%;C:\Users\Administrator\AppData\Local\Microsoft\WinGet\Packages\BrechtSanders.WinLibs.POSIX.UCRT_Microsoft.Winget.Source_8wekyb3d8bbwe\mingw64\bin"
```
> ⚠️ `setx` 值超过 1024 字符会被截断，GUI 更安全。

### 验证（重开终端后）

```cmd
cmake --version          &:: 能打印版本即可
gcc --version            &:: 应显示 16.x，不是 6.3.0
arm-none-eabi-gcc --version
```

> 若 `gcc --version` 仍是 6.3.0，说明旧的 `C:\Windows\MinGW\bin` 排在前面挡住了，把 WinLibs 的目录挪到它前面，或从 PATH 里删掉旧 MinGW。

---

## 2. 编译（CMake）

### 2.1 工具链文件 `cmake/arm-none-eabi.cmake`

交叉编译需要它，内容如下（项目里放一份）：

```cmake
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER   arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_OBJCOPY      arm-none-eabi-objcopy)
set(CMAKE_SIZE         arm-none-eabi-size)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
```

MCU 相关的 `-mcpu` / `-mfloat-abi` / `-mfpu` 等标志写在 `CMakeLists.txt` 里（`add_compile_options` / `add_link_options`）。本项目 STM32G431（Cortex-M4F）用：

```
-mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
```

### 2.2 首次配置（生成 build 目录）

```cmd
cmake -B build -DCMAKE_TOOLCHAIN_FILE=cmake/arm-none-eabi.cmake -DCMAKE_BUILD_TYPE=Debug
```

### 2.3 编译（每次改完代码后）

```cmd
cmake --build build -j
```

产物在 `build/` 下：`firmware.elf`（调试用）/ `firmware.hex` / `firmware.bin`（烧录用，取决于 CMakeLists 里配置的 objcopy 规则）。

---

## 3. 烧录（ST-Link）

> 烧录需要再装一个下载工具，二选一即可。

### 3.1 STM32CubeProgrammer（官方，推荐）

从 ST 官网下载安装（安装时可勾选加入 PATH）：
https://www.st.com/en/development-tools/stm32cubeprog.html

安装后命令行：
```cmd
STM32_Programmer_CLI -c port=SWD -w build/firmware.hex -v -rst
```

参数说明：`-c port=SWD` 用 SWD 接口连接；`-w` 写入；`-v` 校验；`-rst` 烧完复位运行。

### 3.2 OpenOCD（免费开源）

用 MSYS2 安装：
```bash
pacman -S mingw-w64-ucrt-x86_64-openocd
```

烧录（STM32G4 用 `stm32g4x.cfg`）：
```cmd
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg ^
  -c "program build/firmware.elf verify reset exit"
```

常用 target 配置文件：`stm32f1x.cfg`、`stm32f3x.cfg`、`stm32f4x.cfg`、`stm32g4x.cfg`、`stm32h7x.cfg`。

---

## 4. 调试（可选）

```cmd
:: 终端 1：启动 gdb server
openocd -f interface/stlink.cfg -f target/stm32g4x.cfg

:: 终端 2：连接调试
arm-none-eabi-gdb build/firmware.elf -ex "target remote localhost:3333"
```

---

## 5. 产物格式

| 格式 | 用途 |
|------|------|
| `.elf` | 带符号，用于 gdb 调试 |
| `.hex` | Intel HEX，烧录常用 |
| `.bin` | 纯二进制，BOOTLOADER / IAP 常用 |
