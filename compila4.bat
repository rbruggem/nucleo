gcc -Iinclude -Iutente/include -c utente/utente.cpp -o utente/uten_cpp.o -fno-exceptions

gcc -Iinclude -Iutente/include -c utente/lib.cpp -o utente/lib.o -fno-exceptions

make build/utente

