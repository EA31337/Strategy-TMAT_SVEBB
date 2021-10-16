//+------------------------------------------------------------------+
//|                                      Copyright 2016-2021, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Prevents processing the same indicator file twice.
#ifndef INDI_TMA_TRUE_MQH
#define INDI_TMA_TRUE_MQH

// Indicator line identifiers used in the indicator.
enum ENUM_TMA_TRUE_MODE {
  TMA_TRUE_MAIN = 0,   // Main line.
  TMA_TRUE_UPPER = 1,  // Upper limit.
  TMA_TRUE_LOWER = 2,  // Lower limit.
  FINAL_TMA_TRUE_MODE_ENTRY,
};

// Structs.

// Defines struct to store indicator parameter values.
struct Indi_TMA_True_Params : public IndicatorParams {
  // Indicator params.
  int atr_tf;
  int half_length;
  double atr_multiplier;
  int atr_period;
  int bars_to_process;
  // Struct constructors.
  Indi_TMA_True_Params(int _atr_tf = 0, int _half_length = 3, double _atr_multiplier = 0.5, int _atr_period = 6,
                       int _bars_to_process = 0, int _shift = 0)
      : atr_tf(_atr_tf),
        half_length(_half_length),
        atr_multiplier(_atr_multiplier),
        atr_period(_atr_period),
        bars_to_process(_bars_to_process),
        IndicatorParams(INDI_TMA_TRUE, FINAL_TMA_TRUE_MODE_ENTRY, TYPE_DOUBLE) {
#ifdef __resource__
    custom_indi_name = "::Indicators\\TMA_True";
#else
    custom_indi_name = "TMA_True";
#endif
    SetDataSourceType(IDATA_ICUSTOM);
  };

  Indi_TMA_True_Params(Indi_TMA_True_Params &_params, ENUM_TIMEFRAMES _tf) {
    this = _params;
    tf = _tf;
  }
  // Getters.
  int GetATRTimeframe() { return atr_tf; }
  int GetHalfLength() { return half_length; }
  double GetAtrMultiplier() { return atr_multiplier; }
  int GetAtrPeriod() { return atr_period; }
  int GetBarsToProcess() { return bars_to_process; }
  // Setters.
  void SetATRTimeframe(int _value) { atr_tf = _value; }
  void SetHalfLength(int _value) { half_length = _value; }
  void SetAtrMultiplier(double _value) { atr_multiplier = _value; }
  void SetAtrPeriod(int _value) { atr_period = _value; }
  void SetBarsToProcess(int _value) { bars_to_process = _value; }
};

/**
 * Implements indicator class.
 */
class Indi_TMA_True : public Indicator<Indi_TMA_True_Params> {
 public:
  /**
   * Class constructor.
   */
  Indi_TMA_True(Indi_TMA_True_Params &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<Indi_TMA_True_Params>(_p, _indi_src) {}
  Indi_TMA_True(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_TMA_TRUE, _tf){};

  /**
   * Gets indicator's params.
   */
  // Indi_TMA_True_Params GetIndiParams() const { return params; }

  /**
   * Returns the indicator's value.
   *
   */
  virtual double GetValue(int _mode = 0, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (iparams.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         iparams.custom_indi_name, (int)iparams.tf.GetTf(), iparams.GetHalfLength(),
                         iparams.GetAtrMultiplier(), iparams.GetAtrPeriod(), iparams.GetBarsToProcess(), false, _mode,
                         _shift);
        break;
      default:
        SetUserError(ERR_USER_NOT_SUPPORTED);
        _value = EMPTY_VALUE;
    }
    istate.is_changed = false;
    istate.is_ready = _LastError == ERR_NO_ERROR;
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<Indi_TMA_True_Params>::IsValidEntry(_entry) && _entry.GetMin<double>() > 0 &&
           _entry.values[TMA_TRUE_UPPER].IsGt<double>(_entry[(int)TMA_TRUE_LOWER]);
  }
};

#endif  // INDI_TMA_TRUE_MQH
