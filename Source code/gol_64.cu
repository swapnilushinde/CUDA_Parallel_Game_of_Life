// GOL.cpp : Defines the entry point for the console application.
//

#include <stdio.h>
#include <cuda.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

__device__  void getNeighbor(int *,int,int,int,int,int *);
__global__ void generation(int *input_whole,int *input,int *rowDim,int *colDim,int *tmp,int *m)
{
	int sum = 0;
	int row,col;
	//int * neighborList = (int *) cudaMalloc(8 * sizeof(int));
	int neighborList[8];
	
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	if((tid+(*m)) < ((*rowDim) * (*colDim)))
	{
	row		= (int) (tid+(*m)) / *colDim;
	col	 	= (int) (tid+(*m)) - (row * (*colDim));
	//*(tmp + 2*tid) = row;
	//*(tmp + 2*tid + 1) = col;
	//*dev_row = row;
	//*dev_col = col;
	getNeighbor(input_whole,row,col, *rowDim,*colDim,neighborList);
	for(int k=0;k<8;k++)
	{
		sum += *(neighborList+k);
	}
	//*dev_sum = sum;
	//tmp[tid] = sum;
	//int offset = (row * (*colDim))+col;
	int offset = (row * (*colDim))+col-(*m);
	if(*(input+offset) == 1)
		{
			//current cell has life.
			if(sum<=1)
				*(tmp+offset) = 0;	// under occupancy or loneyness
			else
			{
				if(sum>=4)
					*(tmp+offset) = 0;	// over occupancy or crowded
				else
					*(tmp+offset) = 1; // 2 or 3 neighbors
			}
		}
		else
		{
			//current cell has no life.
			if(sum == 3)
				*(tmp+offset) = 1;	//exactly 3 neighbors gives new birth.
			else
				*(tmp+offset) = 0;
		}
	}
}

//void generation(int *,int,int);
int main(int argc, char *argv[]) 
{
	int *input;
	int inputSize,sqrt_inputSize_int;
	bool infinite_flag = false;
	char reply;
	//Loop continues till number entered by user is perfect square and > 1.
	do{
		printf("Enter number of element- N*N (should be perfect square) \n");
		scanf("%d",&inputSize);
		sqrt_inputSize_int = sqrt((double)inputSize);
		//printf("%d \n",sqrt_inputSize_int);
	}
	while(sqrt_inputSize_int*sqrt_inputSize_int != inputSize || inputSize == 0 || inputSize == 1);
	// Number of rows and columsn is square root of inputSize.
	int rowDim = sqrt((double)inputSize);
	int colDim = sqrt((double)inputSize);
	//Get # of blocks, #of threads and total generations. (default 1).
	// User can choose to get infinite generations also.
	int B,T,totalGenerations=1;
	printf("Enter # of blocks\n");
	scanf("%d",&B);
	printf("Enter # of threads per block\n");
	scanf("%d",&T);
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

	//Set input array elements to either 0 or 1 randomly.
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
	// Set output array to default value 99.
	int * tmp = (int *) malloc((rowDim*colDim)*sizeof(int));
	for(int i=0;i<(rowDim*colDim);i++)
	{
		*(tmp + i) = 99;
	}
	//device pointers to copy data to CUDA device.
	int *dev_input,*dev_tmp, *dev_rowDim,*dev_colDim,*dev_offset;
	//int *dev_row,*dev_col,*dev_sum;
	//int row,col,sum;
	int offset=0;
	
	//Create CUDA event for performance measurement.
	cudaEvent_t start,end;
	float elapsedTime;
	cudaEventCreate(&start);
	cudaEventCreate(&end);
	
	//Start event recording
	cudaEventRecord(start, 0);
	
	cudaMalloc((void**)&dev_input,(rowDim*colDim) * sizeof(int));
	cudaMalloc((void**)&dev_rowDim,sizeof(int));
	cudaMalloc((void**)&dev_colDim,sizeof(int));
	cudaMalloc((void**)&dev_tmp,(rowDim*colDim) * sizeof(int));
	//cudaMalloc((void**)&dev_col,sizeof(int));
	//cudaMalloc((void**)&dev_row,sizeof(int));
	cudaMalloc((void**)&dev_offset,sizeof(int));
	//cudaMalloc((void**)&dev_sum,sizeof(int));

	cudaMemcpy(dev_input, input , (rowDim*colDim)*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_rowDim, &rowDim , sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_colDim, &colDim , sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_tmp, tmp , (rowDim*colDim)*sizeof(int),cudaMemcpyHostToDevice);
	cudaMemcpy(dev_offset, &offset , sizeof(int),cudaMemcpyHostToDevice);
	
	for(int s=0;s<totalGenerations;s++)
	{
		for(int m = 0;m<(rowDim*colDim);m=m+(B*T))
		{
			offset = m;
			cudaMemcpy(dev_offset, &offset , sizeof(int),cudaMemcpyHostToDevice);
			generation<<<B,T>>>(dev_input,dev_input+m,dev_rowDim,dev_colDim,dev_tmp+m,dev_offset);
			//cudaMemcpy(&row,dev_row,sizeof(int),cudaMemcpyDeviceToHost);
			//cudaMemcpy(&col,dev_col,sizeof(int),cudaMemcpyDeviceToHost);
			//cudaMemcpy(&sum,dev_sum,sizeof(int),cudaMemcpyDeviceToHost);
			cudaMemcpy(tmp,dev_tmp,(rowDim*colDim)*sizeof(int),cudaMemcpyDeviceToHost);
			/*for(int i=0;i<(rowDim*colDim);i++)
			{
				printf("%d ",*(tmp+i));
			}*/
			printf("\n");
			//int copyoffset;
			//cudaMemcpy(&copyoffset,dev_offset,sizeof(int),cudaMemcpyDeviceToHost);
			//printf("\n%d %d %d %d\n",row,col,copyoffset,sum);
		}
		printf("Generation %d is \n",s+1);
		cudaMemcpy(tmp,dev_tmp,(rowDim*colDim)*sizeof(int),cudaMemcpyDeviceToHost);
		for(int i=0;i<(rowDim*colDim);i++)
		{
			printf("%d, ",*(tmp+i));
		}
		printf("\ngrid presentation\n");
		for(int i=0;i<rowDim;i++)
		{
			for(int j=0;j<colDim;j++)
			{
				printf("%d ",*(tmp+(i*colDim)+j));
			}
			printf("\n");
		}

		//printf("\n\n");
		cudaMemcpy(dev_input, tmp , (rowDim*colDim)*sizeof(int),cudaMemcpyHostToDevice);
		if(infinite_flag)
			totalGenerations = totalGenerations + 1;
	}
	//Stop recording
	cudaEventRecord(end, 0);
	//Synchronized to actually record event because cudaEvent Record is asynchronous call
	cudaEventSynchronize(end);
	cudaEventElapsedTime(&elapsedTime,start,end);
	
	//Final output display
	printf("\nNumber of blocks used %d\n", B);
	printf("Number of threads used %d\n", T);
	printf("Elapsed time in microseconds %ld\n", long(elapsedTime*1000));
	//
	cudaEventDestroy(start);
	cudaEventDestroy(end);
	
	return 0;
}

__device__  void getNeighbor(int *input,int row,int col,int rowDim,int colDim, int * neighborList)
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
