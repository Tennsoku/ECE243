#include <stdio.h>
#include <math.h>
int get_cos_ratio (int G,int Gx)
{
int Return_Ratio=0;
double Precise_Ratio=0;
Precise_Ratio= (sqrt(G*G-Gx*Gx)/G);
Precise_Ratio= Precise_Ratio*1000;
Return_Ratio= Precise_Ratio;
return Return_Ratio;
}