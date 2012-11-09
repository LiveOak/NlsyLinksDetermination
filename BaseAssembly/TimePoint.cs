using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Nls.BaseAssembly {
	public sealed class TimePoint<T> {
		#region Fields
		private readonly Int16 _surveyYear = Int16.MinValue;
		private readonly T _point;
		#endregion
		#region Properties
		internal Int16 SurveyYear { get { return _surveyYear; } }
		public T Point { get { return _point; } }
		#endregion
		#region Constructor
		internal TimePoint ( Int16 surveyYear, T point ) {
			_surveyYear = surveyYear;
			_point = point;
		}
		#endregion
		#region Public Methods
		#endregion
		#region Private Methods
		#endregion
	}
}