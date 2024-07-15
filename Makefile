PROJECT?=main

SRCDIRECTORY=src
PREFIX = arm-none-eabi

LIBOPENCM3_PATH := ./deps/libopencm3
BUILD_DIR ?= build

SOURCE_FILES = $(wildcard $(SRCDIRECTORY)/*.c)
OBJFILES = $(patsubst $(SRCDIRECTORY)/%.c, $(BUILD_DIR)/%.o, $(SOURCE_FILES))
GENRATED_FILES += $(OBJFILES) $(patsubst $(BUILD_DIR)/%.o, $(BUILD_DIR)/%.d, $(OBJFILES))


# FREERTOS stuff
FREERTOS_PATH := ./deps/freertos_kernel
FREERTOS_PORT_PATH := $(FREERTOS_PATH)/portable/GCC/ARM_CM4F
FREERTOS_SOURCES :=  $(FREERTOS_PATH)/tasks.c \
					$(FREERTOS_PATH)/queue.c \
					$(FREERTOS_PATH)/list.c \
					$(FREERTOS_PATH)/timers.c \
					$(FREERTOS_PATH)/event_groups.c \
					$(FREERTOS_PATH)/portable/MemMang/heap_4.c \
					$(FREERTOS_PORT_PATH)/port.c

FREERTOS_OBJS :=  $(BUILD_DIR)/tasks.o \
					$(BUILD_DIR)/queue.o \
					$(BUILD_DIR)/list.o \
					$(BUILD_DIR)/timers.o \
					$(BUILD_DIR)/event_groups.o \
					$(BUILD_DIR)/heap_4.o \
					$(BUILD_DIR)/port.o
					

FREERTOS_INCLUDE := -I$(FREERTOS_PATH)/include -I$(FREERTOS_PORT_PATH)

all: folder_setup $(BUILD_DIR)/$(PROJECT).elf


freertos_objs: $(FREERTOS_SOURCES)
	$(PREFIX)-gcc -Os -ggdb3 -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 \
	-fno-common -ffunction-sections -fdata-sections -Wextra -Wshadow -Wno-unused-variable \
	-Wimplicit-function-declaration -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes \
	-MD -Wall -Wundef $(FREERTOS_INCLUDE) -c $(FREERTOS_SOURCES)
	mv *.o *.d $(BUILD_DIR)



# building all the object files
$(BUILD_DIR)/%.o: $(SRCDIRECTORY)/%.c 
	$(PREFIX)-gcc -Os -ggdb3 -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 \
	-fno-common -ffunction-sections -fdata-sections -Wextra -Wshadow -Wno-unused-variable \
	-Wimplicit-function-declaration -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes \
	-MD -Wall -Wundef -I$(LIBOPENCM3_PATH)/include $(FREERTOS_INCLUDE) -DSTM32F4 -DSTM32F446RE -o $@ -c $<


# linking with libopencm3
$(BUILD_DIR)/$(PROJECT).elf: $(OBJFILES) freertos_objs
	$(PREFIX)-gcc -Tstm32f446re.ld -L$(LIBOPENCM3_PATH)/lib -nostartfiles -mcpu=cortex-m4 \
	-mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16 -specs=nano.specs -Wl,--gc-sections -Wl,--cref \
	-Wl,-Map=$(BUILD_DIR)/$(PROJECT).map -L../libopencm3/lib $(FREERTOS_OBJS) $(OBJFILES) \
	-lopencm3_stm32f4 -Wl,--start-group \
	-lc -lgcc -lnosys -Wl,--end-group -o $@
	$(PREFIX)-objcopy -Obinary $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).bin

GENRATED_FILES += $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).map $(FREERTOS_OBJS) $(patsubst $(BUILD_DIR)/%.o, $(BUILD_DIR)/%.d, $(FREERTOS_OBJS)) $(BUILD_DIR)/$(PROJECT).bin

folder_setup:
	mkdir -p build

upload: all
	st-flash --reset write $(BUILD_DIR)/$(PROJECT).bin 0x08000000

clean:
	rm -f $(GENRATED_FILES)