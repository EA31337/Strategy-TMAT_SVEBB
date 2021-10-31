/**
 * @file
 * Implements TMAT SVEBB strategy.
 *
 * @see: https://www.forexstrategiesresources.com/trading-system-metatrader-4-iii/397-tma-band-true/
 */

#include "Indi_SVE_Bollinger_Bands.mqh"

// User input params.
INPUT_GROUP("TMAT_SVEBB strategy: strategy params");
INPUT float TMAT_SVEBB_LotSize = 0;                // Lot size
INPUT int TMAT_SVEBB_SignalOpenMethod = 0;         // Signal open method
INPUT int TMAT_SVEBB_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int TMAT_SVEBB_SignalOpenFilterTime = 3;     // Signal open filter time
INPUT float TMAT_SVEBB_SignalOpenLevel = 0.0f;     // Signal open level
INPUT int TMAT_SVEBB_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int TMAT_SVEBB_SignalCloseMethod = 0;        // Signal close method
INPUT int TMAT_SVEBB_SignalCloseFilter = 0;        // Signal close filter (-127-127)
INPUT float TMAT_SVEBB_SignalCloseLevel = 0.0f;    // Signal close level
INPUT int TMAT_SVEBB_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float TMAT_SVEBB_PriceStopLevel = 2;         // Price stop level
INPUT int TMAT_SVEBB_TickFilterMethod = 32;        // Tick filter method
INPUT float TMAT_SVEBB_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT short TMAT_SVEBB_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT float TMAT_SVEBB_OrderCloseLoss = 80;        // Order close loss
INPUT float TMAT_SVEBB_OrderCloseProfit = 80;      // Order close profit
INPUT int TMAT_SVEBB_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("TMAT_SVEBB strategy: SVE Bollinger Band indicator params");
INPUT int TMAT_SVEBB_Indi_SVEBB_TEMAPeriod = 8;           // SVE Band: TEMA Period
INPUT int TMAT_SVEBB_Indi_SVEBB_SvePeriod = 18;           // SVE Band: SVE Period
INPUT double TMAT_SVEBB_Indi_SVEBB_BBUpDeviations = 1.6;  // SVE Band: BB Up Deviation
INPUT double TMAT_SVEBB_Indi_SVEBB_BBDnDeviations = 1.6;  // SVE Band: BB Down Deviation
INPUT int TMAT_SVEBB_Indi_SVEBB_DeviationsPeriod = 63;    // SVE Band: Deviations Period
INPUT int TMAT_SVEBB_Indi_SVEBB_Shift = 0;                // SVE Band: Shift
INPUT_GROUP("TMAT_SVEBB strategy: TMA True indicator params");
INPUT int TMAT_SVEBB_Indi_TMA_True_Timeframe = 0;           // TMA True: Timeframe
INPUT int TMAT_SVEBB_Indi_TMA_True_HalfLength = 3;          // TMA True: Half Length
INPUT double TMAT_SVEBB_Indi_TMA_True_AtrMultiplier = 1.5;  // TMA True: ATR Multiplier
INPUT int TMAT_SVEBB_Indi_TMA_True_AtrPeriod = 6;           // TMA True: ATR Period
INPUT int TMAT_SVEBB_Indi_TMA_True_BarsToProcess = 0;       // TMA True: Bars to process
INPUT int TMAT_SVEBB_Indi_TMA_True_Shift = 0;               // TMA True: Shift

// Includes indicator file.
#include "Indi_SVE_Bollinger_Bands.mqh"
#include "Indi_TMA_True.mqh"

// Structs.

// Struct to define strategy parameters to override.
struct Stg_TMAT_SVEBB_Params : StgParams {
  float TMAT_SVEBB_LotSize;
  int TMAT_SVEBB_Shift;
  int TMAT_SVEBB_SignalOpenMethod;
  int TMAT_SVEBB_SignalOpenFilterMethod;
  float TMAT_SVEBB_SignalOpenLevel;
  int TMAT_SVEBB_SignalOpenBoostMethod;
  int TMAT_SVEBB_SignalCloseMethod;
  float TMAT_SVEBB_SignalCloseLevel;
  int TMAT_SVEBB_PriceStopMethod;
  float TMAT_SVEBB_PriceStopLevel;
  int TMAT_SVEBB_TickFilterMethod;
  float TMAT_SVEBB_MaxSpread;

  // Constructor: Set default param values.
  Stg_TMAT_SVEBB_Params(Trade *_trade = NULL, IndicatorBase *_data = NULL, Strategy *_sl = NULL, Strategy *_tp = NULL)
      : StgParams(::TMAT_SVEBB_SignalOpenMethod, ::TMAT_SVEBB_SignalOpenFilterMethod, ::TMAT_SVEBB_SignalOpenLevel,
                  ::TMAT_SVEBB_SignalOpenBoostMethod, ::TMAT_SVEBB_SignalCloseMethod, ::TMAT_SVEBB_SignalCloseFilter,
                  ::TMAT_SVEBB_SignalCloseLevel, ::TMAT_SVEBB_PriceStopMethod, ::TMAT_SVEBB_PriceStopLevel,
                  ::TMAT_SVEBB_TickFilterMethod, ::TMAT_SVEBB_MaxSpread, ::TMAT_SVEBB_Shift) {
    Set(STRAT_PARAM_LS, TMAT_SVEBB_LotSize);
    Set(STRAT_PARAM_OCL, TMAT_SVEBB_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, TMAT_SVEBB_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, TMAT_SVEBB_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, TMAT_SVEBB_SignalOpenFilterTime);
  }
};

// Defines struct with default user strategy values.
struct Stg_TMAT_SVEBB_Params_Defaults : StgParams {
  Stg_TMAT_SVEBB_Params_Defaults()
      : StgParams(::TMAT_SVEBB_SignalOpenMethod, ::TMAT_SVEBB_SignalOpenFilterMethod, ::TMAT_SVEBB_SignalOpenLevel,
                  ::TMAT_SVEBB_SignalOpenBoostMethod, ::TMAT_SVEBB_SignalCloseMethod, ::TMAT_SVEBB_SignalCloseFilter,
                  ::TMAT_SVEBB_SignalCloseLevel, ::TMAT_SVEBB_PriceStopMethod, ::TMAT_SVEBB_PriceStopLevel,
                  ::TMAT_SVEBB_TickFilterMethod, ::TMAT_SVEBB_MaxSpread, ::TMAT_SVEBB_Shift) {}
};

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

class Stg_TMAT_SVEBB : public Strategy {
 public:
  Stg_TMAT_SVEBB(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_TMAT_SVEBB *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    Stg_TMAT_SVEBB_Params_Defaults stg_tmat_svebb_defaults;
    StgParams _stg_params(stg_tmat_svebb_defaults);
#ifdef __config__
    SetParamsByTf<Stg_TMAT_SVEBB_Params>(_stg_params, _tf, stg_tmat_svebb_m1, stg_tmat_svebb_m5, stg_tmat_svebb_m15,
                                         stg_tmat_svebb_m30, stg_tmat_svebb_h1, stg_tmat_svebb_h4, stg_tmat_svebb_h4);
#endif
    // Initialize strategy parameters.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_TMAT_SVEBB(_stg_params, _tparams, _cparams, "TMAT_SVEBB");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiSVEBBParams _svebb_params(::TMAT_SVEBB_Indi_SVEBB_TEMAPeriod, ::TMAT_SVEBB_Indi_SVEBB_SvePeriod,
                                  ::TMAT_SVEBB_Indi_SVEBB_BBUpDeviations, ::TMAT_SVEBB_Indi_SVEBB_BBDnDeviations,
                                  ::TMAT_SVEBB_Indi_SVEBB_DeviationsPeriod, ::TMAT_SVEBB_Indi_SVEBB_Shift);
    _svebb_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_SVE_Bollinger_Bands(_svebb_params), INDI_SVE_BB);

    IndiTMATrueParams _tmat_params(::TMAT_SVEBB_Indi_TMA_True_Timeframe, ::TMAT_SVEBB_Indi_TMA_True_HalfLength,
                                   ::TMAT_SVEBB_Indi_TMA_True_AtrMultiplier, ::TMAT_SVEBB_Indi_TMA_True_AtrPeriod,
                                   ::TMAT_SVEBB_Indi_TMA_True_BarsToProcess, ::TMAT_SVEBB_Indi_TMA_True_Shift);
    _tmat_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_TMA_True(_tmat_params), INDI_TMA_TRUE);
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_TMA_True *_indi_tma = GetIndicator(INDI_TMA_TRUE);
    Indi_SVE_Bollinger_Bands *_indi_sve = GetIndicator(INDI_SVE_BB);
    bool _result =
        _indi_tma.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi_sve.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 2);
    _result &=
        _indi_sve.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi_sve.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 2);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }

    Chart *_chart = (Chart *)_indi_tma;

    double lowest_price, highest_price;
    double _change_pc_tma = Math::ChangeInPct(_indi_tma[1][(int)TMA_TRUE_MAIN], _indi_tma[0][(int)TMA_TRUE_MAIN], true);
    double _change_pc_sve = Math::ChangeInPct(_indi_sve[1][(int)SVE_BAND_MAIN], _indi_sve[0][(int)SVE_BAND_MAIN], true);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        lowest_price = fmin3(_chart.GetLow(CURR), _chart.GetLow(PREV), _chart.GetLow(PPREV));
        _result =
            (lowest_price < fmax3(_indi_tma[_shift][(int)TMA_TRUE_LOWER], _indi_tma[_shift + 1][(int)TMA_TRUE_LOWER],
                                  _indi_tma[_shift + 2][(int)TMA_TRUE_LOWER]));
        _result &= _change_pc_tma > _level;
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) < _indi_tma[_shift][(int)TMA_TRUE_LOWER];
          if (METHOD(_method, 1))
            _result &= (_indi_tma[_shift][(int)TMA_TRUE_LOWER] > _indi_tma[_shift + 2][(int)TMA_TRUE_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_tma[_shift][(int)TMA_TRUE_MAIN] > _indi_tma[_shift + 2][(int)TMA_TRUE_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_tma[_shift][(int)TMA_TRUE_UPPER] > _indi_tma[_shift + 2][(int)TMA_TRUE_UPPER]);
          if (METHOD(_method, 4)) _result &= Open[_shift] < _indi_tma[_shift][(int)TMA_TRUE_MAIN];
          if (METHOD(_method, 5))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) > _indi_tma[_shift][(int)TMA_TRUE_MAIN];
        }

        // Price value was lower than the lower band.
        lowest_price = fmin3(_chart.GetLow(CURR), _chart.GetLow(PREV), _chart.GetLow(PPREV));
        _result =
            (lowest_price < fmax3(_indi_sve[_shift][(int)SVE_BAND_LOWER], _indi_sve[_shift + 1][(int)SVE_BAND_LOWER],
                                  _indi_sve[_shift + 2][(int)SVE_BAND_LOWER]));
        _result &= _change_pc_sve > _level;
        if (_result && _method != 0) {
          if (METHOD(_method, 0))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) < _indi_sve[_shift][(int)SVE_BAND_LOWER];
          if (METHOD(_method, 1))
            _result &= (_indi_sve[_shift][(int)SVE_BAND_LOWER] > _indi_sve[_shift + 2][(int)SVE_BAND_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_sve[_shift][(int)SVE_BAND_MAIN] > _indi_sve[_shift + 2][(int)SVE_BAND_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_sve[_shift][(int)SVE_BAND_UPPER] > _indi_sve[_shift + 2][(int)SVE_BAND_UPPER]);
          if (METHOD(_method, 4)) _result &= lowest_price < _indi_sve[_shift][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 5)) _result &= Open[_shift] < _indi_sve[_shift][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 6))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) > _indi_sve[_shift][(int)SVE_BAND_MAIN];
        }
        break;

      case ORDER_TYPE_SELL:
        // Price value was higher than the upper band.
        highest_price = fmin3(_chart.GetHigh(CURR), _chart.GetHigh(PREV), _chart.GetHigh(PPREV));

        _result =
            (highest_price > fmin3(_indi_tma[_shift][(int)TMA_TRUE_UPPER], _indi_tma[_shift + 1][(int)TMA_TRUE_UPPER],
                                   _indi_tma[_shift + 2][(int)TMA_TRUE_UPPER]));
        _result &= _change_pc_tma < -_level;

        _result =
            (highest_price > fmin3(_indi_sve[_shift][(int)SVE_BAND_UPPER], _indi_sve[_shift + 1][(int)SVE_BAND_UPPER],
                                   _indi_sve[_shift + 2][(int)SVE_BAND_UPPER]));
        _result &= _change_pc_sve < _level;

        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) > _indi_tma[_shift][(int)TMA_TRUE_UPPER];
          if (METHOD(_method, 1))
            _result &= (_indi_tma[_shift][(int)TMA_TRUE_LOWER] < _indi_tma[_shift + 2][(int)TMA_TRUE_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_tma[_shift][(int)TMA_TRUE_MAIN] < _indi_tma[_shift + 2][(int)TMA_TRUE_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_tma[_shift][(int)TMA_TRUE_UPPER] < _indi_tma[_shift + 2][(int)TMA_TRUE_UPPER]);
          if (METHOD(_method, 4)) _result &= Open[_shift] > _indi_tma[_shift][(int)TMA_TRUE_MAIN];
          if (METHOD(_method, 5))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) < _indi_tma[_shift][(int)TMA_TRUE_MAIN];
        }

        if (_result && _method != 0) {
          if (METHOD(_method, 0))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) > _indi_sve[_shift][(int)SVE_BAND_UPPER];
          if (METHOD(_method, 1))
            _result &= (_indi_sve[_shift][(int)SVE_BAND_LOWER] < _indi_sve[_shift + 2][(int)SVE_BAND_LOWER]);
          if (METHOD(_method, 2))
            _result &= (_indi_sve[_shift][(int)SVE_BAND_MAIN] < _indi_sve[_shift + 2][(int)SVE_BAND_MAIN]);
          if (METHOD(_method, 3))
            _result &= (_indi_sve[_shift][(int)SVE_BAND_UPPER] < _indi_sve[_shift + 2][(int)SVE_BAND_UPPER]);
          if (METHOD(_method, 4)) _result &= highest_price > _indi_sve[_shift][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 5)) _result &= Open[_shift] > _indi_sve[_shift][(int)SVE_BAND_MAIN];
          if (METHOD(_method, 6))
            _result &= fmin(Close[_shift + 1], Close[_shift + 2]) < _indi_sve[_shift][(int)SVE_BAND_MAIN];
        }

        break;
    }

    return _result;
  }
};
