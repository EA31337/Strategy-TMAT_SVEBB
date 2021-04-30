/**
 * @file
 * Implements indicator under MQL5.
 */

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 5

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>

// Defines macros.
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  ArraySetAsSeries(gadblMid, true);
  ArraySetAsSeries(gadblUpper, true);
  ArraySetAsSeries(gadblLower, true);

  if (begin > 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, begin);
  if (begin > 0) PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, begin);
  if (begin > 0) PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, begin);
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}

// Includes the main file.
#include "TMA_True.mq4"
