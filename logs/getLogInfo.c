#include<stdio.h>
#define BSIZE 1024
#define LOGSTART 900

FILE *fp_read, *fp_write;

int main()
{
    fp_read = fopen("fs.img", "rb");
    if(!fp_read)
    {
        printf("\033[0;31mError in opening disk image\033[0m\n");
        return 0;
    }

    fp_write = fopen("logs/r5o5.log", "w");
    if(!fp_write)
    {
        printf("\033[0;31mError in creating/opening log file\033[0m\n");
        return 0;
    }

    if(fseek(fp_read, LOGSTART * BSIZE, SEEK_SET) != 0)
    {
        printf("\033[0;31mError in seeking disk\033[0m\n");
        return 0;
    }

    for(int i = 0;i < BSIZE;i++)
    {
        char c;

        if(fread(&c, sizeof(char), 1, fp_read) < 1)
        {
            printf("\033[0;31mError in reading disk\033[0m\n");
            break;
        }

        if(fwrite(&c, sizeof(char), 1, fp_write) < 1)
        {
            printf("\033[0;31mError in writing log file\033[0m\n");
            break;
        }
    }

    (void)fclose(fp_read);
    (void)fclose(fp_write);

    return 0;
}