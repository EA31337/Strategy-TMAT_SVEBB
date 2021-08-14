/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_color1 DarkGray
#property indicator_color2 DarkGray
#property indicator_color3 DarkGray
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>

// Defines macros.
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Includes the main file.
#include "TMA_True.mq4"

// Custom indicator initialization function.
void OnInit() {
  init();
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 0);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, 0);
  if (!ArrayGetAsSeries(gadblMid)) {
    ArraySetAsSeries(gadblMid, true);
    ArraySetAsSeries(gadblUpper, true);
    ArraySetAsSeries(gadblLower, true);
  }
}

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}
