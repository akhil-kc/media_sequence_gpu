#ifndef _DEVICE_H
#define _DEVICE_H
#include "dna.h"
#define DATAXSIZE 671
#define DATAYSIZE 671
#define DATAZSIZE 671

// For storing and calculating the state
class Stateinfo {
  public:
    Stateinfo();
    ~Stateinfo();
    int states[27];
    int getScore(char a,char b,char c);
};

//__global__ void parallel_score(int a[][DATAXSIZE][DATAXSIZE],unsigned size,int scores[4],int allStates[27]);
__global__ void parallel_score(char seq1[DATAXSIZE],char seq2[DATAXSIZE],char seq3[DATAXSIZE],int s1,int s2,int s3,int a[][DATAXSIZE][DATAXSIZE],unsigned size,int scores[4],int allStates[27]);
#endif
