using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.Text;
using Nls.BaseAssembly;

namespace Nls.BaseAssembly.Assign {
	public class RGen1Pass2 : IAssignPass2 {
		#region Fields
		//private readonly ImportDataSet _dsImport;
		private readonly LinksDataSet _dsLinks;
		private readonly LinksDataSet.tblRelatedStructureRow _drLeft;
		private readonly LinksDataSet.tblRelatedStructureRow _drRight;
		//private readonly LinksDataSet.tblSubjectRow _drBare1;
		//private readonly LinksDataSet.tblSubjectRow _drBare2;
		private readonly LinksDataSet.tblSubjectDetailsRow _drSubjectDetails1;
		private readonly LinksDataSet.tblSubjectDetailsRow _drSubjectDetails2;
		private readonly LinksDataSet.tblMarkerGen1DataTable _dtMarkersGen1;
		private readonly LinksDataSet.tblRelatedValuesRow _drValue;

		private readonly Int32 _idRelatedLeft = Int32.MinValue;
		private readonly Int32 _idRelatedRight = Int32.MinValue;
		private readonly Int32 _idRelatedOlderAboutYounger = Int32.MinValue;//usually equal to _idRelatedLeft
		//private readonly Int32 _idRelatedYoungerAboutOlder = Int32.MinValue;//usually equal to _idRelatedRight

		private readonly Int32 _extendedID;
		private float? _rImplicit = null;// float.NaN;
		private float? _rImplicitSubject = null;//float.NaN;
		private float? _rExplicit = float.NaN;//float.NaN;
		private float? _r = float.NaN;
		private float? _rPeek = null;//float.NaN;
		#endregion
		#region IAssign Properties
		public Int32 IDLeft { get { return _idRelatedLeft; } }
		public Int32 IDRight { get { return _idRelatedRight; } }
		public float? RImplicit { get { return _rImplicit; } }
		public float? RImplicitMother{ get { return null; } }
		public float? RImplicitSubject { get { return _rImplicitSubject; } }
		public float? RExplicit { get { return _rExplicit; } }
		public float? R { get { return _r; } }
		public float? RPeek { get { return _rPeek; } }
		#endregion
		#region Constructor
		public RGen1Pass2 ( ImportDataSet dsImport, LinksDataSet dsLinks, LinksDataSet.tblRelatedStructureRow drLeft, LinksDataSet.tblRelatedStructureRow drRight ) {
			if ( dsImport == null ) throw new ArgumentNullException("dsImport");
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( drLeft == null ) throw new ArgumentNullException("drLeft");
			if ( drRight == null ) throw new ArgumentNullException("drRight");
			//if ( dsLinks.tblRelatedValues.Count != 0 ) throw new InvalidOperationException("tblRelatedValues must be empty before creating rows for it.");
			//if ( dsImport.tblLinks2004Gen2.Count == 0 ) throw new InvalidOperationException("tblLinks2004Gen2 must NOT be empty before assigning R values from it.");
			//if ( dsLinks.tblMzManual.Count == 0 ) throw new InvalidOperationException("tblMzManual must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblSubject.Count == 0 ) throw new InvalidOperationException("tblSubject must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblSubjectDetails.Count == 0 ) throw new InvalidOperationException("tblSubjectDetails must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblMarkerGen1.Count == 0 ) throw new InvalidOperationException("tblMarkerGen1 must NOT be empty before assigning R values from it.");
			//_dsImport = dsImport;
			_dsLinks = dsLinks;
			_drLeft = drLeft;
			_drRight = drRight;
			_idRelatedLeft = _drLeft.ID;
			_idRelatedRight = _drRight.ID;
			//_drBare1 = _dsLinks.tblSubject.FindBySubjectTag(drLeft.Subject1Tag);
			//_drBare2 = _dsLinks.tblSubject.FindBySubjectTag(drLeft.Subject2Tag);
			_drSubjectDetails1 = _dsLinks.tblSubjectDetails.FindBySubjectTag(drLeft.Subject1Tag);
			_drSubjectDetails2 = _dsLinks.tblSubjectDetails.FindBySubjectTag(drLeft.Subject2Tag);
			_extendedID = _drLeft.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1.ExtendedID;

			if ( _drSubjectDetails1.BirthOrderInNls <= _drSubjectDetails2.BirthOrderInNls ) {//This is the way it usually is.  Recall twins were assigned tied birth orders
				_idRelatedOlderAboutYounger = _idRelatedLeft;
				//_idRelatedYoungerAboutOlder = _idRelatedRight;
			}
			else if ( _drSubjectDetails1.BirthOrderInNls > _drSubjectDetails2.BirthOrderInNls ) {
				_idRelatedOlderAboutYounger = _idRelatedRight;
				//_idRelatedYoungerAboutOlder = _idRelatedLeft;
			}

			_drValue = _dsLinks.tblRelatedValues.FindByID(_idRelatedLeft);
			_dtMarkersGen1 = MarkerGen1.PairRelevantMarkerRows(_idRelatedLeft, _idRelatedRight, _dsLinks, _extendedID);

			//MarkerEvidence babyDaddyDeathDate = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.BabyDaddyDeathDate, _dtMarkersGen2);
			//MarkerEvidence babyDaddyAlive = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.BabyDaddyAlive, _dtMarkersGen2);
			//MarkerEvidence babyDaddyInHH = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.BabyDaddyInHH, _dtMarkersGen2);
			//MarkerEvidence babyDaddyLeftHHDate = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.BabyDaddyLeftHHDate, _dtMarkersGen2);
			//MarkerEvidence babyDaddyDistanceFromHH = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.BabyDaddyDistanceFromHH, _dtMarkersGen2);

			//MarkerEvidence fatherAlive = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.Gen2CFatherAlive, _dtMarkersGen2);
			//MarkerEvidence fatherInHH = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.Gen2CFatherInHH, _dtMarkersGen2);
			//MarkerEvidence fatherDistanceFromHH = MarkerGen2.RetrieveBiodadMarkerFromGen1(_idRelatedOlderAboutYounger, MarkerType.Gen2CFatherDistanceFromHH, _dtMarkersGen2);

			//_rImplicitSubject = CalculateRImplicitSubject(fatherAlive, fatherInHH, fatherDistanceFromHH);
			//_rImplicit = CalculateRImplicit(_rImplicitMother, _rImplicitSubject);
			_rExplicit = CalculateRExplicit();
			_r = CalculateR();
			//Trace.Write(_r);

			//_rPeek = CalculateRPeek();
		}
		#endregion
		#region Public Methods
		#endregion
		#region Private Methods - Estimate R
		private float? CalculateRExplicit ( ) {//Int32 idRelated
			if ( !_drValue.IsRExplicitPass1Null() ) return (float?)_drValue.RExplicitPass1;
			DataColumn dcPass1 = _dsLinks.tblRelatedValues.RExplicitPass1Column;
			Pair[] pairs = Pair.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

			InterpolateR interpolate = new InterpolateR(pairs);
			float? newRExplicit = interpolate.Interpolate(_drLeft.Subject1Tag, _drLeft.Subject2Tag);
			if ( newRExplicit.HasValue ) {
				return newRExplicit;
			}
			else {
				return null;
				//MarkerGen1Summary biomom = MarkerGen1.RetrieveMarker(idRelated, MarkerType.ShareBiomom, _dtMarkersGen1);
				//MarkerGen1Summary biodad = MarkerGen1.RetrieveMarker(idRelated, MarkerType.ShareBiodad, _dtMarkersGen1);
				//if ( biomom == null || biodad == null ) {
				//   return null;
				//}
				//else if ( biomom.ShareBiomom == MarkerEvidence.Disconfirms && biodad.ShareBiodad == MarkerEvidence.Disconfirms ) {
				//   return RCoefficients.NotRelated;//The could still be cousins or something else
				//}
				//else {
				//   return null;
				//}
			}
		}
		private float? CalculateR ( ) {
			if ( !_drValue.IsRPass1Null() ) return (float?)_drValue.RPass1;
			DataColumn dcPass1 = _dsLinks.tblRelatedValues.RPass1Column;
			Pair[] pairs = Pair.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

			InterpolateR interpolate = new InterpolateR(pairs);
			float? newR = interpolate.Interpolate(_drLeft.Subject1Tag, _drLeft.Subject2Tag);
			if ( newR.HasValue )
				return newR;
			else if ( _rImplicit.HasValue )
				return _rImplicit;
			else
				return null;
		}
		private static float? CalculateRPeek ( ) {
			return null;
		}
		#endregion
	}
}