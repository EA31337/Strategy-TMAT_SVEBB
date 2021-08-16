/**
 * @file
 * Implements TMA Band SVE True strategy.
 *
 * @see: https://www.forexstrategiesresources.com/trading-system-metatrader-4-iii/397-tma-band-true/
 */

// Includes.
#include <EA31337-classes/Indicator.enum.h>

#include "Indi_SVE_Bollinger_Bands.mqh"

// User input params.
INPUT_GROUP("TMA_SVEBB strategy: strategy params");
INPUT float TMA_SVEBB_LotSize = 0;                // Lot size
INPUT int TMA_SVEBB_SignalOpenMethod = 0;         // Signal open method
INPUT int TMA_SVEBB_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int TMA_SVEBB_SignalOpenFilterTime = 8;     // Signal open filter time
INPUT float TMA_SVEBB_SignalOpenLevel = 0.0f;     // Signal open level
INPUT int TMA_SVEBB_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int TMA_SVEBB_SignalCloseMethod = 0;        // Signal close method
INPUT int TMA_SVEBB_SignalCloseFilter = 0;        // Signal close filter (-127-127)
INPUT float TMA_SVEBB_SignalCloseLevel = 0.0f;    // Signal close level
INPUT int TMA_SVEBB_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float TMA_SVEBB_PriceStopLevel = 2;         // Price stop level
INPUT int TMA_SVEBB_TickFilterMethod = 1;         // Tick filter method
INPUT float TMA_SVEBB_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short TMA_SVEBB_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT float TMA_SVEBB_OrderCloseLoss = 0;         // Order close loss
INPUT float TMA_SVEBB_OrderCloseProfit = 0;       // Order close profit
INPUT int TMA_SVEBB_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("TMA_SVEBB strategy: SVE Bollinger Band indicator params");
INPUT int TMA_SVEBB_Indi_SVE_Bollinger_Bands_TEMAPeriod = 8;           // SVE Band: TEMA Period
INPUT int TMA_SVEBB_Indi_SVE_Bollinger_Bands_SvePeriod = 18;           // SVE Band: SVE Period
INPUT double TMA_SVEBB_Indi_SVE_Bollinger_Bands_BBUpDeviations = 1.6;  // SVE Band: BB Up Deviation
INPUT double TMA_SVEBB_Indi_SVE_Bollinger_Bands_BBDnDeviations = 1.6;  // SVE Band: BB Down Deviation
INPUT int TMA_SVEBB_Indi_SVE_Bollinger_Bands_DeviationsPeriod = 63;    // SVE Band: Deviations Period
INPUT int TMA_SVEBB_Indi_SVE_Bollinger_Bands_Shift = 0;                // SVE Band: Shift
INPUT_GROUP("TMA_SVEBB strategy: TMA True indicator params");
INPUT int TMA_SVEBB_Indi_TMA_True_AtrTimeframe = 0;        // TMA True: Timeframe
INPUT int TMA_SVEBB_Indi_TMA_True_TmaHalfLength = 3;       // TMA True: Half Length
INPUT double TMA_SVEBB_Indi_TMA_True_AtrMultiplier = 1.5;  // TMA True: ATR Multiplier
INPUT int TMA_SVEBB_Indi_TMA_True_AtrPeriod = 6;           // TMA True: ATR Period
INPUT int TMA_SVEBB_Indi_TMA_True_BarsToProcess = 0;       // TMA True: Bars to process
INPUT int TMA_SVEBB_Indi_TMA_True_Shift = 0;               // TMA True: Shift

// Structs.

// Defines struct with default user indicator values.
/*
struct Indi_SVE_Band_Params_Defaults : Indi_SVE_Bollinger_Bands_Params {
  Indi_SVE_Band_Params_Defaults()
      : SVE_Band_Params(::TMA_SVEBB_Indi_TMA_SVEBB_Period,
::TMA_SVEBB_Indi_TMA_SVEBB_MA_Method, ::TMA_SVEBB_Indi_TMA_SVEBB_Applied_Price,
::TMA_SVEBB_Indi_TMA_SVEBB_Shift) {} } Indi_SVE_Bollinger_Bands_defaults;
*/

// Struct to define strategy parameters to override.
struct Stg_TMA_SVEBB_Params : StgParams {
  float TMA_SVEBB_LotSize;
  int TMA_SVEBB_Shift;
  int TMA_SVEBB_SignalOpenMethod;
  int TMA_SVEBB_SignalOpenFilterMethod;
  float TMA_SVEBB_SignalOpenLevel;
  int TMA_SVEBB_SignalOpenBoostMethod;
  int TMA_SVEBB_SignalCloseMethod;
  float TMA_SVEBB_SignalCloseLevel;
  int TMA_SVEBB_PriceStopMethod;
  float TMA_SVEBB_PriceStopLevel;
  int TMA_SVEBB_TickFilterMethod;
  float TMA_SVEBB_MaxSpread;

  // Constructor: Set default param values.
  Stg_TMA_SVEBB_Params(Trade *_trade = NULL, Indicator *_data = NULL, Strategy *_sl = NULL, Strategy *_tp = NULL)
      : StgParams(::TMA_SVEBB_SignalOpenMethod, ::TMA_SVEBB_SignalOpenFilterMethod, ::TMA_SVEBB_SignalOpenLevel,
                  ::TMA_SVEBB_SignalOpenBoostMethod, ::TMA_SVEBB_SignalCloseMethod, ::TMA_SVEBB_SignalCloseFilter,
                  ::TMA_SVEBB_SignalCloseLevel, ::TMA_SVEBB_PriceStopMethod, ::TMA_SVEBB_PriceStopLevel,
                  ::TMA_SVEBB_TickFilterMethod, ::TMA_SVEBB_MaxSpread, ::TMA_SVEBB_Shift) {
    Set(STRAT_PARAM_OCL, TMA_SVEBB_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, TMA_SVEBB_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, TMA_SVEBB_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, TMA_SVEBB_SignalOpenFilterTime);
  }
};

// Structs.

// Includes indicator file.
#include "Indi_TMA_True.mqh"

// Defines struct with default user indicator values.
struct Indi_TMA_True_Params_Defaults : Indi_TMA_True_Params {
  Indi_TMA_True_Params_Defaults()
      : Indi_TMA_True_Params(::TMA_SVEBB_Indi_TMA_True_AtrTimeframe, ::TMA_SVEBB_Indi_TMA_True_TmaHalfLength,
                             ::TMA_SVEBB_Indi_TMA_True_AtrMultiplier, ::TMA_SVEBB_Indi_TMA_True_AtrPeriod,
                             ::TMA_SVEBB_Indi_TMA_True_BarsToProcess, ::TMA_SVEBB_Indi_TMA_True_Shift) {}
} indi_tmat_defaults;

// Defines struct with default user strategy values.
struct Stg_TMA_SVEBB_Params_Defaults : StgParams {
  Stg_TMA_SVEBB_Params_Defaults()
      : StgParams(::TMA_SVEBB_SignalOpenMethod, ::TMA_SVEBB_SignalOpenFilterMethod, ::TMA_SVEBB_SignalOpenLevel,
                  ::TMA_SVEBB_SignalOpenBoostMethod, ::TMA_SVEBB_SignalCloseMethod, ::TMA_SVEBB_SignalCloseFilter,
                  ::TMA_SVEBB_SignalCloseLevel, ::TMA_SVEBB_PriceStopMethod, ::TMA_SVEBB_PriceStopLevel,
                  ::TMA_SVEBB_TickFilterMethod, ::TMA_SVEBB_MaxSpread, ::TMA_SVEBB_Shift) {}
} stg_tmat_defaults;

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_TMA_SVEBB : public Strategy {
 public:
  Stg_TMA_SVEBB(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_TMA_SVEBB *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    Indi_TMA_True_Params _tma_params(TMA_SVEBB_Indi_TMA_True_AtrTimeframe, TMA_SVEBB_Indi_TMA_True_TmaHalfLength,
                                     TMA_SVEBB_Indi_TMA_True_AtrMultiplier, TMA_SVEBB_Indi_TMA_True_AtrPeriod,
                                     TMA_SVEBB_Indi_TMA_True_BarsToProcess, TMA_SVEBB_Indi_TMA_True_Shift);

    Indi_SVE_Bollinger_Bands_Params _sve_params(
        TMA_SVEBB_Indi_SVE_Bollinger_Bands_TEMAPeriod, TMA_SVEBB_Indi_SVE_Bollinger_Bands_SvePeriod,
        TMA_SVEBB_Indi_SVE_Bollinger_Bands_BBUpDeviations, TMA_SVEBB_Indi_SVE_Bollinger_Bands_BBDnDeviations,
        TMA_SVEBB_Indi_SVE_Bollinger_Bands_DeviationsPeriod, TMA_SVEBB_Indi_SVE_Bollinger_Bands_Shift);

    Stg_TMA_SVEBB_Params _stg_params;
#ifdef __config__
    SetParamsByTf<Indi_TMA_True_Params>(_tma_params, _tf, indi_tmat_m1, indi_tmat_m5, indi_tmat_m15, indi_tmat_m30,
                                        indi_tmat_h1, indi_tmat_h4, indi_tmat_h8);

    SetParamsByTf<Stg_TMA_SVEBB_Params>(_stg_params, _tf, stg_tbst_m1, stg_tbst_m5, stg_tbst_m15, stg_tbst_m30,
                                        stg_tbst_h1, stg_tbst_h4, stg_tbst_h4);
#endif
    // Initialize strategy parameters.
    Indicator *_tma = new Indi_TMA_True(_tma_params);
    Indicator *_sve_bb = new Indi_SVE_Bollinger_Bands(_sve_params);
    _stg_params.SetIndicator(_tma, INDI_TMA_TRUE);
    _stg_params.SetIndicator(_sve_bb, INDI_SVE_BB);
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_TMA_SVEBB(_stg_params, _tparams, _cparams, "TMA_SVEBB");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi_tma = GetIndicator(INDI_TMA_TRUE);
    Indicator *_indi_sve = GetIndicator(INDI_SVE_BB);
    bool _result = _indi_tma.GetFlag(INDI_ENTRY_FLAG_IS_VALID) && _indi_sve.GetFlag(INDI_ENTRY_FLAG_IS_VALID);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }

    Chart *_chart = trade.GetChart();

    double lowest_price, highest_price;

    double _change_pc_tma = Math::ChangeInPct(_indi_tma[1][(int)TMA_TRUE_MAIN], _indi_tma[0][(int)TMA_TRUE_MAIN], true);
    double _change_pc_sve = Math::ChangeInPct(_indi_sve[1][(int)SVE_BAND_MAIN], _indi_sve[0][(int)SVE_BAND_MAIN], true);

    switch (_cmd) {
      case ORDER_TYPE_BUY:
        lowest_price = fmin3(_chart.GetLow(CURR), _chart.GetLow(PREV), _chart.GetLow(PPREV));
        _result = (lowest_price < fmax3(_indi_tma[CURR][(int)TMA_TRUE_LOWER], _indi_tma[PREV][(int)TMA_TRUE_LOWER],
                                        _indi_tma[PPREV][(int)TMA_TRUE_LOWER]));
        _result &= _change_pc_tma > _level;
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= fmin(Close[PREV], Close[PPREV]) < _indi_tma[CURR][(int)TMA_TRUE_LOWER];
          if (METHOD(_method, 1))
            _result &= (_indi_tma[CURR][(int)TMA_TRUE_LOWER] > _indi_tma[PPREV][(int)TMA_TRUE_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_tma[CURR][(int)TMA_TRUE_MAIN] > _indi_tma[PPREV][(int)TMA_TRUE_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_tma[CURR][(int)TMA_TRUE_UPPER] > _indi_tma[PPREV][(int)TMA_TRUE_UPPER]);
          if (METHOD(_method, 4)) _result &= Open[CURR] < _indi_tma[CURR][(int)TMA_TRUE_MAIN];
          if (METHOD(_method, 5)) _result &= fmin(Close[PREV], Close[PPREV]) > _indi_tma[CURR][(int)TMA_TRUE_MAIN];
        }

        // Price value was lower than the lower band.
        lowest_price = fmin3(_chart.GetLow(CURR), _chart.GetLow(PREV), _chart.GetLow(PPREV));
        _result = (lowest_price < fmax3(_indi_sve[CURR][(int)SVE_BAND_LOWER], _indi_sve[PREV][(int)SVE_BAND_LOWER],
                                        _indi_sve[PPREV][(int)SVE_BAND_LOWER]));
        _result &= _change_pc_sve > _level;
        if (_result && _method != 0) {
          if (METHOD(_method, 0)) _result &= fmin(Close[PREV], Close[PPREV]) < _indi_sve[CURR][(int)SVE_BAND_LOWER];
          if (METHOD(_method, 1))
            _result &= (_indi_sve[CURR][(int)SVE_BAND_LOWER] > _indi_sve[PPREV][(int)SVE_BAND_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_sve[CURR][(int)SVE_BAND_MAIN] > _indi_sve[PPREV][(int)SVE_BAND_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_sve[CURR][(int)SVE_BAND_UPPER] > _indi_sve[PPREV][(int)SVE_BAND_UPPER]);
          if (METHOD(_method, 4)) _result &= lowest_price < _indi_sve[CURR][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 5)) _result &= Open[CURR] < _indi_sve[CURR][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 6)) _result &= fmin(Close[PREV], Close[PPREV]) > _indi_sve[CURR][(int)SVE_BAND_MAIN];
        }
        break;

      case ORDER_TYPE_SELL:
        // Price value was higher than the upper band.
        highest_price = fmin3(_chart.GetHigh(CURR), _chart.GetHigh(PREV), _chart.GetHigh(PPREV));

        _result = (highest_price > fmin3(_indi_tma[CURR][(int)TMA_TRUE_UPPER], _indi_tma[PREV][(int)TMA_TRUE_UPPER],
                                         _indi_tma[PPREV][(int)TMA_TRUE_UPPER]));
        _result &= _change_pc_tma < -_level;

        _result = (highest_price > fmin3(_indi_sve[CURR][(int)SVE_BAND_UPPER], _indi_sve[PREV][(int)SVE_BAND_UPPER],
                                         _indi_sve[PPREV][(int)SVE_BAND_UPPER]));
        _result &= _change_pc_sve < _level;

        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= fmin(Close[PREV], Close[PPREV]) > _indi_tma[CURR][(int)TMA_TRUE_UPPER];
          if (METHOD(_method, 1))
            _result &= (_indi_tma[CURR][(int)TMA_TRUE_LOWER] < _indi_tma[PPREV][(int)TMA_TRUE_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_tma[CURR][(int)TMA_TRUE_MAIN] < _indi_tma[PPREV][(int)TMA_TRUE_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_tma[CURR][(int)TMA_TRUE_UPPER] < _indi_tma[PPREV][(int)TMA_TRUE_UPPER]);
          if (METHOD(_method, 4)) _result &= Open[CURR] > _indi_tma[CURR][(int)TMA_TRUE_MAIN];
          if (METHOD(_method, 5)) _result &= fmin(Close[PREV], Close[PPREV]) < _indi_tma[CURR][(int)TMA_TRUE_MAIN];
        }

        if (_result && _method != 0) {
          if (METHOD(_method, 0)) _result &= fmin(Close[PREV], Close[PPREV]) > _indi_sve[CURR][(int)SVE_BAND_UPPER];
          if (METHOD(_method, 1))
            _result &= (_indi_sve[CURR][(int)SVE_BAND_LOWER] < _indi_sve[PPREV][(int)SVE_BAND_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_sve[CURR][(int)SVE_BAND_MAIN] < _indi_sve[PPREV][(int)SVE_BAND_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_sve[CURR][(int)SVE_BAND_UPPER] < _indi_sve[PPREV][(int)SVE_BAND_UPPER]);
          if (METHOD(_method, 4)) _result &= highest_price > _indi_sve[CURR][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 5)) _result &= Open[CURR] > _indi_sve[CURR][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 6)) _result &= fmin(Close[PREV], Close[PPREV]) < _indi_sve[CURR][(int)SVE_BAND_MAIN];
        }

        break;
    }

    return _result;
  }
};
