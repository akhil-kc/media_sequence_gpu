#ifndef _STATEINFO_H
#define _STATEINFO_H
#include "dna.h"
// For storing and calculating the state
class Stateinfo {
  public:
    Stateinfo();
    ~Stateinfo();
    int states[27];
    int getScore(char a,char b,char c);
};

__global__ void parallel_score(DNA sequences[3],int *a,unsigned size,int scores[4],int allStates[27]);
#endif
