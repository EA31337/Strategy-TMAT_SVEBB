//+------------------------------------------------------------------+
//|                                      Copyright 2016-2022, EA31337 Ltd |
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
#ifndef INDI_SVE_BOLLINGER_BANDS_MQH
#define INDI_SVE_BOLLINGER_BANDS_MQH

// Defines.
#define INDI_SVEBB_PATH "indicators-other\\Oscillator"

// Indicator line identifiers used in the indicator.
enum ENUM_SVE_BAND_LINE {
  SVE_BAND_MAIN = 0,   // Main line.
  SVE_BAND_UPPER = 1,  // Upper limit.
  SVE_BAND_LOWER = 2,  // Lower limit.
  FINAL_SVE_BAND_LINE_ENTRY,
};

// Structs.

// Defines struct to store indicator parameter values.
struct IndiSVEBBParams : public IndicatorParams {
  // Indicator params.
  int TEMAPeriod;
  int SvePeriod;
  double BBUpDeviations;
  double BBDnDeviations;
  int DeviationsPeriod;
  // Struct constructors.
  void IndiSVEBBParams(int _tema_period = 8, int _sve_period = 18, double _deviations_up = 1.6,
                       double _deviations_down = 1.6, int _deviations_period = 63, int _shift = 0)
      : TEMAPeriod(_tema_period),
        SvePeriod(_sve_period),
        BBUpDeviations(_deviations_up),
        BBDnDeviations(_deviations_down),
        DeviationsPeriod(_deviations_period),
        IndicatorParams(INDI_SVE_BB, FINAL_SVE_BAND_LINE_ENTRY, TYPE_DOUBLE) {
#ifdef __resource__
    custom_indi_name = "::" + INDI_SVEBB_PATH + "\\SVE_Bollinger_Bands";
#else
    custom_indi_name = "SVE_Bollinger_Bands";
#endif
    SetDataSourceType(IDATA_ICUSTOM);
  };
  void IndiSVEBBParams(IndiSVEBBParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  }
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
class Indi_SVE_Bollinger_Bands : public Indicator<IndiSVEBBParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_SVE_Bollinger_Bands(IndiSVEBBParams &_p, IndicatorBase *_indi_src = NULL)
      : Indicator<IndiSVEBBParams>(_p, _indi_src) {}
  Indi_SVE_Bollinger_Bands(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_SVE_BB, _tf){};

  /**
   * Returns the indicator's value.
   */
  IndicatorDataEntryValue GetEntryValue(int _mode = 0, int _shift = -1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         iparams.custom_indi_name, iparams.GetTEMAPeriod(), iparams.GetSvePeriod(),
                         iparams.GetBBUpDeviations(), iparams.GetBBDnDeviations(), iparams.GetDeviationsPeriod(), _mode,
                         _ishift);
        break;
      default:
        SetUserError(ERR_INVALID_PARAMETER);
        _value = EMPTY_VALUE;
        break;
    }
    return _value;
  }

  /**
   * Checks if indicator entry values are valid.
   */
  virtual bool IsValidEntry(IndicatorDataEntry &_entry) {
    return Indicator<IndiSVEBBParams>::IsValidEntry(_entry) && _entry.GetMin<double>() > 0 &&
           _entry.values[(int)SVE_BAND_UPPER].IsGt<double>(SVE_BAND_LOWER);
  }
};

#endif  // INDI_SVE_BOLLINGER_BANDS_MQH
