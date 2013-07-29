// GOL.cpp : Defines the entry point for the console application.
//

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <math.h>
#include <sys/time.h>

void getNeighbor(int *,int,int,int,int,int *);
void generation(int *,int,int);
int main(int argc, char *argv[]) 
{
	int *input;
	int inputSize,sqrt_inputSize_int,totalGenerations;
	//time_t start,end;
	time_t rawtime;
	struct tm * timeinfo;
	struct timeval start_time, end_time;
	bool infinite_flag = false;
	char reply;
	//Loop continues till number entered by user is perfect square and > 1.
	do{
		printf("Enter number of element - N*N (should be perfect square) \n");
		scanf("%d",&inputSize);
		sqrt_inputSize_int = sqrt((double)inputSize);
		//printf("%d \n",sqrt_inputSize_int);
	}
	while(sqrt_inputSize_int*sqrt_inputSize_int != inputSize || inputSize == 0 || inputSize == 1);
	// Number of rows and columsn is square root of inputSize.
	int rowDim = sqrt((double)inputSize);
	int colDim = sqrt((double)inputSize);
	printf("Do you want infinite loop('y' or 'n') : ");
	//scanf("%c",&reply);
	getchar();
	reply = getchar();
	printf("%c\n",reply);
	if(reply == 'y')
	{
		infinite_flag = true;	
	}
	else
	{
		printf("Enter # of generations\n");
		scanf("%d",&totalGenerations);
	}
	input = (int *) malloc(inputSize*sizeof(int));
	//	
	srand(time(NULL));	//Seed rand function each time differently.
	for(int i=0;i<inputSize;i++)
	{
		//*(input+i) = i+1;
		*(input+i) = rand() % 2 ;
	}
	// testing
	int check[] = {0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1,
					0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 1, 1};
	for(int i=0;i<inputSize;i++)
	{
		//*(input+i) = i+1;
		*(input+i) = check[i];
	}
	// testing
	for(int i=0;i<inputSize;i++)
	{
		printf("%d, ",*(input+i));
	}
	printf("\nprinting in row col wise\n");
	//
	for(int i=0;i<rowDim;i++)
	{
		for(int j=0;j<colDim;j++)
		{
			printf("%d ",*(input+(i*colDim)+j)); // i is [row] and j is [col]
		}
		printf("\n");
	}
	
	//start = time(NULL);
	time ( &rawtime );
	timeinfo = localtime ( &rawtime );
	//printf ( "Current local time and date: %s", asctime (timeinfo) );
	gettimeofday(&start_time, NULL);
	//printf("%ld\n", ((start_time.tv_sec * 1000000 + start_time.tv_usec)));
	
	for(int i=0;i<totalGenerations;i++)
	{
		printf("Generation %d is \n",i+1);
		generation(input,rowDim,colDim);
		printf("\n");
	}
	//end = time(NULL);
	time ( &rawtime );
	timeinfo = localtime ( &rawtime );
	//printf ( "Current local time and date: %s", asctime (timeinfo) );
	gettimeofday(&end_time, NULL);
	//
	printf("# elements in sequential processing %d \n",inputSize);
	printf("# of generations %d \n",totalGenerations);
	printf("Elapsed time in microseconds %ld\n", ((end_time.tv_sec * 1000000 + end_time.tv_usec)
							- (start_time.tv_sec * 1000000 + start_time.tv_usec)));
							
	return 0;
}
void generation(int *input,int rowDim,int colDim)
{
	int sum = 0;
	int * temp = (int *) malloc((rowDim*colDim)*sizeof(int));
	
	int * neighborList = (int *) malloc(8 * sizeof(int));
	//neighbor list squence is right,left,top,top right,top left,bottom,bottom right,bottom left...
	for(int i=0;i<rowDim;i++)
	{
		for(int j=0;j<colDim;j++)
		{
			getNeighbor(input,i,j, rowDim,colDim,neighborList);
			for(int k=0;k<8;k++)
			{
				sum += *(neighborList+k);
			}
			//printf("sum for [%d %d]element %d\n",i,j,sum);
			if(*(input+(i*colDim)+j) == 1)
			{
				//current cell has life.
				if(sum<=1)
					*(temp+(i*colDim)+j) = 0;	// under occupancy or loneyness
				else
				{
					if(sum>=4)
						*(temp+(i*colDim)+j) = 0;	// over occupancy or crowded
					else
						*(temp+(i*colDim)+j) = 1; // 2 or 3 neighbors
				}
			}
			else
			{
				//current cell has no life.
				if(sum == 3)
					*(temp+(i*colDim)+j) = 1;	//exactly 3 neighbors gives new birth.
				else
					*(temp+(i*colDim)+j) = 0;
			}
			sum = 0;
		}
	}
	for(int i=0;i<(rowDim*colDim);i++)
	{
		printf("%d, ",*(temp+i));
		*(input+i) = *(temp+i);
	}
	printf("\ngrid presentation\n");
	for(int i=0;i<rowDim;i++)
	{
		for(int j=0;j<colDim;j++)
		{
			printf("%d ",*(temp+(i*colDim)+j));
		}
		printf("\n");
	}
}
void getNeighbor(int *input,int row,int col,int rowDim,int colDim, int * neighborList)
{
	//printf("elements is %d \n",*(input+(row*colDim)+col));
	int i=0;
	//right neighbor
	if((col+1) < colDim)
	{
		//printf("right neighbor is %d \n",*(input+(row*colDim)+col+1));
		*(neighborList+i) = *(input+(row*colDim)+col+1);
		i++;
	}
	else
	{
		//printf("right neighbor is %d \n",*(input+(row*colDim)+0));
		*(neighborList+i) = *(input+(row*colDim)+0);
		i++;
	}
	//left neighbor
	if((col-1) >= 0)
	{
		//printf("left neighbor is %d \n",*(input+(row*colDim)+col-1));
		*(neighborList+i) = *(input+(row*colDim)+col-1);
		i++;
	}
	else
	{
		//printf("left neighbor is %d \n",*(input+(row*colDim)+colDim-1));
		*(neighborList+i) = *(input+(row*colDim)+colDim-1);
		i++;
	}
	//top neighbor
	if((row-1) >= 0)
	{
		//printf("top neighbor is %d \n",*(input+((row-1)*colDim)+col));
		*(neighborList+i) = *(input+((row-1)*colDim)+col);
		i++;
		//top right neighbor
		if((col+1) < colDim)
		{
			//printf("top right neighbor is %d \n",*(input+((row-1)*colDim)+col+1));
			*(neighborList+i) = *(input+((row-1)*colDim)+col+1);
			i++;
		}
		else
		{
			//printf("top right neighbor is %d \n",*(input+((row-1)*colDim)+0));
			*(neighborList+i) = *(input+((row-1)*colDim)+0);
			i++;
		}
		//top left neighbor
		if((col-1) >= 0)
		{
			//printf("top left neighbor is %d \n",*(input+((row-1)*colDim)+col-1));
			*(neighborList+i) = *(input+((row-1)*colDim)+col-1);
			i++;
		}
		else
		{
			//printf("top left neighbor is %d \n",*(input+((row-1)*colDim)+colDim-1));
			*(neighborList+i) = *(input+((row-1)*colDim)+colDim-1);
			i++;
		}
	}
	else
	{
		//printf("top neighbor is %d \n",*(input+((rowDim-1)*colDim)+col));
		*(neighborList+i) = *(input+((rowDim-1)*colDim)+col);
		i++;
		//top right neighbor
		if((col+1) < colDim)
		{
			//printf("top right neighbor is %d \n",*(input+((rowDim-1)*colDim)+col+1));
			*(neighborList+i) = *(input+((rowDim-1)*colDim)+col+1);
			i++;
		}
		else
		{
			//printf("top right neighbor is %d \n",*(input+((rowDim-1)*colDim)+0));
			*(neighborList+i) = *(input+((rowDim-1)*colDim)+0);
			i++;
		}
		//top left neighbor
		if((col-1) >= 0)
		{
			//printf("top left neighbor is %d \n",*(input+((rowDim-1)*colDim)+col-1));
			*(neighborList+i) = *(input+((rowDim-1)*colDim)+col-1);
			i++;
		}
		else
		{
			//printf("top left neighbor is %d \n",*(input+((rowDim-1)*colDim)+colDim-1));
			*(neighborList+i) = *(input+((rowDim-1)*colDim)+colDim-1);
			i++;
		}
	}
	//bottom neighbor
	if((row+1) < rowDim)
	{
		//bottom neighbor
		//printf("bottom neighbor is %d \n",*(input+((row+1)*colDim)+col));
		*(neighborList+i) = *(input+((row+1)*colDim)+col);
		i++;
		//bottom right neighbor
		if((col +1 ) < colDim)
		{
			//printf("bottom right neighbor is %d \n",*(input+((row+1)*colDim)+col+1));
			*(neighborList+i) = *(input+((row+1)*colDim)+col+1);
			i++;
		}
		else
		{
			//printf("bottom right neighbor is %d \n",*(input+((row+1)*colDim)+0));
			*(neighborList+i) = *(input+((row+1)*colDim)+0);
			i++;
		}
		//bottom left neighbor
		if((col-1) >= 0)
		{
			//printf("bottom left neighbor is %d \n",*(input+((row+1)*colDim)+col-1));
			*(neighborList+i) = *(input+((row+1)*colDim)+col-1);
			i++;
		}
		else
		{
			//printf("bottom left neighbor is %d \n",*(input+((row+1)*colDim)+colDim-1));
			*(neighborList+i) = *(input+((row+1)*colDim)+colDim-1);
			i++;
		}
	}
	else
	{
		//printf("bottom neighbor is %d \n",*(input+(0*colDim)+col));
		*(neighborList+i) = *(input+(0*colDim)+col);
		i++;
		//bottom right neighbor
		if((col +1 ) < colDim)
		{
			//printf("bottom right neighbor is %d \n",*(input+(0*colDim)+col+1));
			*(neighborList+i) = *(input+(0*colDim)+col+1);
			i++;
		}
		else
		{
			//printf("bottom right neighbor is %d \n",*(input+(0*colDim)+0));
			*(neighborList+i) = *(input+(0*colDim)+0);
			i++;
		}
		//bottom left neighbor
		if((col-1) >= 0)
		{
			//printf("bottom left neighbor is %d \n",*(input+(0*colDim)+col-1));
			*(neighborList+i) = *(input+(0*colDim)+col-1);
			i++;
		}
		else
		{
			//printf("bottom left neighbor is %d \n",*(input+(0*colDim)+colDim-1));
			*(neighborList+i) = *(input+(0*colDim)+colDim-1);
			i++;
		}
	}

	//printf("\n value of i %d \n",i);
}
