#include "Stateinfo.h"
#include "dna.h"

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
	}
	return maxScore;
}

__global__ void parallel_score(DNA sequences[3],int *a,unsigned size,int scores[4],int allStates[27])
{
    unsigned idx = blockIdx.x*blockDim.x + threadIdx.x;
    unsigned idy = blockIdx.y*blockDim.y + threadIdx.y;
    unsigned idz = blockIdx.z*blockDim.z + threadIdx.z;
    unsigned xLen=sequences[0].seq_length;
    unsigned yLen=sequences[1].seq_length;
    unsigned zLen=sequences[2].seq_length;
    unsigned index= idx + (xLen * (idy + (yLen * idz)));
    if ((idx < (xLen)) && (idy < (yLen)) && (idz < (zLen)) && (index < size)){
	 int z = index / (xLen * yLen);
        index -= (z * xLen * yLen);
        int y = index / xLen;
        int x = index % xLen;
      a[index] = getScore(sequences[0].seq_string[x],sequences[1].seq_string[y],sequences[2].seq_string[z],scores,allStates);
      }
}

