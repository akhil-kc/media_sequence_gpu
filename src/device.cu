#include<stdio.h>
#include "device.h"
#include "dna.h"
#define DATAXSIZE 671
#define DATAYSIZE 671
#define DATAZSIZE 671

__device__ int getScore(char a,char b,char c,int scores[4],int allStates[27])
{
	//1 Represents Match, 2 represents Insert , 3 represents Delete
	int score,maxScore=-999;
	int match=scores[0];
	int mismatch=scores[1];
	int insert=scores[2];
	int del=scores[3];
	 for(int i=0;i<27;i++)
        {
		if (allStates[i]<200)
		{
			switch(allStates[i]){
				case 111: score=((a==b)?((a==c)?(match+match+match):(match+match+mismatch)):((a==c)?(match+mismatch+match):(mismatch+mismatch+mismatch)));
					  maxScore=(score>maxScore)?score:maxScore;
					  break;
				case 112: score=((a==b)?(match+match+insert):(mismatch+mismatch+insert));
					 maxScore=(score>maxScore)?score:maxScore;
                                          break;
				case 113: score=((a==b)?(match+match+del):(mismatch+mismatch+del));
					  maxScore=(score>maxScore)?score:maxScore;
                                          break;
				case 121: score=((a==c)?(match+match+insert):(mismatch+mismatch+insert));
					  maxScore=(score>maxScore)?score:maxScore;
                                          break;
				case 122: score=(match+insert+insert);
					  maxScore=(score>maxScore)?score:maxScore;
					  break;
				case 123: score=(match+insert+del);
					  maxScore=(score>maxScore)?score:maxScore;
					  break;
				case 131: score=((a==c)?(match+del+match):(mismatch+del+mismatch));
					  maxScore=(score>maxScore)?score:maxScore;
                                          break;
				case 132: score=(match+insert+del);
					   maxScore=(score>maxScore)?score:maxScore;
					  break;
				case 133: score=(match+del+del);
				          maxScore=(score>maxScore)?score:maxScore;
					  break;
		
			}
		}
		else if (allStates[i]<300)
		{
			switch(allStates[i]){
			case 211: score=((b==c)?(insert+match+match):(insert+mismatch+mismatch));
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 212: score=(insert+match+insert);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 213: score=(insert+match+del);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 221: score=(insert+insert+match);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 222: score=(insert+insert+insert);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 223: score=(insert+insert+del);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 231: score=(insert+del+match);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 232: score=(insert+del+insert);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 233: score=(insert+del+del);
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			}
		}
		else{
			switch(allStates[i]){
			case 311: score=((b==c)?(del+match+match):(del+mismatch+mismatch));
				  maxScore=(score>maxScore)?score:maxScore;
				  break;
			case 312: score=(del+match+insert);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
                        case 313: score=(del+match+del);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
                        case 321: score=(del+insert+match);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
                        case 322: score=(del+insert+insert);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
                        case 323: score=(del+insert+del);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
                        case 331: score=(del+del+match);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
                        case 332: score=(del+del+insert);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
                        case 333: score=(del+del+del);
                                  maxScore=(score>maxScore)?score:maxScore;
                                  break;
			}
		}

	}
	return maxScore;
}

__global__ void parallel_score(char *sequence1,char * sequence2,char* sequence3,int xLen,int yLen,int zLen,int a[][DATAYSIZE][DATAXSIZE],int state[][DATAYSIZE][DATAXSIZE],int scores[4],int allStates[27])
{
    unsigned idx = blockIdx.x*blockDim.x + threadIdx.x;
    unsigned idy = blockIdx.y*blockDim.y + threadIdx.y;
    unsigned idz = blockIdx.z*blockDim.z + threadIdx.z;
    if ((idx < (xLen)) && (idy < (yLen)) && (idz < (zLen)) ){
	a[idx][idy][idz]=getScore(sequence1[idx],sequence2[idy],sequence3[idz],scores,allStates);
      }
}

