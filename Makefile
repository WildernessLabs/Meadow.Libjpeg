TOOLCHAIN_PREFIX := arm-none-eabi-
CXX := $(TOOLCHAIN_PREFIX)g++
CC := $(TOOLCHAIN_PREFIX)gcc
AR := $(TOOLCHAIN_PREFIX)ar
LD := $(TOOLCHAIN_PREFIX)ld
OBJDUMP := $(TOOLCHAIN_PREFIX)objdump
ARFLAGS := -r

GENDIR := gen
OBJDIR := $(GENDIR)/obj
BINDIR := $(GENDIR)/bin

MEADOW := ../Meadow

LIBJPEG := $(GENDIR)/jpeg.a

OPTIMIZATION_LEVEL := -O3

CC_WARNINGS := \
  	-Wall \
	-Wextra \
	-Wno-shadow \
	-Wno-vla \
	-Wno-strict-aliasing \
	-Wno-type-limits \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-Wno-write-strings \
	-Wno-sign-compare \
	-Wunused-function \
	-Wno-unused-value \
	-Werror=return-type \
	-Wl,--no-undefined \

PLATFORM_FLAGS := \
	-fmessage-length=0 \
	-fno-exceptions \
	-fno-unwind-tables \
	-funsigned-char \
	-fno-delete-null-pointer-checks \
	-fomit-frame-pointer \
	-MMD \
	-mcpu=cortex-m7 \
	-mabi=aapcs \
	-mthumb \
	-mfpu=fpv5-d16 \
	-mfloat-abi=hard \

COMMON_FLAGS := \
	$(PLATFORM_FLAGS) \
	$(OPTIMIZATION_LEVEL) \
	$(CC_WARNINGS) \
	-fPIC \
	-fPIE

CCFLAGS := \
	$(COMMON_FLAGS) \
	-g \
	-v \
	-nostartfiles \

INCLUDES_NUTTX := \
	-I. \
	-I $(MEADOW)/nuttx/include \
	-I $(MEADOW)/nuttx/include/sys/ \
	-I $(MEADOW)/nuttx/include/arch/ \
	-I $(MEADOW)/nuttx/arch/ \
	-I $(MEADOW)/nuttx/arpa/ \
	-I $(MEADOW)/nuttx/cxx/ \
	-I $(MEADOW)/nuttx/net/ \
	-I $(MEADOW)/nuttx/netinet/ \
	-I $(MEADOW)/nuttx/netpacket/ \
	-I $(MEADOW)/nuttx/sched/ \
	-I $(MEADOW)/nuttx/libs/libc/ \
	-I $(MEADOW)/nuttx/libs/libcxx/ \
	-I $(MEADOW)/nuttx/include/nuttx/lib/ \

LIBS := \
  -L../Meadow/nuttx/staging \
   --start-group \
  -lproxies \
  -luc \
  -lumm \
  -luarch \
  -lxx \
  -lapps \
  $(MEADOW)/aot-support/libbuiltin.a \
  --end-group

SRC := libjpeg

CSRCS := $(SRC)/jaricom.c $(SRC)/jcomapi.c $(SRC)/jdapimin.c $(SRC)/jdapistd.c \
         $(SRC)/jdarith.c $(SRC)/jdatasrc.c $(SRC)/jdcoefct.c $(SRC)/jdcolor.c \
         $(SRC)/jddctmgr.c $(SRC)/jdhuff.c $(SRC)/jdinput.c $(SRC)/jdmainct.c \
         $(SRC)/jdmarker.c $(SRC)/jdmaster.c $(SRC)/jdmerge.c $(SRC)/jdpostct.c \
         $(SRC)/jdsample.c $(SRC)/jdtrans.c $(SRC)/jerror.c $(SRC)/jidctflt.c \
         $(SRC)/jidctfst.c $(SRC)/jidctint.c $(SRC)/jquant1.c $(SRC)/jquant2.c \
         $(SRC)/jutils.c $(SRC)/jmemmgr.c $(SRC)/jmemname.c

OBJS := $(patsubst $(SRC)/%.c,$(OBJDIR)/%.o,$(CSRCS))

$(OBJDIR)/%.o: $(SRC)/%.c
	@mkdir -p $(@D)
	$(CC) $(CCFLAGS) $(INCLUDES_NUTTX) -c $< -o $@

$(LIBJPEG): $(OBJS)
	@mkdir -p $(dir $@)
	$(AR) $(ARFLAGS) $@ $(OBJS)
	$(LD) -Map $(GENDIR)/jpeg.map -Bsymbolic -G -Bdynamic -o $(GENDIR)/jpeg.so $(OBJS) $(LIBS)
	$(OBJDUMP) -d -S -C $(GENDIR)/jpeg.so > $(GENDIR)/jpeg.disassembly

libjpeg: $(LIBJPEG)

clean: 
	rm -rf $(GENDIR)
