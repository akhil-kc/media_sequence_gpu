#include <stdio.h>
#include <stdlib.h>
#include "dna.h"
#include "device.h"
#include "MUtils.h"
#include <iostream>
using namespace std;
//#include "device.cu"
//define the chunk sizes that each threadblock will work on
#define DATAXSIZE 671
#define DATAYSIZE 671
#define DATAZSIZE 671

#define BLKXSIZE 4
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
    typedef int nRarray[DATAYSIZE][DATAXSIZE];
    DNA sequence1,sequence2,sequence3;
    int scores[4]={5,2,-5,-4},*d_scores,*d_allStates;
    int allStates[27]={111,112,113,121,122,123,131,132,133,211,212,213,221,222,223,231,232,233,311,312,313,321,322,323,331,332,333};
    sequence1.read_file(argv[1]);
    sequence2.read_file(argv[2]);
    sequence3.read_file(argv[3]);
    char *d_sequence1,*d_sequence2,*d_sequence3;


    printf("\n Sequence 1: %s \t Length: %d",sequence1.seq_string,sequence1.seq_length);
    printf("\n Sequence 2: %s \t Length: %d",sequence2.seq_string,sequence2.seq_length);
    printf("\n Sequence 3: %s \t Length: %d",sequence3.seq_string,sequence3.seq_length);
    const int nx = sequence1.seq_length;
    const int ny = sequence2.seq_length;
    const int nz = sequence3.seq_length;
    const dim3 blockSize(BLKXSIZE, BLKYSIZE, BLKZSIZE);
    const dim3 gridSize(((nx+BLKXSIZE-1)/BLKXSIZE), ((ny+BLKYSIZE-1)/BLKYSIZE), ((nz+BLKZSIZE-1)/BLKZSIZE));

   unsigned size=nx*ny*nz;
    nRarray *c; // storage for result stored on host
    nRarray *d_c;  // storage for result computed on device
// allocate storage for data set
   if ((c = (nRarray *)malloc((nx*ny*nz)*sizeof(int))) == 0) {fprintf(stderr,"malloc1 Fail \n"); return 1;}
// allocate GPU device buffers
   cudaMalloc((void **) &d_sequence1, (nx)*sizeof(char));	
   cudaCheckErrors("Failed to allocate device buffer");
   cudaMemcpy(d_sequence1, &sequence1.seq_string, (nx)*sizeof(char), cudaMemcpyHostToDevice);
   cudaCheckErrors("Failed to copy device buffer");
	
   cudaMalloc((void **) &d_sequence2, (ny)*sizeof(char));
   cudaCheckErrors("Failed to allocate device buffer");
   cudaMemcpy(d_sequence2, &sequence2.seq_string, (ny)*sizeof(char), cudaMemcpyHostToDevice);
   cudaCheckErrors("Failed to copy device buffer");

   cudaMalloc((void **) &d_sequence3, (nz)*sizeof(char));
   cudaCheckErrors("Failed to allocate device buffer");
   cudaMemcpy(d_sequence3, &sequence3.seq_string, (nz)*sizeof(char), cudaMemcpyHostToDevice);
   cudaCheckErrors("Failed to copy device buffer");

    cudaMalloc((void **) &d_c, (nx*ny*nz)*sizeof(int));
    cudaCheckErrors("Failed to allocate device buffer");
    cudaMalloc((void **) &d_scores, 4*sizeof(int));
    cudaCheckErrors("Failed to allocate device buffer");
    cudaMalloc((void **) &d_allStates, 27*sizeof(int));
    cudaCheckErrors("Failed to allocate device buffer");
    cudaMemcpy(d_scores, &scores, (4*sizeof(int)), cudaMemcpyHostToDevice);
    cudaCheckErrors("Failed to copy device buffer");
    cudaMemcpy(d_allStates, &allStates, (27*sizeof(int)), cudaMemcpyHostToDevice);
    cudaCheckErrors("Failed to copy device buffer");
// compute result
    cudaTimer kernelTimer;
    kernelTimer.start();
    parallel_score<<<gridSize, blockSize>>>(d_sequence1,d_sequence2,d_sequence3,nx,ny,nz,d_c,size,d_scores,d_allStates);
    cudaCheckErrors("Kernel launch failure");
    cudaDeviceSynchronize();
    //parallel_score<<<gridSize, blockSize>>>(d_c,size,d_scores,d_allStates);
    kernelTimer.stop();
    double gcups = (sequence1.seq_length * sequence2.seq_length * sequence3.seq_length)/(1e9 * kernelTimer.getElapsedTimeMillis());
    cout<<"\n Kernel Time:"<<kernelTimer.getElapsedTimeMillis()/1000<<"\n GCUPS:"<<gcups<<endl;

    cudaMemcpy(c, d_c, ((nx*ny*nz)*sizeof(int)), cudaMemcpyDeviceToHost);
    cudaCheckErrors("CUDA memcpy failure");

    free(c);
    cudaFree(d_c);
    cudaFree(d_scores);
    cudaFree(d_allStates);
    cudaCheckErrors("cudaFree fail");
    return 0;
}
