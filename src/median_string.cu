#include <stdio.h>
#include <stdlib.h>
#include "dna.h"
#include "device.h"
#include "MUtils.h"
#include "stateTransition.h"
#include <iostream>
#include <getopt.h>
using namespace std;
//#include "device.cu"
//define the chunk sizes that each threadblock will work on
#define DATAXSIZE 671
#define DATAYSIZE 671
#define DATAZSIZE 671

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

static struct option options[] = {
    {"sequence1", required_argument, 0, 'a'},
    {"sequence2", required_argument, 0, 'b'},
    {"sequence3", required_argument, 0, 'c'},
    {"match", required_argument, 0, 'm'},
    {"insertion", required_argument, 0, 'i'},
    {"deletion", required_argument, 0, 'd'},
    {"mismatch", required_argument, 0, 'n'},
    {"help", no_argument, 0, 'h'},
    {0, 0, 0, 0}
};

static void help() {
    printf(
    "Usage: ./median -a <sequence 1> -b <sequence 2> -c <sequence 3> [Arguments ...]\n"
    "\n"
    "Arguments:\n"
    "\t -a, --sequence1 <file> (required)\n"
    "\t\t Input Sequence 1 FASTA format\n"
    "\t -b, --sequence2 <file> (required)\n"
    "\t\t Input Sequence 2 FASTA format\n"
    "\t -c, --sequence3 <file> (required)\n"
    "\t\t Input Sequence 3 FASTA format\n"
    "\t -m, --match <int> (default : 5)\n"
    "\t\t Match score, should be a positive integer \n"
    "\t -n, --mismatch <int> (default : -10)\n"
    "\t\t Mismatch score, should be a negative integer \n"
    "\t -d, --deletion <int> (default : -5)\n"
    "\t\t Deletion score, should be a negative integer \n"
    "\t -i, --insertion <int> (default : -4)\n"
    "\t\t Insertion score, should be a negative integer \n"
    "\t -h, -help\n"
    "\t\t prints out the help\n");
}

int main(int argc, char *argv[])
{
    CUDAcard gpu;
    typedef int nRarray[DATAYSIZE][DATAXSIZE];
    char *seq1_path=NULL;
    char *seq2_path=NULL;
    char *seq3_path=NULL;
    DNA sequence1,sequence2,sequence3;
    int scores[4]={5,-10,-5,-4},*d_scores,*d_allStates;
    //1 represents Match, 2 represents Insert, 3 represents Delete
    int allStates[27]={111,222,113,223,221,131,232,212,133,211,213,231,233,311,122,311,313,121,123,321,323,331,112,132,312,332,333};

    if (argc<3){
	help();
	return 0;
     }

     while (1) {
        char argument = getopt_long(argc, argv, "a:b:c:m:n:d:i:h", options, NULL);
        if (argument == -1) {
            break;
        }
        switch (argument) {
        case 'a': seq1_path= optarg;
            	break;
        case 'b': seq2_path= optarg;
	    	break;
	case 'c': seq3_path= optarg;
	    	break;
	case 'm': scores[0]=  atoi(optarg);
		break;
	case 'n': scores[1]=  atoi(optarg);
		break;
	case 'i': scores[2]=  atoi(optarg);
		break;
	case 'd': scores[3]=  atoi(optarg);
		break;
	case 'h':
	default: help();
		return -1;
    	}
    }
    sequence1.read_file(seq1_path);
    sequence2.read_file(seq2_path);
    sequence3.read_file(seq3_path);
    char *d_sequence1,*d_sequence2,*d_sequence3;


    printf("\n ---------------------------------------------------------------------------------------------"); 
    printf("\n Sequence 1: %s \t Length: %d",sequence1.seq_name,sequence1.seq_length);
    printf("\n Sequence 2: %s \t Length: %d",sequence2.seq_name,sequence2.seq_length);
    printf("\n Sequence 3: %s \t Length: %d",sequence3.seq_name,sequence3.seq_length);
    printf("\n ---------------------------------------------------------------------------------------------"); 
    printf("\n GPU Info \n");
    gpu=findBestDevice();
    printCardInfo(gpu);
    printf("\n ---------------------------------------------------------------------------------------------"); 

    const int nx = sequence1.seq_length;
    const int ny = sequence2.seq_length;
    const int nz = sequence3.seq_length;
    const dim3 blockSize(BLKXSIZE, BLKYSIZE, BLKZSIZE);
    const dim3 gridSize(((nx+BLKXSIZE-1)/BLKXSIZE), ((ny+BLKYSIZE-1)/BLKYSIZE), ((nz+BLKZSIZE-1)/BLKZSIZE));
    short **stateTrans= calculateTransition();
    printf("\n Scoring Values \n ________________ \n Match: %d \n Mismatch: %d \n Insertion: %d \n Deleteion: %d",scores[0],scores[1],scores[3],scores[2]);
    printf("\n ---------------------------------------------------------------------------------------------"); 

   unsigned size=nx*ny*nz;
    nRarray *c; // storage for result stored on host
    nRarray *d_c;  // storage for result computed on device
    nRarray *d_state;  // storage for result computed on device
    nRarray *state;  // storage for result computed on device
// allocate storage for data set
   if ((c = (nRarray *)malloc((nx*ny*nz)*sizeof(int))) == 0) {fprintf(stderr,"malloc1 Fail \n"); return 1;}
   if ((state = (nRarray *)malloc((nx*ny*nz)*sizeof(int))) == 0) {fprintf(stderr,"malloc1 Fail \n"); return 1;}
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
    cudaMalloc((void **) &d_state, (nx*ny*nz)*sizeof(int));
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
    parallel_score<<<gridSize, blockSize>>>(d_sequence1,d_sequence2,d_sequence3,nx,ny,nz,d_c,d_state,d_scores,d_allStates);
    cudaCheckErrors("Kernel launch failure");
    cudaDeviceSynchronize();
    kernelTimer.stop();
    double gcups = (sequence1.seq_length * sequence2.seq_length * sequence3.seq_length)/(kernelTimer.getElapsedTimeMillis()/1000);
    cout<<"\n Kernel Time:"<<kernelTimer.getElapsedTimeMillis()/1000<<"\n CUPS:"<<gcups<<endl;

    cudaMemcpy(c, d_c, ((nx*ny*nz)*sizeof(int)), cudaMemcpyDeviceToHost);
    cudaCheckErrors("CUDA memcpy failure");
   cout<<"\n Last Cell Score: "<<c[nx-1][ny-1][nz-1]<<endl; 
    free(c);
    cudaFree(d_c);
    cudaFree(d_scores);
    cudaFree(d_allStates);
    cudaCheckErrors("cudaFree fail");
    return 0;
}
