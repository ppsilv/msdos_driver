# Compilador e flags
ASM := nasm
ASMFLAGS := -f bin

# Arquivos de origem e saída
SOURCE := driver.asm
OUTPUT := driver.sys
FLOPPY_IMG := floppy.img

# Alvo principal
all: $(FLOPPY_IMG)

# Regra para compilar driver.sys
$(OUTPUT): $(SOURCE)
	@echo "Compilando $<..."
	$(ASM) $(ASMFLAGS) -o $@ $<

# Regra para criar a imagem de disquete
$(FLOPPY_IMG): boot.bin kernel.bin config.sys $(OUTPUT)
	@echo "Criando imagem de disquete..."
	dd if=/dev/zero of=$@ bs=512 count=2880 status=none
	dd if=boot.bin of=$@ bs=512 conv=notrunc status=none
	dd if=kernel.bin of=$@ bs=512 seek=1 conv=notrunc status=none
	dd if=config.sys of=$@ bs=512 seek=2 conv=notrunc status=none
	dd if=$(OUTPUT) of=$@ bs=512 seek=3 conv=notrunc status=none
	@echo "Imagem criada: $@"

# Limpeza
clean:
	rm -f $(OUTPUT) $(FLOPPY_IMG) boot.bin kernel.bin

# Executar no QEMU
run:
	#qemu-system-i386 -fda $<
	qemu-system-i386 -drive file=flpy0001.img,format=raw,if=floppy,index=0 -drive file=virtual_disk.img,format=raw,if=ide,index=0,media=disk -boot order=a -machine pc,acpi=off

copy:
	mcopy -i flpy0001.img driver.sys ::/

.PHONY: all clean run
