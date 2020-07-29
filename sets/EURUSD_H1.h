// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Demo_EURUSD_H1_Params : Stg_Demo_Params {
  Stg_Demo_EURUSD_H1_Params() {
    Demo_LotSize = lot_size = 0;
    Demo_Shift = 0;
    Demo_SignalOpenMethod = signal_open_method = 0;
    Demo_SignalOpenFilterMethod = signal_open_filter = 1;
    Demo_SignalOpenLevel = signal_open_level = 0;
    Demo_SignalOpenBoostMethod = signal_open_boost = 0;
    Demo_SignalCloseMethod = signal_close_method = 0;
    Demo_SignalCloseLevel = signal_close_level = 0;
    Demo_PriceLimitMethod = price_limit_method = 0;
    Demo_PriceLimitLevel = price_limit_level = 2;
    Demo_TickFilterMethod = tick_filter_method = 1;
    Demo_MaxSpread = max_spread = 0;
  }
} stg_demo_h1;
