START_SISTEMA=   0x00100000
START_IO=        0x40000000
START_UTENTE=	 0x80000000
SWAP=		 :0/2

CXXFLAGS=-fno-exceptions -fno-rtti -g -fcall-saved-edi -fcall-saved-esi -fcall-saved-ebx
CPPFLAGS=-DWIN -nostdinc -Iinclude -g

all: build/sistema \
     build/parse.exe   \
     build/creatimg.exe
     
build/sistema: sistema/sist_s.o sistema/sist_cpp.o
	ld -nostdlib -o build/sistema -Ttext $(START_SISTEMA) sistema/sist_s.o sistema/sist_cpp.o

build/io: io/io_s.o io/io_cpp.o
	ld -nostdlib -o build/io -Ttext $(START_IO) io/io_s.o io/io_cpp.o

build/utente: utente/uten_s.o utente/lib.o utente/uten_cpp.o
	ld -nostdlib -o build/utente -Ttext $(START_UTENTE) utente/uten_cpp.o utente/uten_s.o utente/lib.o


# compilazione di sistema.s e sistema.cpp
sistema/sist_s.o: sistema/sistema.S include/costanti.h
	gcc $(CPPFLAGS) -c sistema/sistema.S -o sistema/sist_s.o

sistema/sist_cpp.o: sistema/sistema.cpp include/mboot.h include/costanti.h
	gxx $(CPPFLAGS) $(CXXFLAGS) -c sistema/sistema.cpp -o sistema/sist_cpp.o

# compilazione di io.s e io.cpp
io/io_s.o: io/io.S include/costanti.h
	gcc $(CPPFLAGS) -c io/io.S -o io/io_s.o

io/io_cpp.o: io/io.cpp include/costanti.h
	gxx $(CPPFLAGS) $(CXXFLAGS) -c io/io.cpp -o io/io_cpp.o

# compilazione di utente.s e utente.cpp
utente/uten_s.o: utente/utente.s
	gcc $(CPPFLAGS) -c utente/utente.s -o utente/uten_s.o

utente/utente.cpp: build/parse.exe utente/prog/*.in utente/include/*.h utente/prog
	build/parse -o utente/utente.cpp utente/prog/*.in

utente/uten_cpp.o: utente/utente.cpp
	gxx $(CXXFLAGS) $(CPPFLAGS) -Iutente/include -c utente/utente.cpp -o utente/uten_cpp.o

utente/lib.o: utente/lib.cpp utente/include/lib.h
	gxx $(CXXFLAGS) $(CPPFLAGS) -Iutente/include -c utente/lib.cpp -o utente/lib.o

# creazione di parse e creatimg
build/parse.exe: util/parse.c util/src.h
	gcc -DWIN -o build/parse.exe util/parse.c

util/coff.o: include/costanti.h util/interp.h util/coff.h util/dos.h util/coff.cpp
	gxx -DWIN -c -g -Iinclude -o util/coff.o util/coff.cpp

util/elf.o:  include/costanti.h util/interp.h util/elf.h util/elf.cpp
	gxx -DWIN -c -g -Iinclude -o util/elf.o util/elf.cpp

util/interp.o: include/costanti.h util/interp.h util/interp.cpp
	gxx -DWIN -c -g -Iinclude -o util/interp.o util/interp.cpp

util/swap.o: include/costanti.h util/swap.h util/swap.cpp
	gxx -DWIN -c -g -Iinclude -o util/swap.o util/swap.cpp

util/fswap.o: include/costanti.h util/swap.h util/fswap.cpp
	gxx -DWIN -c -g -Iinclude -o util/fswap.o util/fswap.cpp

util/doswap.o: include/costanti.h util/swap.h util/doswap.cpp
	gxx -DWIN -c -g -Iinclude -o util/doswap.o util/doswap.cpp

util/creatimg.o: util/interp.h util/swap.h util/creatimg.cpp
	gxx -DWIN -c -g -Iinclude -o util/creatimg.o util/creatimg.cpp

build/creatimg.exe: util/creatimg.o util/elf.o util/coff.o util/interp.o util/swap.o util/fswap.o util/doswap.o
	gxx -DWIN -g -o build/creatimg.exe util/creatimg.o util/elf.o util/coff.o util/interp.o util/swap.o util/fswap.o util/doswap.o

.PHONY: swap
swap: build/creatimg.exe build/io build/utente
	build\creatimg $(SWAP) build\io build\utente
	

clean:
	del sistema\*.o
	del io\*.o
	del utente\*.o 
	del util\*.o

reset: clean
	del build\*
