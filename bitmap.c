#include <stdio.h>
#include <stdlib.h>

// prototypes of the functions to be implemented in assembly level
void brightness(unsigned char *i1, int w, int h, int val);
void brightness_sse(unsigned char *i1, int len, int val);

int main(int argc, char *argv[]) {
    // variables
    int value = 0;
    int i, j;
    char information[54];
    int width, height;
    unsigned char *image1;
    char outfilename[512];
    FILE *input, *output;
    // argument check
    if (argc < 3) {
        printf("usage: ./program input1.bmp value [--sse] \n");
        return 1;
    }
    // read input image (It must be a 24-bit bmp file)
    input = fopen(argv[1], "rb");
    fread(information, 1, 54, input);
    width = *(int *)(information + 18);
    height = *(int *)(information + 22);
    image1 = (unsigned char *)calloc(width * height, 1);
    unsigned char blue, green, red;
    for (i = 0; i < height; i++)
        for (j = 0; j < width; j++) {
            blue = getc(input);
            green = getc(input);
            red = getc(input);
            // convert to grayscale
            image1[i * width + j] = (blue + green + red) / 3;
        }
    fclose(input);
    value = atoi(argv[2]);
    if (value < -255 || value > 255) {
        printf("value must be in [-255,255] for this operation\n");
        return 1;
    }

    if (argc == 4)
        brightness_sse(image1, height * width, value);
    else
        brightness(image1, width, height, value);

    // save the resulting image to a file
    i = 0;
    if (argc == 4) {
        outfilename[i++] = 's';
        outfilename[i++] = 's';
        outfilename[i++] = 'e';
        outfilename[i++] = '_';
    }
    outfilename[i++] = 'o';
    outfilename[i++] = 'u';
    outfilename[i++] = 't';
    outfilename[i++] = '_';
    for (j = 0; argv[1][j] != '\0'; j++) {
        outfilename[i++] = argv[1][j];
    }

    output = fopen(outfilename, "wb");
    *(int *)(information + 18) = width;
    *(int *)(information + 22) = height;
    fwrite(information, 1, 54, output);
    for (i = 0; i < height; i++)
        for (j = 0; j < width; j++) {
            putc(image1[i * width + j], output);
            putc(image1[i * width + j], output);
            putc(image1[i * width + j], output);
        }
    fclose(output);
    free(image1);

    return 0;
}
