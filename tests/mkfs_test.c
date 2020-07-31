#include<stdio.h>

#define BLOCK_SIZE 1024
#define DISK_SIZE 1000
#define START_BLOCK 100
#define PROC_START 100
#define PROC_END 299
#define LOG_START 900
#define LOG_END 999
#define get_offset(block_num, off) (BLOCK_SIZE * block_num + offset)

void build_disk(FILE *f_disk)
{
    for(int blk = 0;blk < DISK_SIZE;blk++)
    {
        for(int byte = 0;byte < BLOCK_SIZE;byte++)
        {
            char c = ' ';
            fwrite(&c, 1, 1, f_disk);
        }
    }
}

void add_program_disk(FILE *f_disk, FILE *f_info, char *proc_file)
{
    static int block_num = PROC_START, offset = 0;
    FILE *fl_proc = fopen(proc_file, "rb");
    if(!fl_proc)
    {
        printf("\033[0;31mError in opening %s\033[0m\n", proc_file);
        return;
    }

    if(fseek(f_disk, get_offset(block_num, offset), SEEK_SET) != 0)
    {
        printf("\033[0;31mError in seeking disk\033[0m\n");
        return;
    }

    int prev_block_num = block_num, prev_offset = offset; // Store the previous values, in case there was some error and for prog info
    int error_occurred = 0;
    while(1)
    {
        char c;
        int rd_bytes = fread(&c, 1, 1, fl_proc);
        if(rd_bytes < 1) // Program had been read
            break;

        if(offset == BLOCK_SIZE) // Block has been completely written, get next block
        {
            block_num ++;
            offset = 0;
            if(block_num == PROC_END + 1) // All allowed blocks have been used, discard this Program
            {
                printf("\033[0;31mProgram %s is not written to disk due to insufficient space\033[0m\n", proc_file);
                block_num = prev_block_num;
                offset = prev_offset;
                error_occurred = 1;
                break;
            }
        }
        
        if(fwrite(&c, 1, 1, f_disk) < 1) // Since Program was not completely written to disk, restore previous block num and offset 
        {
            printf("\033[0;31mError in writing %s to disk\033[0m\n", proc_file);
            block_num = prev_block_num;
            offset = prev_offset;
            error_occurred = 1;
            break;
        }

        offset ++; // Increment offset
    }

    if(!error_occurred) // If error did not occur, then program was succesfully placed
    {
        if(fprintf(f_info, "%s | start-block num: %d, start-offset: %d, end-block num: %d, end-offset: %d\n", proc_file, prev_block_num, prev_offset, block_num, offset) < 0)
            printf("\033[0;31mError in writing information of %s\033[0m\n", proc_file);
    }


    (void)fclose(fl_proc);
}

int main(int argc, char *argv[])
{
    if(argc < 2)
    {
        printf("\033[0;31mimage file unspecified\033[0m\n");
        return 1;
    }

    FILE *f_disk = fopen(argv[1], "w");
    if(!f_disk)
    {
        printf("\033[0;31mError in creating/opening disk image\033[0m\n");
        return 0;
    }

    FILE *f_info = fopen("information/prog_info", "w");
    if(!f_info)
    {
        printf("\033[0;31mError in creating program information file\033[0m\n");
        return 0;
    }

    build_disk(f_disk);
    for(int i = 2;i < argc;i++)
        add_program_disk(f_disk, f_info, argv[i]);

    (void)fclose(f_info);
    (void)fclose(f_disk);
    return 0;
}