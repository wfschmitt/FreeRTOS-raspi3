CROSS ?= aarch64-elf
CFLAGS =  -mcpu=cortex-a53 -fpic -ffreestanding -std=gnu99 -O2 -Wall -Wextra -I$(INCLUDEPATH1) -I$(INCLUDEPATH2) -I$(INCLUDEPATH3)
ASMFLAGS = -mcpu=cortex-a53

INCLUDEPATH1 ?= FreeRTOS/Source/include
INCLUDEPATH2 ?= FreeRTOS/Source/portable/GCC/ARM_CA53_64_RaspberryPi3
INCLUDEPATH3 ?= Demo

OBJS = build/startup.o 
OBJS +=build/main.o

OBJS +=build/port.o

OBJS +=build/list.o
OBJS +=build/tasks.o

OBJS +=build/heap_1.o

kernel8.elf : raspberrypi3.ld $(OBJS)
	$(CROSS)-gcc -T raspberrypi3.ld -o $@ -ffreestanding -O2 -nostdlib $(OBJS)
	$(CROSS)-objdump -D kernel8.elf > kernel8.list

build/%.o : Demo/%.S
	$(CROSS)-as $(ASMFLAGS) -c -o $@ $<
	
build/%.o : Demo/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

build/%.o : FreeRTOS/Source/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

build/%.o : FreeRTOS/Source/portable/GCC/ARM_CA53_64_RaspberryPi3/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

build/%.o : FreeRTOS/Source/portable/MemMang/%.c
	$(CROSS)-gcc $(CFLAGS)  -c -o $@ $<

clean :
	rm -f build/*.o
	rm -f *.elf
	rm -f *.list

run :
	$(MAKE) kernel8.elf
	qemu-system-aarch64 -M raspi3 -m 128 -serial null -serial mon:stdio -nographic -kernel kernel8.elf

runasm :
	$(MAKE) kernel8.elf
	qemu-system-aarch64 -M raspi3 -m 128 -serial null -serial mon:stdio -nographic -kernel kernel8.elf -d in_asm


