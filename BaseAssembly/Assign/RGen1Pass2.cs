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
		private readonly LinksDataSet _dsLinks;
		private readonly LinksDataSet.tblRelatedStructureRow _drLeft;
		private readonly LinksDataSet.tblRelatedStructureRow _drRight;
		private readonly LinksDataSet.tblSubjectDetailsRow _drSubjectDetails1;
		private readonly LinksDataSet.tblSubjectDetailsRow _drSubjectDetails2;
		private readonly LinksDataSet.tblMarkerGen1DataTable _dtMarkersGen1;
		private readonly LinksDataSet.tblRelatedValuesRow _drValue;

		private readonly Int32 _idRelatedLeft = Int32.MinValue;
		private readonly Int32 _idRelatedRight = Int32.MinValue;
		private readonly Int32 _idRelatedOlderAboutYounger = Int32.MinValue;//usually equal to _idRelatedLeft

		private readonly Tristate _implicitShareBiomom;
		private readonly Tristate _implicitShareBiodad;
		private readonly Tristate _explicitShareBiomom;
		private readonly Tristate _explicitShareBiodad;
		private readonly Tristate _shareBiomom;
		private readonly Tristate _shareBiodad;

		private readonly Int32 _extendedID;
		private float? _rImplicit = null;// float.NaN;
		private float? _rImplicitSubject = null;//float.NaN;
		private float? _rExplicit = float.NaN;//float.NaN;
		private float? _r = float.NaN;
		private float? _rFull = float.NaN;
		private float? _rPeek = null;//float.NaN;
		#endregion
		#region IAssign Properties
		public Int32 IDLeft { get { return _idRelatedLeft; } }
		public Int32 IDRight { get { return _idRelatedRight; } }
		public float? RImplicit { get { return _rImplicit; } }
		public float? RImplicitMother { get { return null; } }
		public float? RImplicitSubject { get { return _rImplicitSubject; } }
		public float? RExplicit { get { return _rExplicit; } }
		public float? R { get { return _r; } }
		public float? RFull { get { return _rFull; } }
		public float? RPeek { get { return _rPeek; } }
		#endregion
		#region Constructor
		public RGen1Pass2 ( LinksDataSet dsLinks, LinksDataSet.tblRelatedStructureRow drLeft, LinksDataSet.tblRelatedStructureRow drRight ) {
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( drLeft == null ) throw new ArgumentNullException("drLeft");
			if ( drRight == null ) throw new ArgumentNullException("drRight");
			if ( dsLinks.tblRelatedValues.Count == 0 ) throw new InvalidOperationException("tblRelatedValues must be empty before updating rows for it.");
			if ( dsLinks.tblMzManual.Count == 0 ) throw new InvalidOperationException("tblMzManual must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblSubject.Count == 0 ) throw new InvalidOperationException("tblSubject must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblSubjectDetails.Count == 0 ) throw new InvalidOperationException("tblSubjectDetails must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblMarkerGen1.Count == 0 ) throw new InvalidOperationException("tblMarkerGen1 must NOT be empty before assigning R values from it.");
			_dsLinks = dsLinks;
			_drLeft = drLeft;
			_drRight = drRight;
			_idRelatedLeft = _drLeft.ID;
			_idRelatedRight = _drRight.ID;
			_drSubjectDetails1 = _dsLinks.tblSubjectDetails.FindBySubjectTag(drLeft.Subject1Tag);
			_drSubjectDetails2 = _dsLinks.tblSubjectDetails.FindBySubjectTag(drLeft.Subject2Tag);
			_extendedID = _drLeft.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1.ExtendedID;

			if ( _drSubjectDetails1.BirthOrderInNls <= _drSubjectDetails2.BirthOrderInNls ) {//This is the way it usually is.  Recall twins were assigned tied birth orders
				_idRelatedOlderAboutYounger = _idRelatedLeft; //_idRelatedYoungerAboutOlder = _idRelatedRight;
			}
			else if ( _drSubjectDetails1.BirthOrderInNls > _drSubjectDetails2.BirthOrderInNls ) {
				_idRelatedOlderAboutYounger = _idRelatedRight;
			}

			_drValue = _dsLinks.tblRelatedValues.FindByID(_idRelatedLeft);
			_dtMarkersGen1 = MarkerGen1.PairRelevantMarkerRows(_idRelatedLeft, _idRelatedRight, _dsLinks, _extendedID);

			_implicitShareBiomom = AddressImplicitBiomom();
			_implicitShareBiodad = AddressImplicitBiodad();
			_rImplicit = CommonFunctions.TranslateToR(shareBiomom: _implicitShareBiomom, shareBiodad: _implicitShareBiodad, mustDecide: false);

			AddressExplicit();
			AddressOverall();
			//Trace.Write(_r);

			//_rPeek = CalculateRPeek();
		}


		private Tristate AddressImplicitBiomom ( ) {
			Tristate implicitBiomomPass1 = (Tristate)_drValue.ImplicitShareBiomomPass1;
			if ( implicitBiomomPass1 != Tristate.DoNotKnow ) return implicitBiomomPass1;

			DataColumn dcPass1 = _dsLinks.tblRelatedValues.ImplicitShareBiomomPass1Column;
			PairShare[] pairs = PairShare.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

			InterpolateShare interpolate = new InterpolateShare(pairs);
			Tristate newShare = interpolate.Interpolate(_drLeft.Subject1Tag, _drLeft.Subject2Tag);

			if ( newShare != Tristate.DoNotKnow ) {
				return newShare;
			}
			else {
				MarkerEvidence biomomInHH1980 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiomomInHH, 1980, Bioparent.Mom, _dtMarkersGen1);
				MarkerEvidence biomomInHH1978 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiomomInHH, 1978, Bioparent.Mom, _dtMarkersGen1);
				MarkerEvidence biomomInHH1977 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiomomInHH, 1977, Bioparent.Mom, _dtMarkersGen1);
				MarkerEvidence biomomInHH1976 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiomomInHH, 1976, Bioparent.Mom, _dtMarkersGen1);
				return ImplicitShareBioparent(biomomInHH1980, biomomInHH1978, biomomInHH1977, biomomInHH1976);
			}
		}
		private Tristate AddressImplicitBiodad ( ) {
			Tristate implicitBiodadPass1 = (Tristate)_drValue.ImplicitShareBiodadPass1;
			if ( implicitBiodadPass1 != Tristate.DoNotKnow ) return implicitBiodadPass1;

			DataColumn dcPass1 = _dsLinks.tblRelatedValues.ImplicitShareBiodadPass1Column;
			PairShare[] pairs = PairShare.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

			InterpolateShare interpolate = new InterpolateShare(pairs);
			Tristate newShare = interpolate.Interpolate(_drLeft.Subject1Tag, _drLeft.Subject2Tag);

			if ( newShare != Tristate.DoNotKnow ) {
				return newShare;
			}
			else {
				MarkerEvidence biodadInHH1980 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiodadInHH, 1980, Bioparent.Dad, _dtMarkersGen1);
				MarkerEvidence biodadInHH1978 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiodadInHH, 1978, Bioparent.Dad, _dtMarkersGen1);
				MarkerEvidence biodadInHH1977 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiodadInHH, 1977, Bioparent.Dad, _dtMarkersGen1);
				MarkerEvidence biodadInHH1976 = MarkerGen1.RetrieveParentRetroMarker(_idRelatedOlderAboutYounger, MarkerType.Gen1BiodadInHH, 1976, Bioparent.Dad, _dtMarkersGen1);
				return ImplicitShareBioparent(biodadInHH1980, biodadInHH1978, biodadInHH1977, biodadInHH1976);
			}
		}
		private void AddressExplicit ( ) {
			Tristate explicitBiomomPass1 = (Tristate)_drValue.ExplicitShareBiomomPass1;
			Tristate explicitBiodadPass1 = (Tristate)_drValue.ExplicitShareBiodadPass1;

			//_explicitShareBiomom = ImplicitShareBioparent();
			//_explicitShareBiodad = ImplicitShareBioparent();
			//_rExplicit = CommonFunctions.TranslateToR(shareBiomom: _explicitShareBiomom, shareBiodad: _explicitShareBiodad, mustDecide: false);
			_rExplicit = CalculateRExplicit();
		}
		private void AddressOverall ( ) {
			_rFull = CalculateRFull();
			_r = CalculateR();
		}
		#endregion
		#region Public Methods
		#endregion
		#region Private Methods - Estimate R
		private Tristate ImplicitShareBioparent ( MarkerEvidence inHH1980, MarkerEvidence inHH1978, MarkerEvidence inHH1977, MarkerEvidence inHH1976 ) {//{ 1980, 1979, 1978, 1977, 1976 }
			//MarkerEvidence biomomInHH1980,MarkerEvidence  biodadInHH1980, MarkerEvidence biomomInHH1978,MarkerEvidence  biodadInHH1978, MarkerEvidence biomomInHH1977, MarkerEvidence biodadInHH1977,MarkerEvidence  biomomInHH1976, MarkerEvidence biodadInHH1976 
			//if ( !_drValue.IsRImplicitPass1Null() )	return (float?)_drValue.RImplicitPass1;

			//DataColumn dcPass1 = _dsLinks.tblRelatedValues.RImplicitPass1Column;
			//Pair[] pairs = Pair.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

			//InterpolateR interpolate = new InterpolateR(pairs);
			//float? newRImplicit = interpolate.Interpolate(_drLeft.Subject1Tag, _drLeft.Subject2Tag);
			//if ( newRImplicit.HasValue ) 
			//   return newRImplicit;
			//else 
			if ( inHH1980 == MarkerEvidence.StronglySupports )
				return Tristate.Yes;
			else if ( inHH1980 == MarkerEvidence.Disconfirms )
				return Tristate.No;
			else if ( inHH1978 == MarkerEvidence.StronglySupports )
				return Tristate.Yes;
			else if ( inHH1978 == MarkerEvidence.Disconfirms )
				return Tristate.No;
			else if ( inHH1977 == MarkerEvidence.StronglySupports )
				return Tristate.Yes;
			else if ( inHH1977 == MarkerEvidence.Disconfirms )
				return Tristate.No;
			else if ( inHH1976 == MarkerEvidence.StronglySupports )
				return Tristate.Yes;
			else if ( inHH1976 == MarkerEvidence.Disconfirms )
				return Tristate.No;
			else
				return Tristate.DoNotKnow;
		}
		private float? CalculateRExplicit ( ) {//Int32 idRelated
			if ( !_drValue.IsRExplicitPass1Null() ) return (float?)_drValue.RExplicitPass1;
			DataColumn dcPass1 = _dsLinks.tblRelatedValues.RExplicitPass1Column;
			PairR[] pairs = PairR.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

			//InterpolateBioparent interpolate = new InterpolateBioparent(pairs);
			//float? newRExplicit = interpolate.Interpolate(_drLeft.Subject1Tag, _drLeft.Subject2Tag);
			//if ( newRExplicit.HasValue ) 
			//   return newRExplicit;
			//else 
				return null;
		}
		private float? CalculateR ( ) {
			if ( !RFull.HasValue ) {
				return null;
			}
			else if ( Constants.Gen1RsToExcludeFromR.Contains(RFull.Value) ) {
				return null;
			}
			else {
				return (float)RFull.Value;
			}



			//if ( !_drValue.IsRFullNull() ) return (float?)_drValue.RPass1;
			//DataColumn dcPass1 = _dsLinks.tblRelatedValues.RPass1Column;
			//Pair[] pairs = Pair.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

			//InterpolateR interpolate = new InterpolateR(pairs);
			//float? newR = interpolate.Interpolate(_drLeft.Subject1Tag, _drLeft.Subject2Tag);
			//if ( newR.HasValue )
			//   return newR;
			//else if ( _rImplicit.HasValue )
			//   return _rImplicit;
			//else
			//   return null;
		}
		private float? CalculateRFull ( ) {
			if ( !_drValue.IsRPass1Null() ) return (float?)_drValue.RPass1;
			DataColumn dcPass1 = _dsLinks.tblRelatedValues.RPass1Column;
			PairR[] pairs = PairR.BuildRelatedPairsOfGen1Housemates(dcPass1, _drLeft.Subject1Tag, _drLeft.Subject2Tag, _drLeft.ExtendedID, _dsLinks);

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