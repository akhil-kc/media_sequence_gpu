#include <stdio.h>
#include <stdlib.h>
#include "dna.h"
#include "Stateinfo.h"
#include "MUtils.h"
#include <iostream>
using namespace std;
//#include "device.cu"
//define the chunk sizes that each threadblock will work on
#define BLKXSIZE 32
#define BLKYSIZE 4
#define BLKZSIZE 4

// for cuda error checking
#define cudaCheckErrors(msg) \
    do { \
        cudaError_t __err = cudaGetLastError(); \
        if (__err != cudaSuccess) { \
            fprintf(stderr, "Fatal error: %s (%s at %s:%d)\n", \
                msg, cudaGetErrorString(__err), \
                __FILE__, __LINE__); \
            fprintf(stderr, "*** FAILED - ABORTING\n"); \
            return 1; \
        } \
    } while (0)


int main(int argc, char *argv[])
{
    DNA *sequences=new DNA[3];
    int scores[4]={5,2,-5,-4},*d_scores,*d_allStates;
    int allStates[27]={111,112,113,121,122,123,131,132,133,211,212,213,221,222,223,231,232,233,311,312,313,321,322,323,331,332,333};
    sequences[0].read_file(argv[1]);
    sequences[1].read_file(argv[2]);
    sequences[2].read_file(argv[3]);
    DNA *d_sequences;
    const size_t sz = size_t(3) * sizeof(DNA);
    cudaMalloc((void**)&d_sequences,sz);
    cudaMemcpy(d_sequences, &sequences, sz, cudaMemcpyHostToDevice);
    printf("\n Sequence 1: %s \t Length: %d",sequences[0].seq_string,sequences[0].seq_length);
    printf("\n Sequence 2: %s \t Length: %d",sequences[1].seq_string,sequences[1].seq_length);
    printf("\n Sequence 3: %s \t Length: %d",sequences[2].seq_string,sequences[2].seq_length);
    const int nx = sequences[0].seq_length;
    const int ny = sequences[1].seq_length;
    const int nz = sequences[2].seq_length;
    const dim3 blockSize(BLKXSIZE, BLKYSIZE, BLKZSIZE);
    const dim3 gridSize(((nx+BLKXSIZE-1)/BLKXSIZE), ((ny+BLKYSIZE-1)/BLKYSIZE), ((nz+BLKZSIZE-1)/BLKZSIZE));

   unsigned size=nx*ny*nz;
// pointers for data set storage via malloc
    int *c; // storage for result stored on host
    int *d_c;  // storage for result computed on device
// allocate storage for data set
   if ((c = (int *)malloc((nx*ny*nz)*sizeof(int))) == 0) {fprintf(stderr,"malloc1 Fail \n"); return 1;}
// allocate GPU device buffers
    cudaMalloc((void **) &d_c, (nx*ny*nz)*sizeof(int));
    cudaMalloc((void **) &d_scores, 4*sizeof(int));
    cudaMalloc((void **) &d_allStates, 27*sizeof(int));
    cudaCheckErrors("Failed to allocate device buffer");
    cudaMemcpy(d_scores, &scores, (4*sizeof(int)), cudaMemcpyHostToDevice);
    cudaMemcpy(d_allStates, &allStates, (27*sizeof(int)), cudaMemcpyHostToDevice);
// compute result
	cudaTimer kernelTimer;
    kernelTimer.start();

    parallel_score<<<gridSize,blockSize>>>(d_sequences,d_c,size,d_scores,d_allStates);
    cudaCheckErrors("Kernel launch failure");
	 kernelTimer.stop();
	 double gcups = (sequences[0].seq_length * sequences[1].seq_length * sequences[2].seq_length)/(1e6 * kernelTimer.getElapsedTimeMillis());
	cout<<"\n Kernel Time:"<<kernelTimer.getElapsedTimeMillis()/1000<<"\n GCUPS:"<<gcups<<endl;
// copy output data back to host
	cout<<"After GPU Call";

    cudaMemcpy(c, d_c, ((nx*ny*nz)*sizeof(int)), cudaMemcpyDeviceToHost);
    cudaCheckErrors("CUDA memcpy failure");
	cout<<endl<<c[100]<<endl<<c[600]<<endl<<c[6000];
    printf("Results check!\n");
    free(c);
    cudaFree(d_c);
    cudaCheckErrors("cudaFree fail");
    return 0;
}
