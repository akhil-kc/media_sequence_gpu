# media_sequence_gpu
The project aims to accelerate finding a median sequence among 3 input sequences. The project is inspired by the paper titled:
"A Divide-and-Conquer Implementation of Three Sequence Alignment and Ancestor Inference" by Jijun Tang and Feng Yue

The 3 sequences of length X,Y and Z are aligned in the form of a 3D cube with |X * Y * Z| elements in them. The score of each cell is calculated based on 27 possible states it can be in. The states are are combination of 3 possible values of Match, Insert or Delete.
Where MMM represents that all 3 sequences match for the particular cell, MMI denotes the first 2 sequences match while the third sequence requires and insertion.
The score of every state is calculated for every cell and the maximum value among those states is stored in it.
