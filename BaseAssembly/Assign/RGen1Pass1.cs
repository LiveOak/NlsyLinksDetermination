using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using Nls.BaseAssembly;

namespace Nls.BaseAssembly.Assign {
	public class RGen1Pass1 : IAssignPass1 {
		#region Fields
		private readonly ImportDataSet _dsImport;
		private readonly LinksDataSet _dsLinks;
		private readonly LinksDataSet.tblRelatedStructureRow _drLeft;
		private readonly LinksDataSet.tblRelatedStructureRow _drRight;
		private readonly LinksDataSet.tblSubjectRow _drBare1;
		private readonly LinksDataSet.tblSubjectRow _drBare2;
		private readonly LinksDataSet.tblSubjectDetailsRow _drSubjectDetails1;
		private readonly LinksDataSet.tblSubjectDetailsRow _drSubjectDetails2;
		private readonly LinksDataSet.tblMarkerGen1DataTable _dtMarkersGen1;

		private readonly Int32 _idRelatedLeft = Int32.MinValue;
		private readonly Int32 _idRelatedRight = Int32.MinValue;
		private readonly Int32 _idRelatedOlderAboutYounger = Int32.MinValue;//usually equal to _idRelatedLeft
		private readonly Int32 _idRelatedYoungerAboutOlder = Int32.MinValue;//usually equal to _idRelatedRight

		private readonly Int32 _extendedID;
		private readonly MultipleBirth _multipleBirth;
		private readonly Tristate _isMZ;
		private readonly Tristate _isRelatedInMZManual;
		//private Int16 _rosterAssignment=Int16.MinValue;
		//private float? _rRoster = float.NaN;
		private float? _rImplicitPass1 = null;// float.NaN;
		private float? _rImplicit2004 = float.NaN;

		private float? _rExplicitOldestSibVersion = float.NaN;
		private float? _rExplicitYoungestSibVersion = float.NaN;
		private float? _rExplicitPass1 = float.NaN;//  float.NaN;
		private float? _rPass1 = float.NaN;//  float.NaN;
		#endregion
		#region IAssign Properties
		public Int32 IDLeft { get { return _idRelatedLeft; } }
		public Int32 IDRight { get { return _idRelatedRight; } }
		public MultipleBirth MultipleBirthIfSameSex { get { return _multipleBirth; } }
		public Tristate IsMZ { get { return _isMZ; } }
		//public Int16 RosterAssignmentID { get { return _rosterAssignment; } }
		//public float? RRoster { get { return _rRoster; } }
		public float? RImplicitPass1 { get { return _rImplicitPass1; } }
		public float? RImplicit2004 { get { return _rImplicit2004; } }
		public float? RExplicitOldestSibVersion { get { return _rExplicitOldestSibVersion; } }
		public float? RExplicitYoungestSibVersion { get { return _rExplicitYoungestSibVersion; } }
		public float? RExplicitPass1 { get { return _rExplicitPass1; } }
		public float? RPass1 { get { return _rPass1; } }
		#endregion
		#region Constructor
		public RGen1Pass1 ( ImportDataSet dsImport, LinksDataSet dsLinks, LinksDataSet.tblRelatedStructureRow drLeft, LinksDataSet.tblRelatedStructureRow drRight ) {
			if ( dsImport == null ) throw new ArgumentNullException("dsImport");
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( drLeft == null ) throw new ArgumentNullException("drLeft");
			if ( drRight == null ) throw new ArgumentNullException("drRight");
			if ( dsImport.tblLinks2004Gen1.Count == 0 ) throw new InvalidOperationException("tblLinks2004Gen1 must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblMzManual.Count == 0 ) throw new InvalidOperationException("tblMzManual must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblSubject.Count == 0 ) throw new InvalidOperationException("tblSubject must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblRosterGen1.Count == 0 ) throw new InvalidOperationException("tblRosterGen1 must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblMarkerGen1.Count == 0 ) throw new InvalidOperationException("tblMarkerGen2 must NOT be empty before assigning R values from it.");
			if ( dsLinks.tblSubjectDetails.Count == 0 ) throw new InvalidOperationException("tblSubjectDetails must NOT be empty before assigning R values from it.");

			_dsImport = dsImport;
			_dsLinks = dsLinks;
			_drLeft = drLeft;
			_drRight = drRight;
			_idRelatedLeft = _drLeft.ID;
			_idRelatedRight = _drRight.ID;
			_drBare1 = _dsLinks.tblSubject.FindBySubjectTag(drLeft.Subject1Tag);
			_drBare2 = _dsLinks.tblSubject.FindBySubjectTag(drLeft.Subject2Tag);
			_drSubjectDetails1 = _dsLinks.tblSubjectDetails.FindBySubjectTag(drLeft.Subject1Tag);
			_drSubjectDetails2 = _dsLinks.tblSubjectDetails.FindBySubjectTag(drLeft.Subject2Tag);
			_extendedID = _drLeft.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1.ExtendedID;

			if ( _drSubjectDetails1.BirthOrderInNls <= _drSubjectDetails2.BirthOrderInNls ) {//This is the way it usually is.  Remember that twins were assigned tied birth orders
				_idRelatedOlderAboutYounger = _idRelatedLeft;
				_idRelatedYoungerAboutOlder = _idRelatedRight;
			}
			else if ( _drSubjectDetails1.BirthOrderInNls > _drSubjectDetails2.BirthOrderInNls ) {
				_idRelatedOlderAboutYounger = _idRelatedRight;
				_idRelatedYoungerAboutOlder = _idRelatedLeft;
			}

			_dtMarkersGen1 = MarkerGen1.PairRelevantMarkerRows(_idRelatedLeft, _idRelatedRight, _dsLinks, _extendedID);

			LinksDataSet.tblMzManualRow drMz = Retrieve.MzManualRecord(_drBare1, _drBare2, _dsLinks);
			
			if ( drMz == null ) {
				_multipleBirth = MultipleBirth.No;
				_isMZ = Tristate.No;
				_isRelatedInMZManual = Tristate.DoNotKnow;
			}
			else {
				_multipleBirth = (MultipleBirth)drMz.MultipleBirthIfSameSex;
				_isMZ = (Tristate)drMz.IsMz;
				if ( drMz.IsRelatedNull() ) _isRelatedInMZManual = Tristate.DoNotKnow;
				else if(drMz.Related) _isRelatedInMZManual = Tristate.Yes;
				else _isRelatedInMZManual = Tristate.No;
			}

			//_rosterAssignment = _dsLinks.tblRosterGen1.FindByRelatedID(idRelated).id
			//_rImplicitPass1 = CalculateRImplicitPass1(babyDaddyDeathDate, babyDaddyAlive, babyDaddyInHH, babyDaddyLeftHHDate, babyDaddyDistanceFromHH, babyDaddyAsthma);
			_rImplicit2004 = RetrieveRImplicit2004();
			_rExplicitOldestSibVersion = CalculateRExplicitSingleSibVersion(_idRelatedOlderAboutYounger, _drLeft.Subject1Tag);
			_rExplicitYoungestSibVersion = CalculateRExplicitSingleSibVersion(_idRelatedYoungerAboutOlder, _drLeft.Subject2Tag);
			_rExplicitPass1 = CalculateRExplicitPass1();
			_rPass1 = CalculateRPass1();
		}
		#endregion
		#region Public Methods
		#endregion
		#region Private Methods
		#endregion
		#region Private Methods - Estimate R
		private float? RetrieveRImplicit2004 ( ) {
			ImportDataSet.tblLinks2004Gen1Row drV1 = _dsImport.tblLinks2004Gen1.FindBySubject1TagSubject2Tag(_drBare1.SubjectTag, _drBare2.SubjectTag);
			ImportDataSet.tblLinks2004Gen1Row drV2 = _dsImport.tblLinks2004Gen1.FindBySubject1TagSubject2Tag(_drBare2.SubjectTag, _drBare1.SubjectTag);
			if ( drV1 != null ) {
				if ( drV1.IsRecommendedRelatednessNull() ) return null;
				else return drV1.RecommendedRelatedness;
			}
			else if ( drV2 != null ) {
				if ( drV2.IsRecommendedRelatednessNull() ) return null;
				else return drV2.RecommendedRelatedness;
			}
			else {
				return null;//The record wasn't contained in the links created in 2004.
			}
		}
		private float? CalculateRRoster ( Int32 idRelated ) {
			//Check overrides first.
			//throw new NotImplementedException();

			LinksDataSet.tblRosterGen1Row dr = _dsLinks.tblRosterGen1.FindByRelatedID(idRelated);
			Trace.Assert(dr != null, "Exactly one row should be retrieved from tblRosterGen1.");
			if ( dr.Resolved ) {
				Trace.Assert(!dr.IsRNull(), "If R is resolved by the roster, then R shouldn't be NaN.");
				return (float?)dr.R;
			}
			else {
				return null;
			}
		}
		private float? CalculateRExplicitSingleSibVersion ( Int32 idRelated, Int32 subjectTag ) {
			//MarkerGen1Summary roster = MarkerGen1.RetrieveMarker(idRelated, MarkerType.RosterGen1, _dtMarkersGen1);
			//MarkerGen1Summary[] biomomMarkers = MarkerGen1.RetrieveMarkers(idRelated, MarkerType.ShareBiomom, _dtMarkersGen1, ItemYears.Gen1ShareBiomom.Length);
			//MarkerGen1Summary[] biodadMarkers = MarkerGen1.RetrieveMarkers(idRelated, MarkerType.ShareBiodad, _dtMarkersGen1, ItemYears.Gen1ShareBiodad.Length);
			QuadState shareBiomom = ReduceShareBioparentToOne(MarkerType.ShareBiomom, ItemYears.Gen1ShareBiomom.Length, idRelated);
			QuadState shareBiodad = ReduceShareBioparentToOne(MarkerType.ShareBiodad, ItemYears.Gen1ShareBiodad.Length, idRelated);
			//if ( biomom == null || biodad == null ) {
			//   return null;
			//}
			//else if ( biomom.ShareBiomom == MarkerEvidence.Supports && biodad.ShareBiodad == MarkerEvidence.Supports ) {
			//   //if ( !OverridesGen1.RosterAndExplicit.Contains(subjectTag) ) {
			//   //   Trace.Assert(roster.ShareBiomom != MarkerEvidence.Disconfirms);
			//   //   Trace.Assert(roster.ShareBiodad != MarkerEvidence.Disconfirms);
			//   //}
			//   return RCoefficients.SiblingFull;
			//}
			//else if ( biomom.ShareBiomom == MarkerEvidence.Disconfirms && biodad.ShareBiodad == MarkerEvidence.Supports ) {
			//   //Trace.Assert(roster.ShareBiomom != MarkerEvidence.Disconfirms);
			//   //Trace.Assert(roster.ShareBiodad != MarkerEvidence.Disconfirms);
			//   return RCoefficients.SiblingHalf;
			//}
			//else if ( biomom.ShareBiomom == MarkerEvidence.Supports && biodad.ShareBiodad == MarkerEvidence.Disconfirms ) {
			//   //if ( !OverridesGen1.RosterAndExplicit.Contains(subjectTag) ) {
			//   //   Trace.Assert(roster.ShareBiomom != MarkerEvidence.Disconfirms);
			//   //   Trace.Assert(roster.ShareBiodad != MarkerEvidence.Disconfirms);
			//   //}
			//   return RCoefficients.SiblingHalf;
			//}
			////else if ( biomom.ShareBiomom == MarkerEvidence.Disconfirms && biodad.ShareBiodad == MarkerEvidence.Disconfirms ) {
			////   return RCoefficients.NotRelated;//The could still be cousins or something else
			////}
			//else {
			//   return null;
			//}
			throw new NotImplementedException();
		}
		private float? CalculateRExplicitPass1 ( ) {
			if ( !RExplicitOldestSibVersion.HasValue && !RExplicitYoungestSibVersion.HasValue )
				return null;
			else if ( !RExplicitOldestSibVersion.HasValue )
				return RExplicitYoungestSibVersion.Value;
			else if ( !RExplicitYoungestSibVersion.HasValue )
				return RExplicitOldestSibVersion.Value;
			else if ( RExplicitOldestSibVersion.Value == RExplicitYoungestSibVersion.Value )
				return RExplicitOldestSibVersion.Value;
			else if ( RExplicitOldestSibVersion.Value == RCoefficients.SiblingAmbiguous )
				return RExplicitYoungestSibVersion.Value;
			else if ( RExplicitYoungestSibVersion.Value == RCoefficients.SiblingAmbiguous )
				return RExplicitOldestSibVersion.Value;
			else if ( RExplicitOldestSibVersion.Value == RCoefficients.SiblingFull && RExplicitYoungestSibVersion.Value == RCoefficients.SiblingHalf )
				return RCoefficients.SiblingAmbiguous;
			else if ( RExplicitYoungestSibVersion.Value == RCoefficients.SiblingFull && RExplicitOldestSibVersion.Value == RCoefficients.SiblingHalf )
				return RCoefficients.SiblingAmbiguous;
			else
				throw new InvalidOperationException("All condition should have been caught.");
		}
		private float? CalculateRPass1 ( ) {
			float? rRoster = CalculateRRoster(_idRelatedOlderAboutYounger);

			if ( this.IsMZ == BaseAssembly.Tristate.Yes ) {
				return RCoefficients.MzTrue;
			}
			else if (  _isRelatedInMZManual == Tristate.No ) {
				return RCoefficients.NotRelated; //Of the 21 Gen1 subjects in tblMZManual with Related=0, 17 ended up with R=0 (as of 11/9/2012).  1 was assigned R=.5; 3 were assigned R=NULL (which I want to override now here, looking at the DOB differences).
			}
			else if ( IsMZ == BaseAssembly.Tristate.DoNotKnow && _isRelatedInMZManual == Tristate.Yes ) {
				Trace.Assert(this.MultipleBirthIfSameSex == MultipleBirth.Twin || this.MultipleBirthIfSameSex == MultipleBirth.Trip || this.MultipleBirthIfSameSex == MultipleBirth.TwinOrTrip, "To be assigned full sib, they've got to be assigned to be a twin/trip.");
				return RCoefficients.MzAmbiguous;
			}
			else if ( this.MultipleBirthIfSameSex == MultipleBirth.Twin || this.MultipleBirthIfSameSex == MultipleBirth.Trip || this.MultipleBirthIfSameSex == MultipleBirth.TwinOrTrip ) {
				return RCoefficients.SiblingFull;
			}
			else if ( rRoster.HasValue ) {
				return rRoster;
			}
			else if ( RExplicitPass1.HasValue ) {
				return RExplicitPass1;
			}
			//else if ( RImplicit2004.HasValue ) {
			//   return RImplicit2004;
			//}
			//else if ( RImplicitPass1.HasValue ) {
			//   return RImplicitPass1;
			//}
			else {
				return null;
			}
		}
		private QuadState ReduceShareBioparentToOne ( MarkerType markerType, Int32 maxMarkerCount, Int32 idRelated ) {
			MarkerGen1Summary[] summaries = MarkerGen1.RetrieveMarkers(idRelated, markerType, _dtMarkersGen1, maxMarkerCount);
			if ( summaries.Length <= 0 )
				return QuadState.Missing;

			IEnumerable<MarkerEvidence> evidences;
			if ( markerType == MarkerType.ShareBiodad )
				evidences = from summary in summaries select summary.ShareBiodad;
			else if ( markerType == MarkerType.ShareBiomom )
				evidences = from summary in summaries select summary.ShareBiomom;
			else
				throw new ArgumentOutOfRangeException("markerType", markerType, "The 'ReduceShareBiodadToOne' function does not accommodoate this markerType.");


			if ( evidences.All(evidence => evidence == MarkerEvidence.Supports) ) {
				return QuadState.Yes;
			}
			else if ( evidences.All(evidence => evidence == MarkerEvidence.Disconfirms) ) {
				return QuadState.No;
			}
			else if ( evidences.All(evidence => evidence == MarkerEvidence.Ambiguous) ) {
				return QuadState.Conflicting;
			}
			else if ( evidences.Any(evidence => evidence == MarkerEvidence.Irrelevant) ) {
				throw new NotImplementedException("This function was not designed to accept this evidence value.");
			}
			else if ( evidences.Any(evidence => evidence == MarkerEvidence.Consistent) ) {
				throw new NotImplementedException("This function was not designed to accept this evidence value.");
			}
			else if ( evidences.Any(evidence => evidence == MarkerEvidence.Unlikely) ) {
				throw new NotImplementedException("This function was not designed to accept this evidence value.");
			}
			else {
				return QuadState.Conflicting;
			}
		}
		#endregion
	}
}