


__kernel void MatrMltMatr(__global double* A, __global double* B, __global double* C, __global int* gW)
{
	int cX = get_global_id(0);
	int cY = get_global_id(1);
	int W = *gW;

	double sum = 0.0;
	for (int i=0; i<W; i++)
		sum += A[i + cX*W] * B[cY + i*W];

	C[cX + cY*W] = sum;
}



