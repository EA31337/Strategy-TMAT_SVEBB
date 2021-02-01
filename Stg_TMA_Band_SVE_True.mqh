/**
 * @file
 * Implements TMA Band SVE True strategy.
 *
 * @see: https://www.forexstrategiesresources.com/trading-system-metatrader-4-iii/397-tma-band-true/
 */

// Includes.
#include "Indi_SVE_Bollinger_Band.mqh"
#include "Indi_TMA_True.mqh"

// User input params.
INPUT string __TMA_Band_SVE_True_Parameters__ = "-- TMA_Band_SVE_True strategy params --";  // >>> TMA Band SVE True <<<
INPUT float TMA_Band_SVE_True_LotSize = 0;                                                  // Lot size
INPUT int TMA_Band_SVE_True_SignalOpenMethod = 0;                                           // Signal open method
INPUT int TMA_Band_SVE_True_SignalOpenFilterMethod = 1;                                     // Signal open filter method
INPUT float TMA_Band_SVE_True_SignalOpenLevel = 0.0f;                                       // Signal open level
INPUT int TMA_Band_SVE_True_SignalOpenBoostMethod = 0;                                      // Signal open boost method
INPUT int TMA_Band_SVE_True_SignalCloseMethod = 0;                                          // Signal close method
INPUT float TMA_Band_SVE_True_SignalCloseLevel = 0.0f;                                      // Signal close level
INPUT int TMA_Band_SVE_True_PriceStopMethod = 0;                                            // Price stop method
INPUT float TMA_Band_SVE_True_PriceStopLevel = 2;                                           // Price stop level
INPUT int TMA_Band_SVE_True_TickFilterMethod = 1;                                           // Tick filter method
INPUT float TMA_Band_SVE_True_MaxSpread = 4.0;     // Max spread to trade (in pips)
INPUT int TMA_Band_SVE_True_Shift = 0;             // Shift (relative to the current bar, 0 - default)
INPUT int TMA_Band_SVE_True_OrderCloseTime = -20;  // Order close time in mins (>0) or bars (<0)
// Indicators params.
INPUT string _TMA_Band_SVE_True_Indi_SVE_Bollinger_Band_Parameters__ =
    "-- TMA_Band_SVE_True strategy: SVE Bollinger Band indicator params --";  // >>> TMA_Band_SVE_True strategy: SVE
                                                                              // Bollinger Band indicator <<<
INPUT int TMA_Band_SVE_True_Indi_SVE_Bollinger_Band_TEMAPeriod = 8;           // SVE Band: TEMA Period
INPUT int TMA_Band_SVE_True_Indi_SVE_Bollinger_Band_SvePeriod = 18;           // SVE Band: SVE Period
INPUT double TMA_Band_SVE_True_Indi_SVE_Bollinger_Band_BBUpDeviations = 1.6;  // SVE Band: BB Up Deviation
INPUT double TMA_Band_SVE_True_Indi_SVE_Bollinger_Band_BBDnDeviations = 1.6;  // SVE Band: BB Down Deviation
INPUT int TMA_Band_SVE_True_Indi_SVE_Bollinger_Band_DeviationsPeriod = 63;    // SVE Band: Deviations Period
INPUT int TMA_Band_SVE_True_Indi_SVE_Bollinger_Band_Shift = 0;                // SVE Band: Shift
INPUT string _TMA_Band_SVE_True_Indi_TMA_True_Parameters__ =
    "-- TMA_Band_SVE_True strategy: TMA True indicator params --";  // >>> TMA_Band_SVE_True strategy: TMA True
                                                                    // indicator <<<
INPUT int TMA_Band_SVE_True_Indi_TMA_True_AtrTimeframe = 0;         // TMA True: Timeframe
INPUT int TMA_Band_SVE_True_Indi_TMA_True_TmaHalfLength = 3;        // TMA True: Half Length
INPUT double TMA_Band_SVE_True_Indi_TMA_True_AtrMultiplier = 0.5;   // TMA True: ATR Multiplier
INPUT int TMA_Band_SVE_True_Indi_TMA_True_AtrPeriod = 6;            // TMA True: ATR Period
INPUT int TMA_Band_SVE_True_Indi_TMA_True_BarsToProcess = 0;        // TMA True: Bars to process

// Structs.

// Defines struct with default user indicator values.
/*
struct Indi_SVE_Band_Params_Defaults : SVEBandParams {
  Indi_SVE_Band_Params_Defaults()
      : SVE_Band_Params(::TMA_Band_SVE_True_Indi_TMA_Band_SVE_True_Period,
::TMA_Band_SVE_True_Indi_TMA_Band_SVE_True_MA_Method, ::TMA_Band_SVE_True_Indi_TMA_Band_SVE_True_Applied_Price,
::TMA_Band_SVE_True_Indi_TMA_Band_SVE_True_Shift) {} } indi_sveband_defaults;
*/

// Struct to define strategy parameters to override.
struct Stg_TMA_Band_SVE_True_Params : StgParams {
  float TMA_Band_SVE_True_LotSize;
  int TMA_Band_SVE_True_Shift;
  int TMA_Band_SVE_True_SignalOpenMethod;
  int TMA_Band_SVE_True_SignalOpenFilterMethod;
  float TMA_Band_SVE_True_SignalOpenLevel;
  int TMA_Band_SVE_True_SignalOpenBoostMethod;
  int TMA_Band_SVE_True_SignalCloseMethod;
  float TMA_Band_SVE_True_SignalCloseLevel;
  int TMA_Band_SVE_True_PriceStopMethod;
  float TMA_Band_SVE_True_PriceStopLevel;
  int TMA_Band_SVE_True_TickFilterMethod;
  float TMA_Band_SVE_True_MaxSpread;

  // Constructor: Set default param values.
  Stg_TMA_Band_SVE_True_Params(Trade *_trade = NULL, Indicator *_data = NULL, Strategy *_sl = NULL,
                               Strategy *_tp = NULL)
      : StgParams(_trade, _data, _sl, _tp),
        TMA_Band_SVE_True_LotSize(::TMA_Band_SVE_True_LotSize),
        TMA_Band_SVE_True_Shift(::TMA_Band_SVE_True_Shift),
        TMA_Band_SVE_True_SignalOpenMethod(::TMA_Band_SVE_True_SignalOpenMethod),
        TMA_Band_SVE_True_SignalOpenFilterMethod(::TMA_Band_SVE_True_SignalOpenFilterMethod),
        TMA_Band_SVE_True_SignalOpenLevel(::TMA_Band_SVE_True_SignalOpenLevel),
        TMA_Band_SVE_True_SignalOpenBoostMethod(::TMA_Band_SVE_True_SignalOpenBoostMethod),
        TMA_Band_SVE_True_SignalCloseMethod(::TMA_Band_SVE_True_SignalCloseMethod),
        TMA_Band_SVE_True_SignalCloseLevel(::TMA_Band_SVE_True_SignalCloseLevel),
        TMA_Band_SVE_True_PriceStopMethod(::TMA_Band_SVE_True_PriceStopMethod),
        TMA_Band_SVE_True_PriceStopLevel(::TMA_Band_SVE_True_PriceStopLevel),
        TMA_Band_SVE_True_TickFilterMethod(::TMA_Band_SVE_True_TickFilterMethod),
        TMA_Band_SVE_True_MaxSpread(::TMA_Band_SVE_True_MaxSpread) {}
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_TMA_Band_SVE_True : public Strategy {
 public:
  Stg_TMA_Band_SVE_True(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_TMA_Band_SVE_True *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL,
                                     ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_TMA_Band_SVE_True_Params _stg_params;
#ifdef __config__
    SetParamsByTf<Stg_TMA_Band_SVE_True_Params>(_stg_params, _tf, stg_tbst_m1, stg_tbst_m5, stg_tbst_m15, stg_tbst_m30,
                                                stg_tbst_h1, stg_tbst_h4, stg_tbst_h4);
#endif
    // Initialize strategy parameters.
    // TBSTIndiParams tbst_params(_tf);
    _stg_params.GetLog().SetLevel(_log_level);
    //_stg_params.SetIndicator(new Indi_TMA_Band_SVE_True(tbst_params));
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_TMA_Band_SVE_True(_stg_params, "TMA_Band_SVE_True");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        break;
    }
    return _result;
  }

  /**
   * Gets price stop value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    // Indicator *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    // int _bar_count = (int)_level * 10;
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    // ENUM_APPLIED_PRICE _ap = _direction > 0 ? PRICE_HIGH : PRICE_LOW;
    switch (_method) {
      case 1:
        // Trailing stop here.
        break;
    }
    return (float)_result;
  }
};
