/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

//Determines what color the cell at the given row/col should be. This function allocates space for a new Color.
//Note that you will need to read the eight neighbors of the cell in question. The grid "wraps", so we treat the top row as adjacent to the bottom row
//and the left column as adjacent to the right column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule)
{
	int rows = image->rows;
	int cols = image->cols;

	int neighbors[8][2] = {
		{(row - 1 + rows) % rows, (col - 1 + cols) % cols},
		{(row - 1 + rows) % rows, col},
		{(row - 1 + rows) % rows, (col + 1) % cols},
		{row, 					  (col - 1 + cols) % cols},
		{row, 					  (col + 1) % cols},
		{(row + 1) % rows, 		  (col - 1 + cols) % cols},
		{(row + 1) % rows, 		  col},
		{(row + 1) % rows, 		  (col + 1) % cols}
	};

	Color *new_color = (Color *)malloc(sizeof(Color));
    new_color->R = 0;
    new_color->G = 0;
    new_color->B = 0;

    for (int bit = 0; bit < 8; bit++) {
        int alive_R = 0, alive_G = 0, alive_B = 0;

        for (int i = 0; i < 8; i++){
            int n_row = neighbors[i][0];
            int n_col = neighbors[i][1];
            
			//统计邻居存活数
            alive_R += (image->image[n_row][n_col].R >> bit) & 1;
            alive_G += (image->image[n_row][n_col].G >> bit) & 1;
            alive_B += (image->image[n_row][n_col].B >> bit) & 1;
        }

		//统计当前位置是否存活
        int is_alive_R = (image->image[row][col].R >> bit) & 1;
        int is_alive_G = (image->image[row][col].G >> bit) & 1;
        int is_alive_B = (image->image[row][col].B >> bit) & 1;

        int new_state_R = (rule >> (is_alive_R * 9 + alive_R)) & 1;
        int new_state_G = (rule >> (is_alive_G * 9 + alive_G)) & 1;
        int new_state_B = (rule >> (is_alive_B * 9 + alive_B)) & 1;

        new_color->R |= (new_state_R << bit);
        new_color->G |= (new_state_G << bit);
        new_color->B |= (new_state_B << bit);
    }

    return new_color;

}

//The main body of Life; given an image and a rule, computes one iteration of the Game of Life.
//You should be able to copy most of this from steganography.c
Image *life(Image *image, uint32_t rule)
{
	Image *new_image = (Image*)malloc(sizeof(Image));

	new_image->rows = image->rows;
	new_image->cols = image->cols;
	
	new_image->image = (Color**)malloc(new_image->rows * sizeof(Color*));
	for (int i = 0; i < new_image->rows; i++){
		new_image->image[i] = (Color*)malloc(new_image->cols * sizeof(Color));
	}

	for (uint32_t i = 0; i < image->rows; i++){
		for (uint32_t j = 0; j < image->cols; j++){
			Color *new_pixel = evaluateOneCell(image, i, j, rule);
			new_image->image[i][j] = *new_pixel;
			free(new_pixel);
		}
	}
	return new_image;
}

/*
Loads a .ppm from a file, computes the next iteration of the game of life, then prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this will be a string.
You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv)
{
	if (argc != 3){
		printf("usage: ./gameOfLife filename rule\nfilename is an ASCII PPM file (type P3) with maximum value 255.\nrule is a hex number beginning with 0x; Life is 0x1808.\n");

		return -1;
	}

	char *fn = argv[1];
	char *new_rule = argv[2];

	char *endptr;
    uint32_t rule = strtol(new_rule, &endptr, 16);
    if (*endptr != '\0' || rule < 0x00000 || rule > 0x3FFFF) {
        printf("Invalid rule. Rule should be a hex number between 0x00000 and 0x3FFFF.\n");
        return -1;
    }

	Image *img = readData(fn);
	Image *new_img = life(img, rule);
	writeData(new_img);
	freeImage(new_img);
	freeImage(img);

	return 0;
}
