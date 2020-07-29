//+------------------------------------------------------------------+
//|                                      Copyright 2016-2020, kenorb |
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

// Includes.
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>

// Indicator line identifiers used in TMATrue.
enum ENUM_TMA_TRUE_LINE {
  TMA_TRUE_BASE = 0,   // Main line.
  TMA_TRUE_UPPER = 1,  // Upper limit.
  TMA_TRUE_LOWER = 2,  // Lower limit.
  FINAL_TMA_TRUE_LINE_ENTRY,
};

// Structs.
struct TMATrueParams : IndicatorParams {
  // Indicator params.
  int AtrTimeframe;
  int TmaHalfLength;
  double AtrMultiplier;
  int AtrPeriod;
  int BarsToProcess;
  // Struct constructor.
  void TMATrueParams(int _atr_tf, int _tma_hl, double _atr_mul, int _atr_period, int _bars, int _shift = 0)
      : AtrTimeframe(_atr_tf),
        TmaHalfLength(_tma_hl),
        AtrMultiplier(_atr_mul),
        AtrPeriod(_atr_period),
        BarsToProcess(_bars) {
    max_modes = FINAL_TMA_TRUE_LINE_ENTRY;
    custom_indi_name = "Indicators\\TMA_True";
    shift = _shift;
    SetDataValueType(TYPE_DOUBLE);
  };
  // Getters.
  int GetAtrTimeframe() { return AtrTimeframe; }
  int GetTmaHalfLength() { return TmaHalfLength; }
  double GetAtrMultiplier() { return AtrMultiplier; }
  int GetAtrPeriod() { return AtrPeriod; }
  int GetBarsToProcess() { return BarsToProcess; }
  // Setters.
  void SetAtrTimeframe(int _value) { AtrTimeframe = _value; }
  void SetTmaHalfLength(int _value) { TmaHalfLength = _value; }
  void SetAtrMultiplier(double _value) { AtrMultiplier = _value; }
  void SetAtrPeriod(int _value) { AtrPeriod = _value; }
  void SetBarsToProcess(int _value) { BarsToProcess = _value; }
};

/**
 * Implements indicator class.
 */
class Indi_TMATrue : public Indicator {
 protected:
  // Structs.
  TMATrueParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_TMATrue(TMATrueParams &_p)
      : params(_p.AtrTimeframe, _p.TmaHalfLength, _p.AtrMultiplier, _p.AtrPeriod, _p.BarsToProcess),
        Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_TMATrue(TMATrueParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.AtrTimeframe, _p.TmaHalfLength, _p.AtrMultiplier, _p.AtrPeriod, _p.BarsToProcess),
        Indicator(NULL, _tf) {
    params = _p;
  }

  /**
   * Returns the indicator's value.
   *
   */
  double GetValue(ENUM_TMA_TRUE_LINE _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.custom_indi_name, params.GetAtrTimeframe(),
                         params.GetTmaHalfLength(), params.GetAtrMultiplier(), params.GetAtrPeriod(),
                         params.GetBarsToProcess(), _mode, _shift);
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
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry;
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (ENUM_TMA_TRUE_LINE _mode = 0; _mode < FINAL_TMA_TRUE_LINE_ENTRY; _mode++) {
        _entry.value.SetValue(params.idvtype, GetValue(_mode, _shift), _mode);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.value.GetMinDbl(params.idvtype) > 0 &&
                                                   _entry.value.GetValueDbl(params.idvtype, TMA_TRUE_LOWER) <
                                                       _entry.value.GetValueDbl(params.idvtype, TMA_TRUE_UPPER));
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }
};
