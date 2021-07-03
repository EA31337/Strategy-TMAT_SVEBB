// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_TMA_True_Params_M30 : Indi_TMA_True_Params {
  Indi_TMA_True_Params_M30() : Indi_TMA_True_Params(indi_tmat_defaults, PERIOD_M30) { shift = 0; }
} indi_tmat_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TMA_Band_SVE_True_EURUSD_M30_Params : Stg_TMA_Band_SVE_True_Params {
  Stg_TMA_Band_SVE_True_EURUSD_M30_Params() {
    TMA_Band_SVE_True_LotSize = lot_size = 0;
    TMA_Band_SVE_True_Shift = 0;
    TMA_Band_SVE_True_SignalOpenMethod = signal_open_method = 2;
    TMA_Band_SVE_True_SignalOpenFilterMethod = signal_open_filter = 32;
    TMA_Band_SVE_True_SignalOpenLevel = signal_open_level = (float)0;
    TMA_Band_SVE_True_SignalOpenBoostMethod = signal_open_boost = 0;
    TMA_Band_SVE_True_SignalCloseMethod = signal_close_method = 2;
    TMA_Band_SVE_True_SignalCloseLevel = signal_close_level = (float)0;
    TMA_Band_SVE_True_PriceStopMethod = price_profit_method = 60;
    TMA_Band_SVE_True_PriceStopLevel = price_profit_level = (float)6;
    TMA_Band_SVE_True_PriceStopMethod = price_stop_method = 60;
    TMA_Band_SVE_True_PriceStopLevel = price_stop_level = (float)6;
    TMA_Band_SVE_True_TickFilterMethod = tick_filter_method = 1;
    TMA_Band_SVE_True_MaxSpread = max_spread = 0;
  }
} stg_tbst_m30;
