#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <jpeglib.h>

int main()
{
	FILE* inFile;
// Have to open in binary mode to prevent stdio corrupting data by inserting newlines etc.
    inFile = fopen("jpegex.jpg", "rb");

    if(!inFile)
    {
    	printf("Can't open jpg file\n");
    	return 0;
    }

    else
    	printf("Opened jpeg!\n");

// Objects for decompression and error handling
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerror;

    cinfo.err = jpeg_std_error(&jerror);
    jpeg_create_decompress(&cinfo);

	printf("this far1\n");

// Set file source for decompression, read in jpeg header valies, start decompress (?)
    jpeg_stdio_src(&cinfo, inFile);
    printf("this far2\n");

    jpeg_read_header(&cinfo, TRUE);
    printf("this far 3\n");

    jpeg_start_decompress(&cinfo);

    int height = cinfo.output_height;
    int width = cinfo.output_width;
    int pixelSize = cinfo.num_components;
     //colorMap = cinfo.colormap;
    int rowStride = width * pixelSize;

    unsigned char* imageData;
    unsigned char* buffer[1];

    printf("width:%i height:%i pixelSize:%i\n", width, height, pixelSize);

// Memory block we put the values from the scanline into
    imageData = (unsigned char*)malloc(height * width * pixelSize);

    while(cinfo.output_scanline < cinfo.output_height)
    {
// Tells the program to put anything in the buffer into the imageData array at an offset of number of scanlines done * rowStride
		buffer[0] = imageData + (cinfo.output_scanline) * rowStride;
    	jpeg_read_scanlines(&cinfo, buffer, 1);
    }

    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);

    int counter = 0;

    for(int i = 0; i < height; i++)
    {
        for(int j = 0; j < rowStride; j++)
        {
            printf("%i ", imageData[j]);
            counter++;
        }
        printf("\n\n\n\n");
    }

    printf("%i", counter);

// Output to a ppm file
    FILE* outFile = fopen("outputJPG.ppm", "w");

    unsigned char* outImageData = (unsigned char*)malloc(width * height * pixelSize);    
    fprintf(outFile, "P3\n%i %i\n%i\n", width, height, 255);

    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < rowStride; x++)
        {
            outImageData[x] = imageData[x];
        }
    }

    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < rowStride; x++)
        {
            fprintf(outFile, "%i ", outImageData[x]);
        }
    }

    free(imageData);
    free(outImageData);

    imageData = NULL;
    outImageData = NULL;

    fclose(inFile);

    return 0;
}