#include<iostream>
#include<stdio.h>
#include <cstdlib>
#include "stateTransition.h"
using namespace std;

short** calculateTransition() 
{
short **stateTrans;             //used in scoreThree function
short **coTrans;                //used in combine two parts function
 char *state[] = { "MMM", "III", "MMD", "IID", "IIM", "MDM", "IDI", "IMI",
    "MDD", "IMM", "IMD", "IDM", "IDD", "DMM", "MII", "DII", "DMD",
    "MIM", "MID", "DIM", "DID", "DDM", "MMI", "MDI", "DMI", "DDI"
  };
	short scanI, scanD, scanI2, min = 999;
	int i,j,k;
 stateTrans = (short **) malloc (26 * sizeof (short *));
  if (stateTrans == (short **) NULL)
    fprintf (stderr, "ERROR: stateTrans NULL\n");
  for (i = 0; i < 26; i++)
    {
      stateTrans[i] = (short *) malloc (26 * sizeof (short));
      if (stateTrans[i] == (short *) NULL)
        fprintf (stderr, "ERROR: stateTrans NULL\n");
      for (j = 0; j < 26; j++)
        stateTrans[i][j] = 0;
    }
  coTrans = (short **) malloc (26 * sizeof (short *));
  for (i = 0; i < 26; i++)
    {
      coTrans[i] = (short *) malloc (26 * sizeof (short));
      for (j = 0; j < 26; j++)
        coTrans[i][j] = 0;
    }
  for (i = 0; i < 26; i++)
    {
      for (j = 0; j < 26; j++)
	{
	  if (i == 1 || i == 3 || i == 4 || i == 6 || i == 7 || i == 14
	      || i == 15)
	    {
	      stateTrans[i][j] = 5;
	      coTrans[i][j] = 5;
	      continue;
	    }
	  if (j == 1 || j == 3 || j == 4 || j == 6 || j == 7 || j == 14
	      || j == 15)
	    {
	      coTrans[i][j] = 5;
	      stateTrans[i][j] = 5;
	      continue;
	    }
	  scanI = 0;
	  scanD = 0;
	  scanI2 = 0;
	  for (k = 0; k < 3; k++)
	    {
	      if (state[i][k] == 'I')
		scanI2 = 1;
	      if (state[j][k] == 'I')
		scanI = 1;
	      else if (state[j][k] == 'D')
		scanD = 1;
	    }
	  if (scanI == 1)
	    {			/* Need to allow MMI to MIM */
	      for (k = 0; k < 3; k++)
		{
		  if (state[j][k] == 'M' && state[i][k] == 'M')
		    continue;	// do we need the above line ???
		  //if (state[j][k] != 'I' && state[i][k] != state[j][k])
		  if (state[j][k] == 'D' && state[i][k] != state[j][k])
		    {
		      stateTrans[i][j] = 5;
		      break;
		    }
		  if (state[j][k] == 'I' && state[i][k] == 'I')
		    {
		      stateTrans[i][j]++;
		    }
		}
	      for (k = 0; k < 3; k++)
		{
		  if (state[j][k] == 'M' && state[i][k] == 'M')
		    continue;
		  if (state[j][k] == 'I' && state[i][k] == 'I')
		    {
		      coTrans[i][j]++;
		    }
		  if (state[j][k] == 'D' && state[i][k] == 'D')
		    {
		      coTrans[i][j]++;
		    }
		}
	    }
	  else if (scanD == 1)
	    {
	      for (k = 0; k < 3; k++)
		{
		  //if (state[j][k] == 'D' && state[i][k] == 'D' && scanI2 != 1)
		  if (state[j][k] == 'D' && state[i][k] == 'D')
		    {
		      stateTrans[i][j]++;
		      coTrans[i][j]++;
		    }
		}
	    }
	}
    }
     //for (i = 0; i < 26; i++)
     //{
     //for (j = 0; j < 26; j++)
     //printf ("%d,", stateTrans[i][j]);
     //printf ("\n");
     //}
     return stateTrans;
}
