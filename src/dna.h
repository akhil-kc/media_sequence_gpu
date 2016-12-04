#ifndef _DNA_H
#define _DNA_H


class DNA {
  public:
    DNA();
    ~DNA();
    bool read_file(char * file_name);
    char *seq_string;
    char *seq_name;
    int seq_length;
};

#endif

