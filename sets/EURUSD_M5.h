// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TMA_Band_SVE_True_EURUSD_M5_Params : Stg_TMA_Band_SVE_True_Params {
  Stg_TMA_Band_SVE_True_EURUSD_M5_Params() {
    TMA_Band_SVE_True_LotSize = lot_size = 0;
    TMA_Band_SVE_True_Shift = 0;
    TMA_Band_SVE_True_SignalOpenMethod = signal_open_method = 0;
    TMA_Band_SVE_True_SignalOpenFilterMethod = signal_open_filter = 1;
    TMA_Band_SVE_True_SignalOpenLevel = signal_open_level = 0;
    TMA_Band_SVE_True_SignalOpenBoostMethod = signal_open_boost = 0;
    TMA_Band_SVE_True_SignalCloseMethod = signal_close_method = 0;
    TMA_Band_SVE_True_SignalCloseLevel = signal_close_level = 0;
    TMA_Band_SVE_True_PriceLimitMethod = price_limit_method = 0;
    TMA_Band_SVE_True_PriceLimitLevel = price_limit_level = 2;
    TMA_Band_SVE_True_TickFilterMethod = tick_filter_method = 1;
    TMA_Band_SVE_True_MaxSpread = max_spread = 0;
  }
} stg_tbst_m5;
