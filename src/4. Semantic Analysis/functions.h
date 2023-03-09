#include <stdio.h>

void simpleIntrst (double principle, double rateY, double timeY, double *amount);
void compoundIntrst (double principle, double rateY, double timeY, int n, double *amount);
void SIPmaturity (double mnthlyInv, double growthRateY, int months, double *maturity);
void SIPmaturityDeets (double mnthlyInv, double growthRateY, int months, double *maturity, double *inv, double *intrst, double *returnPerc);
