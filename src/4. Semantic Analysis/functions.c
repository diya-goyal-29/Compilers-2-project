#include "functions.h"
#include <stdlib.h>
#include <math.h>

void simpleIntrst (double principle, double rateY, double timeY, double *amount)
{
    *amount = principle * rateY * timeY / 100;
}

void compoundIntrst (double principle, double rateY, double timeY, int n, double *amount)
{
    rateY = rateY/100;
    *amount = principle * pow((1 + rateY/n),(n*timeY));
}

void SIPmaturity (double mnthlyInv, double growthRateY, int months, double *maturity)
{
    double i = growthRateY/12/100;
    *maturity = mnthlyInv * (pow(1+i, months)-1) * (1+i)/i;
}

void SIPmaturityDeets (double mnthlyInv, double growthRateY, int months, double *maturity, double *inv, double *intrst, double *returnPerc)
{
    SIPmaturity(mnthlyInv, growthRateY, months, maturity);
    *inv = mnthlyInv * months;
    *intrst = *maturity - *inv;
    *returnPerc = *intrst/ (*inv) * 100;
}