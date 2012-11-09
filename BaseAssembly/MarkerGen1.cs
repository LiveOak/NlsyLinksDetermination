using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Nls.BaseAssembly {
	public sealed class MarkerGen1 {
		#region Fields
		private readonly LinksDataSet _dsLinks;
		private readonly ItemYearCount _itemYearCount;
		private readonly Item[] _items = { Item.IDOfOther1979RosterGen1, Item.RosterGen1979, Item.IDCodeOfOtherSiblingGen1, Item.ShareBiomomGen1, Item.ShareBiodadGen1 };
		private readonly string _itemIDsString = "";
		#endregion
		#region Constructor
		public MarkerGen1 ( LinksDataSet dsLinks ) {
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( dsLinks.tblSubject.Count <= 0 ) throw new ArgumentException("There shouldn't be zero rows in tblSubject.");
			if ( dsLinks.tblRelatedStructure.Count <= 0 ) throw new ArgumentException("There shouldn't be zero rows in tblRelatedStructure.");
			if ( dsLinks.tblRosterGen1.Count <= 0 ) throw new ArgumentException("There shouldn't be zero rows in tblRosterGen1.");
			if ( dsLinks.tblMarkerGen1.Count != 0 ) throw new ArgumentException("There should be zero rows in tblMarkerGen1.");
			_dsLinks = dsLinks;
			_itemYearCount = new ItemYearCount(_dsLinks);
			_itemIDsString = CommonCalculations.ConvertItemsToString(_items);
		}
		#endregion
		#region  Public Methods
		public string Go ( ) {
			Stopwatch sw = new Stopwatch();
			sw.Start();
			Retrieve.VerifyResponsesExistForItem(_items, _dsLinks);
			Int32 recordsAdded = 0;
			foreach ( LinksDataSet.tblRelatedStructureRow drRelated in _dsLinks.tblRelatedStructure ) {
				if ( (RelationshipPath)drRelated.RelationshipPath == RelationshipPath.Gen1Housemates ) {
					Int32 subject1Tag = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1.SubjectTag;
					//Int32 subject2Tag = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject2.SubjectTag;
					LinksDataSet.tblResponseDataTable dtSubject1 = Retrieve.SubjectsRelevantResponseRows(subject1Tag, _itemIDsString, 1, _dsLinks.tblResponse);
					//LinksDataSet.tblResponseDataTable dtSubject2 = Retrieve.SubjectsRelevantResponseRows(subject2Tag, _itemIDsString, _dsLinks);
					//SurveyTime.SubjectSurvey[] surveysSubject1 = SurveyTime.RetrieveSubjectSurveys(subject1Tag, _dsLinks);
					//SurveyTime.SubjectSurvey[] surveysSubject2 = SurveyTime.RetrieveSubjectSurveys(subject2Tag, _dsLinks);

					recordsAdded += FromRoster(drRelated, dtSubject1);
					recordsAdded += FromShareBiomom(drRelated, dtSubject1);
					recordsAdded += FromShareBiodad(drRelated, dtSubject1);
				}
			}
			sw.Stop();
			string message = string.Format("{0:N0} Gen1 Markers were processed.\n\nElapsed time: {1}", recordsAdded, sw.Elapsed.ToString());
			return message;
		}
		#endregion
		#region Public Static Methods
		internal static MarkerGen1Summary RetrieveMarker ( Int64 relatedIDLeft, MarkerType markerType, LinksDataSet.tblMarkerGen1DataTable dtMarker ) {
			if ( dtMarker == null ) throw new ArgumentNullException("dtMarker");
			string select = string.Format("{0}={1} AND {2}={3}",
				relatedIDLeft, dtMarker.RelatedIDColumn.ColumnName,
				(byte)markerType, dtMarker.MarkerTypeColumn.ColumnName);
			LinksDataSet.tblMarkerGen1Row[] drs = (LinksDataSet.tblMarkerGen1Row[])dtMarker.Select(select);
			//Trace.Assert(drs.Length <= 1, "The number of returns markers should not exceed 1.");
			switch ( drs.Length ) {
				case 0: return null;
				//case 1: return new MarkerGen1Summary(					(MarkerEvidence)drs[0].SameGeneration, (MarkerEvidence)drs[0].ShareBiomomEvidence, (MarkerEvidence)drs[0].ShareBiodadEvidence, (MarkerEvidence)drs[0].ShareBioGrandparentEvidence);
				case 1: return new MarkerGen1Summary((MarkerEvidence)drs[0].SameGeneration, (MarkerEvidence)drs[0].ShareBiomomEvidence, (MarkerEvidence)drs[0].ShareBiodadEvidence, (MarkerEvidence)drs[0].ShareBioGrandparentEvidence);

				//(bool)drs[0].RosterResolved, (float)drs[0].RosterR, (float)drs[0].RosterRBoundLower, (float)drs[0].RosterRBoundUpper,
				default: throw new InvalidOperationException("The number of returns markers should not exceed 1.");
			}
		}
		internal static LinksDataSet.tblMarkerGen1DataTable PairRelevantMarkerRows ( Int64 relatedIDLeft, Int64 relatedIDRight, LinksDataSet dsLinks, Int32 extendedID ) {
			string select = string.Format("{0}={1} AND {2} IN ({3},{4})",
				extendedID, dsLinks.tblMarkerGen1.ExtendedIDColumn.ColumnName,
				dsLinks.tblMarkerGen1.RelatedIDColumn.ColumnName, relatedIDLeft, relatedIDRight);
			LinksDataSet.tblMarkerGen1Row[] drs = (LinksDataSet.tblMarkerGen1Row[])dsLinks.tblMarkerGen1.Select(select);
			//if ( drs.Length <= 0 ) {
			//   return null;
			//}
			//else {
			LinksDataSet.tblMarkerGen1DataTable dt = new LinksDataSet.tblMarkerGen1DataTable();
			foreach ( LinksDataSet.tblMarkerGen1Row dr in drs ) {
				dt.ImportRow(dr);
			}
			return dt;
		}
		#endregion
		#region Private Methods -Tier 1
		private Int32 FromRoster ( LinksDataSet.tblRelatedStructureRow drRelated, LinksDataSet.tblResponseDataTable dtSubject1 ) {
			const MarkerType markerType = MarkerType.RosterGen1;
			MarkerGen1Summary roster = RosterGen1.RetrieveSummary(drRelated.ID, _dsLinks.tblRosterGen1);

			MarkerEvidence mzEvidence;
			if ( roster.ShareBiomom == MarkerEvidence.StronglySupports && roster.ShareBiodad == MarkerEvidence.StronglySupports )
				mzEvidence = MarkerEvidence.Consistent;
			else
				mzEvidence = MarkerEvidence.Disconfirms;

			AddMarkerRow(drRelated.ExtendedID, drRelated.ID, markerType, ItemYears.Gen1Roster, mzEvidence, roster.SameGeneration, roster.ShareBiomom, roster.ShareBiodad, roster.ShareBiograndparent);
			const Int32 recordsAdded = 1;
			return recordsAdded;
		}
		private Int32 FromShareBiomom ( LinksDataSet.tblRelatedStructureRow drRelated, LinksDataSet.tblResponseDataTable dtSubject1 ) {
			const Item itemID = Item.IDCodeOfOtherSiblingGen1;
			const Item itemRelationship = Item.ShareBiomomGen1;
			const MarkerType markerType = MarkerType.ShareBiomom;
			Int32 surveyYearCount = _itemYearCount.ShareBiomomGen1;

			LinksDataSet.tblSubjectRow drSubject1 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1;
			LinksDataSet.tblSubjectRow drSubject2 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject2;

			//Use the other subject's ID to find the appropriate 'loop index';
			string selectToGetLoopIndex = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				drSubject1.SubjectTag, dtSubject1.SubjectTagColumn.ColumnName,
				(byte)itemID, dtSubject1.ItemColumn.ColumnName,
				drSubject2.SubjectID, dtSubject1.ValueColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsForLoopIndex = (LinksDataSet.tblResponseRow[])dtSubject1.Select(selectToGetLoopIndex);
			Trace.Assert(drsForLoopIndex.Length <= surveyYearCount, string.Format("No more than {0} row(s) should be returned that matches Subject2 for item '{1}'.", surveyYearCount, itemID.ToString()));

			if ( drsForLoopIndex.Length == 0 )
				return 0;

			//Use the loop index (that corresponds to the other subject) to find the ShareBiomom response.
			LinksDataSet.tblResponseRow drResponse = drsForLoopIndex[0];
			string selectToShareResponse = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				drSubject1.SubjectTag, dtSubject1.SubjectTagColumn.ColumnName,
				(byte)itemRelationship, dtSubject1.ItemColumn.ColumnName,
				drResponse.LoopIndex, dtSubject1.LoopIndexColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsForShareResponse = (LinksDataSet.tblResponseRow[])dtSubject1.Select(selectToShareResponse);
			switch ( drsForShareResponse.Length ) {
				case 0:
					return 0;
				case 1:
					EnumResponsesGen1.ShareBioparentGen1 shareBioparent = (EnumResponsesGen1.ShareBioparentGen1)drsForShareResponse[0].Value;

					MarkerEvidence evidence = Assign.EvidenceGen1.ShareBioparentsForBioparents(shareBioparent);
					MarkerEvidence mzEvidence;
					if ( evidence == MarkerEvidence.StronglySupports ) mzEvidence = MarkerEvidence.Consistent;
					else mzEvidence = MarkerEvidence.Disconfirms;

					MarkerEvidence sameGeneration;
					if ( evidence == MarkerEvidence.Supports || evidence == MarkerEvidence.StronglySupports )
						sameGeneration = MarkerEvidence.StronglySupports;
					else
						sameGeneration = MarkerEvidence.Ambiguous;

					AddMarkerRow(drRelated.ExtendedID, drRelated.ID, markerType, drResponse.SurveyYear, mzEvidence, sameGeneration,evidence, MarkerEvidence.Irrelevant, evidence);
					const Int32 recordsAdded = 1;
					return recordsAdded;
				default:
					throw new InvalidOperationException("Only zero or one rows should be returned for the Item.ShareBiomomGen1 item to Subject2");
			}
		}
		private Int32 FromShareBiodad ( LinksDataSet.tblRelatedStructureRow drRelated, LinksDataSet.tblResponseDataTable dtSubject1 ) {
			const Item itemID = Item.IDCodeOfOtherSiblingGen1;
			const Item itemRelationship = Item.ShareBiodadGen1;
			const MarkerType markerType = MarkerType.ShareBiodad;
			Int32 surveyYearCount = _itemYearCount.ShareBiodadGen1;

			LinksDataSet.tblSubjectRow drSubject1 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1;
			LinksDataSet.tblSubjectRow drSubject2 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject2;

			//Use the other subject's ID to find the appropriate 'loop index';
			string selectToGetLoopIndex = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				drSubject1.SubjectTag, dtSubject1.SubjectTagColumn.ColumnName,
				(byte)itemID, dtSubject1.ItemColumn.ColumnName,
				drSubject2.SubjectID, dtSubject1.ValueColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsForLoopIndex = (LinksDataSet.tblResponseRow[])dtSubject1.Select(selectToGetLoopIndex);
			Trace.Assert(drsForLoopIndex.Length <= surveyYearCount, string.Format("No more than {0} row(s) should be returned that matches Subject2 for item '{1}'.", surveyYearCount, itemID.ToString()));

			if ( drsForLoopIndex.Length == 0 )
				return 0;

			//Use the loop index (that corresponds to the other subject) to find the ShareBiomom response.
			LinksDataSet.tblResponseRow drResponse = drsForLoopIndex[0];
			string selectToShareResponse = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				drSubject1.SubjectTag, dtSubject1.SubjectTagColumn.ColumnName,
				(byte)itemRelationship, dtSubject1.ItemColumn.ColumnName,
				drResponse.LoopIndex, dtSubject1.LoopIndexColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsForShareResponse = (LinksDataSet.tblResponseRow[])dtSubject1.Select(selectToShareResponse);
			switch ( drsForShareResponse.Length ) {
				case 0:
					return 0;
				case 1:
					EnumResponsesGen1.ShareBioparentGen1 shareBioparent = (EnumResponsesGen1.ShareBioparentGen1)drsForShareResponse[0].Value;

					MarkerEvidence evidence = Assign.EvidenceGen1.ShareBioparentsForBioparents(shareBioparent);
					MarkerEvidence mzEvidence;
					if ( evidence == MarkerEvidence.StronglySupports ) mzEvidence = MarkerEvidence.Consistent;
					else mzEvidence = MarkerEvidence.Disconfirms;

					MarkerEvidence sameGeneration;
					if ( evidence == MarkerEvidence.Supports || evidence == MarkerEvidence.StronglySupports )
						sameGeneration = MarkerEvidence.StronglySupports;
					else
						sameGeneration = MarkerEvidence.Ambiguous;

					AddMarkerRow(drRelated.ExtendedID, drRelated.ID, markerType, drResponse.SurveyYear, mzEvidence, sameGeneration, MarkerEvidence.Irrelevant, evidence, evidence);
					const Int32 recordsAdded = 1;
					return recordsAdded;
				default:
					throw new InvalidOperationException("Only zero or one rows should be returned for the Item.ShareBiodadGen1 item to Subject2");
			}
		}
		#endregion
		#region Tier 2
		private void AddMarkerRow ( Int32 extendedID, Int32 relatedID, MarkerType markerType, Int16 surveyYear, MarkerEvidence mzEvidence, MarkerEvidence sameGenerationEvidence, MarkerEvidence biomomEvidence, MarkerEvidence biodadEvidence, MarkerEvidence biograndparentEvidence ) {
			LinksDataSet.tblMarkerGen1Row drNew = _dsLinks.tblMarkerGen1.NewtblMarkerGen1Row();
			drNew.ExtendedID = extendedID	;
			drNew.RelatedID = relatedID;
			drNew.MarkerType = (byte)markerType;
			drNew.SurveyYear = surveyYear;
			drNew.MzEvidence = (byte)mzEvidence;
			drNew.SameGeneration = (byte)sameGenerationEvidence;
			drNew.ShareBiomomEvidence = (byte)biomomEvidence;
			drNew.ShareBiodadEvidence = (byte)biodadEvidence;
			drNew.ShareBioGrandparentEvidence = (byte)biograndparentEvidence;

			_dsLinks.tblMarkerGen1.AddtblMarkerGen1Row(drNew);
		}
		#endregion
	}
}

//internal static MarkerGen1Summary[] RetrieveMarkers ( Int64 relatedIDLeft, MarkerType markerType, LinksDataSet.tblMarkerGen1DataTable dtMarker, Int32 maxCount ) {
//   if ( dtMarker == null ) throw new ArgumentNullException("dtMarker");
//   string select = string.Format("{0}={1} AND {2}={3}",
//      relatedIDLeft, dtMarker.RelatedIDColumn.ColumnName,
//      (byte)markerType, dtMarker.MarkerTypeColumn.ColumnName);
//   string sort = dtMarker.SurveyYearColumn.ColumnName;
//   LinksDataSet.tblMarkerGen1Row[] drs = (LinksDataSet.tblMarkerGen1Row[])dtMarker.Select(select, sort);
//   Trace.Assert(drs.Length <= maxCount, "The number of returns markers should not exceed " + maxCount + ".");
//   MarkerGen1Summary[] evidences = new MarkerGen1Summary[drs.Length];
//   for ( Int32 i = 0; i < drs.Length; i++ ) {
//      evidences[i] = new MarkerGen1Summary((MarkerEvidence)drs[i].MzEvidence, (MarkerEvidence)drs[i].ShareBiomomEvidence, (MarkerEvidence)drs[i].ShareBiodadEvidence, (MarkerEvidence)drs[i].ShareBioGrandparentEvidence);
//   }
//   return evidences;
//}

//private Int32 FromRoster ( LinksDataSet.tblRelatedStructureRow drRelated, LinksDataSet.tblResponseDataTable dtSubject1 ) {
//      const Item itemID = Item.IDOfOther1979RosterGen1;
//      const Item itemRelationship = Item.RosterGen11979;
//      const MarkerType markerType = MarkerType.RosterGen1;
//      LinksDataSet.tblSubjectRow drSubject1 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1;
//      LinksDataSet.tblSubjectRow drSubject2 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject2;

//      Int32 surveyYearCount = _itemYearCount.ShareRosterGen1;


//      //Use the other subject's ID to find the appropriate 'loop index';
//      string selectToGetLoopIndex = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
//         drSubject1.SubjectTag, dtSubject1.SubjectTagColumn.ColumnName,
//         (byte)itemID, dtSubject1.ItemColumn.ColumnName,
//         drSubject2.SubjectID, dtSubject1.ValueColumn.ColumnName);
//      LinksDataSet.tblResponseRow[] drsForLoopIndex = (LinksDataSet.tblResponseRow[])dtSubject1.Select(selectToGetLoopIndex);
//      Trace.Assert(drsForLoopIndex.Length <= surveyYearCount, string.Format("No more than {0} row(s) should be returned that matches Subject2 for item '{1}'.", surveyYearCount, itemID.ToString()));
//      Int32 recordsAdded = 0;

//      //Use the loop index (that corresponds to the other subject) to find the roster response.
//      LinksDataSet.tblResponseRow drResponse = drsForLoopIndex[0];
//      string selectToShareResponse = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
//         drSubject1.SubjectTag, dtSubject1.SubjectTagColumn.ColumnName,
//         (byte)itemRelationship, dtSubject1.ItemColumn.ColumnName,
//         drResponse.LoopIndex, dtSubject1.LoopIndexColumn.ColumnName);
//      LinksDataSet.tblResponseRow[] drsForShareResponse = (LinksDataSet.tblResponseRow[])dtSubject1.Select(selectToShareResponse);
//      Trace.Assert(drsForShareResponse.Length == 1, "Exactly one row should be returned for the Item.RosterGen11979 item to Subject2");
//      EnumResponsesGen1.Gen1Roster rosterRelationship = (EnumResponsesGen1.Gen1Roster)drsForShareResponse[0].Value;

//      MarkerGen1Summary evidencePackage = Assign.EvidenceGen1.ShareBioparentRoster1979(rosterRelationship);

//      MarkerEvidence mzEvidence;
//      if ( evidencePackage.ShareBiomom == MarkerEvidence.StronglySupports && evidencePackage.ShareBiodad == MarkerEvidence.StronglySupports )
//         mzEvidence = MarkerEvidence.Consistent;
//      else
//         mzEvidence = MarkerEvidence.Disconfirms;
//      AddMarkerRow(drRelated.ExtendedID, drRelated.ID, markerType, drResponse.SurveyYear, mzEvidence, evidencePackage.SameGeneration, evidencePackage.ShareBiomom, evidencePackage.ShareBiodad, evidencePackage.ShareBiograndparent);
//      recordsAdded += 1;

//      return recordsAdded;
//   }