// Defines indicator's parameter values for the given pair symbol and timeframe.
struct IndiTMATrueParams_H4 : IndiTMATrueParams {
  IndiTMATrueParams_H4() : IndiTMATrueParams(stg_tmat_svebb_indi_tmat_defaults, PERIOD_H4) { shift = 0; }
} indi_tmat_h4;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_TMAT_SVEBB_EURUSD_H4_Params : Stg_TMAT_SVEBB_Params {
  Stg_TMAT_SVEBB_EURUSD_H4_Params() {
    TMAT_SVEBB_LotSize = lot_size = 0;
    TMAT_SVEBB_Shift = 0;
    TMAT_SVEBB_SignalOpenMethod = signal_open_method = 2;
    TMAT_SVEBB_SignalOpenLevel = signal_open_level = (float)0;
    TMAT_SVEBB_SignalOpenBoostMethod = signal_open_boost = 0;
    TMAT_SVEBB_SignalCloseMethod = signal_close_method = 2;
    TMAT_SVEBB_SignalCloseLevel = signal_close_level = (float)0;
    TMAT_SVEBB_PriceStopMethod = price_profit_method = 60;
    TMAT_SVEBB_PriceStopLevel = price_profit_level = (float)6;
    TMAT_SVEBB_PriceStopMethod = price_stop_method = 60;
    TMAT_SVEBB_PriceStopLevel = price_stop_level = (float)6;
    TMAT_SVEBB_TickFilterMethod = tick_filter_method = 1;
    TMAT_SVEBB_MaxSpread = max_spread = 0;
  }
} stg_tmat_svebb_h4;
