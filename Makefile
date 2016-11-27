CC     = nvcc
CFLAGS = -O3 -gencode=arch=compute_20,code=compute_20

all: clean main 

main: median_string.o dna.o MUtils.o device.o
	$(CC) $(CFLAGS) median_string.o dna.o device.o MUtils.o -o median

median_string.o: median_string.cu
	$(CC) $(CFLAGS) -c median_string.cu -o median_string.o

dna.o: dna.cpp
	$(CC) $(CFLAGS) -c dna.cpp -o dna.o
device.o: device.cu
	 $(CC) $(CFLAGS) -c device.cu -o device.o
MUtils.o: MUtils.cu
	$(CC) $(CFLAGS) -c MUtils.cu -o MUtils.o
clean:
	rm -f *.o
