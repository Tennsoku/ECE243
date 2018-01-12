#include <stdio.h>
#include <math.h>
int get_sin_ratio (int G,int Gx)
{
int Return_Ratio;
double Precise_Ratio=0;
Precise_Ratio= (Gx/G);
Precise_Ratio= Precise_Ratio*1000;
Return_Ratio= Precise_Ratio;
return Return_Ratio;

}