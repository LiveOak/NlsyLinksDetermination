using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Nls.BaseAssembly {
	public class MarkerGen1Summary {
		#region Fields
		//private readonly bool _rosterResolved;
		//private readonly float _rosterR = float.NaN;
		//private readonly float _rosterRBoundLower = float.NaN;
		//private readonly float _rosterRBoundUpper = float.NaN;

		private readonly MarkerEvidence _sameGeneration;
		private readonly MarkerEvidence _shareBiomom;
		private readonly MarkerEvidence _shareBiodad;
		private readonly MarkerEvidence _shareBiograndparent;
		#endregion
		#region Properties
		//public bool RosterResolved { get { return _rosterResolved; } }
		//public float RosterR { get { return _rosterR; } }
		//public float RosterRBoundLower { get { return _rosterRBoundLower; } }
		//public float RosterRBoundUpper { get { return _rosterRBoundUpper; } }

		public MarkerEvidence SameGeneration { get { return _sameGeneration; } }
		public MarkerEvidence ShareBiomom { get { return _shareBiomom; } }
		public MarkerEvidence ShareBiodad { get { return _shareBiodad; } }
		public MarkerEvidence ShareBiograndparent { get { return _shareBiograndparent; } }
		#endregion
		#region Constructor
		public MarkerGen1Summary ( MarkerEvidence sameGeneration, MarkerEvidence shareBiomom, MarkerEvidence shareBiodad, MarkerEvidence shareBiograndparent ) {
			//bool rosterResolved, float rosterR, float rosterRBoundLower, float rosterRBoundUpper,

			//_rosterResolved=rosterResolved;
			//_rosterR = rosterR;
			//_rosterRBoundLower = rosterRBoundLower;
			//_rosterRBoundUpper = rosterRBoundUpper;

			_sameGeneration = sameGeneration;
			_shareBiomom = shareBiomom;
			_shareBiodad = shareBiodad;
			_shareBiograndparent = shareBiograndparent;
		}
		#endregion
	}
}