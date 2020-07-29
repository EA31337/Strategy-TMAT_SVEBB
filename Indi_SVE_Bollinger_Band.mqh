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

// Indicator line identifiers used in SVEBand.
enum ENUM_SVE_BAND_LINE {
  SVE_BAND_BASE = 0,   // Main line.
  SVE_BAND_UPPER = 1,  // Upper limit.
  SVE_BAND_LOWER = 2,  // Lower limit.
  FINAL_SVE_BAND_LINE_ENTRY,
};

// Structs.
struct SVEBandParams : IndicatorParams {
  // Indicator params.
  int    TEMAPeriod;
  int    SvePeriod;
  double BBUpDeviations;
  double BBDnDeviations;
  int    DeviationsPeriod;
  // Struct constructor.
  void SVEBandParams(int _tema_period, int _sve_period,
      double _deviations_up, double _deviations_down, int _deviations_period,
      int _shift)
      : TEMAPeriod(_tema_period), SvePeriod(_sve_period),
      BBUpDeviations(_deviations_up), BBDnDeviations(_deviations_down),
      DeviationsPeriod(_deviations_period) {
    max_modes = FINAL_SVE_BAND_LINE_ENTRY;
    custom_indi_name = "Indicators\\SVE_Bollinger_Band";
    SetDataValueType(TYPE_DOUBLE);
  };
  // Getters.
  int GetTEMAPeriod() { return TEMAPeriod; }
  int GetSvePeriod() { return SvePeriod; }
  double GetBBUpDeviations() { return BBUpDeviations; }
  double GetBBDnDeviations() { return BBDnDeviations; }
  int GetDeviationsPeriod() { return DeviationsPeriod; }
  // Setters.
  void SetTEMAPeriod(int _value) { TEMAPeriod = _value; }
  void SetSvePeriod(int _value) { SvePeriod = _value; }
  void SetBBUpDeviations(double _value) { BBUpDeviations = _value; }
  void SetBBDnDeviations(double _value) { BBDnDeviations = _value; }
  void SetDeviationsPeriod(int _value) { DeviationsPeriod = _value; }
};

/**
 * Implements indicator class.
 */
class Indi_SVEBand : public Indicator {
 protected:
  // Structs.
  SVEBandParams params;

 public:
  /**
   * Class constructor.
   */
  Indi_SVEBand(SVEBandParams &_p)
      : params(_p.TEMAPeriod, _p.SvePeriod, _p.BBUpDeviations, _p.BBDnDeviations,
        _p.DeviationsPeriod, _p.shift), Indicator((IndicatorParams) _p) {
    params = _p;
  }
  Indi_SVEBand(SVEBandParams &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.TEMAPeriod, _p.SvePeriod, _p.BBUpDeviations, _p.BBDnDeviations,
        _p.DeviationsPeriod, _p.shift), Indicator(NULL, _tf) {
    params = _p;
  }

  /**
   * Returns the indicator's value.
   *
   */
  double GetValue(ENUM_SVE_BAND_LINE _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, GetSymbol(), GetTf(), params.custom_indi_name,
          params.GetTEMAPeriod(), params.GetSvePeriod(), params.GetBBUpDeviations(), params.GetBBDnDeviations(),
          params.GetDeviationsPeriod(),
          _mode, _shift);
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
      for (ENUM_SVE_BAND_LINE _mode = 0; _mode < FINAL_SVE_BAND_LINE_ENTRY; _mode++) {
        _entry.value.SetValue(params.idvtype, GetValue(_mode, _shift), _mode);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.value.GetMinDbl(params.idvtype) > 0 &&
                                                   _entry.value.GetValueDbl(params.idvtype, SVE_BAND_LOWER) <
                                                       _entry.value.GetValueDbl(params.idvtype, SVE_BAND_UPPER));
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }

};
