#include <stdio.h>

#define BLOCK_SIZE 1024
#define DISK_SIZE 1000
#define START_BLOCK 100
#define PROC_START 100
#define PROC_END 299
#define LOG_START 900
#define LOG_END 999
#define getOffset(blockNum, off) (BLOCK_SIZE * blockNum + off)

// Fills the disk with the spaces
void buildDisk(FILE *disk) {
  
    for(int block = 0; block < DISK_SIZE; block++) {
        for(int byte = 0; byte < BLOCK_SIZE; byte++) {
            char c = ' ';
            fwrite(&c, sizeof(char), 1, disk);
        }
    }
}

// This stores a program on the disk
// progName -> name of the program
// info -> file stream for the information file
// disk -> file stream for the disk file
// information file -> stores the location of the program
// in the disk
void storeProgram(FILE *disk, FILE *info, char *progName) {
  
    static int blockNum = PROC_START, offset = 0;
    FILE *prog = fopen(progName, "rb");
    if(prog == NULL) {
        printf("\033[0;31mError: Couldn't open  %s\033[0m\n", progName);
        return;
    }

    if(fseek(disk, getOffset(blockNum, offset), SEEK_SET) != 0) {
        printf("\033[0;31mError: Couldn't set the file position\033[0m\n");
        return;
    }

    // Store the previous values, in case there was some error and for prog info
    int prevBlockNum = blockNum, prevOffset = offset; 
    int errorOccurred = 0;
    
    while (1) {

        blockNum += offset / BLOCK_SIZE;
	    offset %= BLOCK_SIZE;

        char c;
        int readBytes = fread(&c, sizeof(char), 1, prog);

        // reading completed
        if(readBytes < 1)
            break;

        // all the blocks allocated for the process are used
        // discard the program store
        if(blockNum >= PROC_END + 1) {
            printf("\033[0;31mProgram %s couldn't be written"
                "on the disk due to insufficient space\033[0m\n", progName);
            blockNum = prevBlockNum;
            offset = prevOffset;
            errorOccurred = 1;
            break;
        }

        // If the program couldn't be completely written on the  disk,
        // restore the previous block num and offset 
        if(fwrite(&c, sizeof(char), 1, disk) < 1) {
            printf("\033[0;31mError in writing %s"
                    "on the disk\033[0m\n", progName);
            blockNum = prevBlockNum;
            offset = prevOffset;
            errorOccurred = 1;
            break;
        }

        // increment the offset
        offset ++;
    }

    // If the program was successfully written,
    // store the program location in the information file
    if(!errorOccurred) {

        offset = (offset + BLOCK_SIZE - 1) % BLOCK_SIZE;
        if (offset == BLOCK_SIZE - 1)
	        blockNum --;
	
        if(
            fprintf(info,
		   "%s | start-block num: %d, start-offset: %d,"
                   " end-block num: %d, end-offset: %d\n",
		   progName,
		   prevBlockNum,
		   prevOffset,
		   blockNum,
		   offset) < 0
        ) {
            printf("\033[0;31mError in writing information of %s\033[0m\n",
		    progName);
        }
    }
    else
        printf("\033[0;31mError in placing program %s\033[0m\n", progName);

    (void)fclose(prog);
}

// argv[1] -> disk image filename
// argv[2...] -> program filenames
int main(int argc, char *argv[]) {

    if(argc < 2) {
        printf("\033[0;31disk image file unspecified\033[0m\n");
        return 1;
    }

    FILE *disk = fopen(argv[1], "w");
    if(!disk) {
        printf("\033[0;31mError in creating/opening disk image\033[0m\n");
        return 0;
    }

    FILE *info = fopen("information/prog_info", "w");
    if(!info) {
        printf("\033[0;31mError in creating program information file\033[0m\n");
        return 0;
    }
    
    buildDisk(disk);
    for(int i = 2; i < argc; i++)
        storeProgram(disk, info, argv[i]);

    (void)fclose(info);
    (void)fclose(disk);
    return 0;
}
