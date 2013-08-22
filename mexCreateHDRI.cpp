/*****************************************************************************
 * mexCreateHDRI.cpp
 * 
 * This is a mex interface to create high dynamic range image from multiple captures
 * 
 * The syntaxes are:
 *
 *     hdri = mexCreateHDRI (images, exposures, saturation, motionFlag) 
 *   
 * Input
 *	  images: Y by X by N array where N is the number of captures
 *	  exposures:  exposure for each capture
 %    saturation: saturation threshold
 %    motionFlag: motion detection or not
 *
 * Output
 *	  hdri: Y by X matrix 
 * 
 *
 * Author: Feng Xiao, Stanford University
 * Last update: 07-25-2002
 *
 *************************************************************************/

#include <stdio.h>
#include <string.h>
#include "mex.h"

#define MAX_EXPOSURES 16
#define UINT16 unsigned short
#define SATURATION 950

double *g_pExp;
int g_totalExp;
double g_saturation;

double pixelProc(double *pixData);

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]) 
{ 
	UINT16 *pIm;
	double *pHDRI, pixData[MAX_EXPOSURES];
	int height, width, pix, cap;
	int ndims, *pdims;
	long frameSize, ind[MAX_EXPOSURES];
	if (nrhs==0)
	{
	    mexErrMsgTxt("Usage: [createHDRI(im,exposure,[saturation]) ");
	    return;
	}
	if (nrhs < 2 || nrhs > 3)
		mexErrMsgTxt("Two inputs required!");
	if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments!");
	if ( !mxIsNumeric(prhs[0]) | !mxIsNumeric(prhs[1]) )
		mexErrMsgTxt("All inputs must be numeric!");
	
	ndims = mxGetNumberOfDimensions(prhs[0]);
	if ( (ndims<2) || (ndims > 3) )
		mexErrMsgTxt("First input must be 2-D or 3-D matrix");
	    
	pdims = (int *)mxGetDimensions(prhs[0]);
	g_totalExp = mxGetN(prhs[1]);
	
	if ( g_totalExp >= MAX_EXPOSURES)
	{
	    mexPrintf("Maximum exposures allowed: %d ",MAX_EXPOSURES);
	    mexErrMsgTxt("\n");
	}
	    
	if ( g_totalExp != pdims[ndims-1] )
	    mexErrMsgTxt("Last dimension of the first input must equal to the number of exposures");

	height = pdims[0];
	if (ndims<3)
	    width = 1;
	else width = pdims[1];

	// create output data 
	plhs[0] = mxCreateDoubleMatrix(height,width,mxREAL);
    
	pIm  = (UINT16 *)mxGetPr(prhs[0]);
	g_pExp = (double *)mxGetPr(prhs[1]);
    pIm  = (UINT16 *)mxGetPr(prhs[0]);

	if (nrhs == 3)
	    g_saturation = mxGetScalar(prhs[2]);
	else
	    g_saturation = SATURATION;

	pHDRI= (double *)mxGetPr(plhs[0]);
	
	frameSize = width*height;
	
	for (cap =0; cap<g_totalExp; cap++)
	    ind[cap]=cap*frameSize;
	    
	for(pix=0; pix<frameSize; pix++, pIm++)
	{
		for(cap=0; cap<g_totalExp; cap++)
		    pixData[cap]=pIm[ind[cap]];
		*pHDRI++=pixelProc(pixData);
	}
}

double pixelProc(double *pixData)
{
	int i,count,ind;
	double norm[MAX_EXPOSURES], ws[MAX_EXPOSURES],total_ws,sum,mean,min,tmp;
	
	// throw away frames after the first saturation
	
	count=0; total_ws=0; sum=0; 
	for(i=0; i<g_totalExp; i++)
	{
	    if (pixData[i]<g_saturation)
	    {
	        norm[i]=pixData[i]/g_pExp[i];
	        ws[i] = i+1; 
	        total_ws+=ws[i];
	        sum+= norm[i]*ws[i];
	    }
	    else 
			break;
	}
    
    ind=i-1;
    if (ind<0)
        ind=0;

	//return ind; 
	return pixData[ind]/g_pExp[ind];
	
/*	mean = sum/total_ws;
	ind = 0; count= i;
	
	for(i=0,min=1000; i<count; i++)
	{
	    tmp = (norm[i]-mean)/ws[i];
	    tmp = tmp>0 ? tmp : -tmp;
	    if (tmp<min)
	    {
	        ind = i;
	        min=tmp;
	    }
	}
	
	return pixData[ind]/g_pExp[ind]*50000; */
}