SRC_DIR = src
OBJ_DIR = obj
CC     = nvcc
CFLAGS = -O3 -gencode=arch=compute_20,code=compute_20

all: clean main 

main: median_string.o dna.o MUtils.o device.o stateTransition.o
	$(CC) $(CFLAGS) $(OBJ_DIR)/median_string.o $(OBJ_DIR)/dna.o $(OBJ_DIR)/device.o $(OBJ_DIR)/MUtils.o  $(OBJ_DIR)/stateTransition.o -o median

median_string.o: $(SRC_DIR)/median_string.cu
	$(CC) $(CFLAGS) -c $(SRC_DIR)/median_string.cu -o $(OBJ_DIR)/median_string.o
dna.o: $(SRC_DIR)/dna.cpp
	$(CC) $(CFLAGS) -c $(SRC_DIR)/dna.cpp -o $(OBJ_DIR)/dna.o
device.o: $(SRC_DIR)/device.cu
	 $(CC) $(CFLAGS) -c $(SRC_DIR)/device.cu -o $(OBJ_DIR)/device.o
MUtils.o: $(SRC_DIR)/MUtils.cu
	$(CC) $(CFLAGS) -c $(SRC_DIR)/MUtils.cu -o $(OBJ_DIR)/MUtils.o
stateTransition.o: $(SRC_DIR)/stateTransition.cpp
	$(CC) $(CFLAGS) -c $(SRC_DIR)/stateTransition.cpp -o $(OBJ_DIR)/stateTransition.o
clean:
	rm -f $(OBJ_DIR)/*.o
	rm -f *median
