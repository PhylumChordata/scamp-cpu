# SCAMP bootloader
# The first 3 words from the disk device should be:
#  1. magic number (0x5343)
#  2. start address
#  3. length
# Once the given number of words have been loaded into memory at the
# given address, the address will be jumped to.
# Apart from the loaded code and the program counter, all machine state is
# undefined, including flags, contents of X, and all pseudo-registers including sp

.at 0

.def DISKDEV   1
.def SERIALDEV 2
.def STARTREG  r1
.def POINTREG  r2
.def LENGTHREG r3

# TODO: initialise serial device...

# 1. print hello
ld r0, welcome_s
call print

# 2. read magic from disk
.def MAGIC 0x5343
call inword
sub r0, MAGIC
jz read_startaddr

ld r0, wrongmagic_s
call print
jr- 1

# 3. read start address from disk
read_startaddr:
    call inword
    ld STARTREG, r0
    ld POINTREG, r0
    ld x, r0
    and x, 0xff00
    jnz read_length

    ld r0, startinrom_s
    call print
    jr- 1

# 4. read length from disk
read_length:
    call inword
    ld LENGTHREG, r0
    jnz read_data

    ld r0, zerolength_s
    call print
    jr- 1

# 5. read data from disk
read_data:
    call inword
    ld x, r0
    ld (POINTREG++), x
    dec LENGTHREG
    jnz read_data

ld r0, ok_s
call print

# 6. jump to the loaded code
jmp STARTREG

# print the nul-terminated string pointed to by r0
print:
    ld x, (r0++)
    test x
    jz printdone
    out SERIALDEV, x
    jmp print
    printdone:
    ret

# read the next 1 word from the disk device and return it in r0
# TODO: support a real disk device
inword:
    # high byte
    in x, DISKDEV
    shl3 x
    shl3 x
    shl2 x
    # low byte
    in r0, DISKDEV
    or r0, x
    ret

welcome_s:    .str "SCAMP boot...\r\n\0"
ok_s:         .str "OK\r\n\0"
wrongmagic_s: .str "Disk error: wrong magic\r\n\0"
startinrom_s: .str "Disk error: start address points to ROM\r\n\0"
zerolength_s: .str "Disk error: length is 0\r\n\0"
