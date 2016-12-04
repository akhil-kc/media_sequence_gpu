# media_sequence_gpu
The project aims to accelerate finding a median sequence among 3 input sequences. The project is inspired by the paper titled:
"A Divide-and-Conquer Implementation of Three Sequence Alignment and Ancestor Inference" by Jijun Tang and Feng Yue

The 3 sequences of length X,Y and Z are aligned in the form of a 3D cube with |X * Y * Z| elements in them. The score of each cell is calculated based on 27 possible states it can be in. The states are are combination of 3 possible values of Match, Insert or Delete.
Where MMM represents that all 3 sequences match for the particular cell, MMI denotes the first 2 sequences match while the third sequence requires and insertion.
The score of every state is calculated for every cell and the maximum value among those states is stored in it.


Usage:
--------------------------------------------------
./median -a <sequence 1> -b <sequence 2> -c <sequence 3> [Arguments ...]

Arguments:
        -a, --sequence1 <file> (required)
                Input Sequence 1 FASTA format
        -b, --sequence2 <file> (required)
                Input Sequence 2 FASTA format
        -c, --sequence3 <file> (required)
                Input Sequence 3 FASTA format
        -m, --match <int> (default : 5)                                                                                                   
                Match score, should be a positive integer
        -n, --mismatch <int> (default : -10)
                Mismatch score, should be a negative integer
        -d, --deletion <int> (default : -5)
                Deletion score, should be a negative integer
        -i, --insertion <int> (default : -4)
                Insertion score, should be a negative integer
        -h, -help
                prints out the help
