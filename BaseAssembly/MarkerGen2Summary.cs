using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Nls.BaseAssembly {
	public struct MarkerGen2Summary {
		private readonly Int16 _surveyYear;
		private readonly MarkerEvidence _mzEvidence;
		private readonly MarkerEvidence _shareBiodadEvidence;

		public Int16 SurveyYear { get { return _surveyYear; } }
		public MarkerEvidence MzEvidence { get { return _mzEvidence; } }
		public MarkerEvidence ShareBiodadEvidence { get { return _shareBiodadEvidence; } }

		public MarkerGen2Summary ( Int16 surveyYear, MarkerEvidence mzEvidence, MarkerEvidence shareBiodadEvidence ) {
			_surveyYear = surveyYear;
			_mzEvidence = mzEvidence;
			_shareBiodadEvidence = shareBiodadEvidence;
		}
	}
}