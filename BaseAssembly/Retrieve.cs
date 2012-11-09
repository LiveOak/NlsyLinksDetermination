using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;

namespace Nls.BaseAssembly {
	public static class Retrieve {
		#region Response
		internal static Int32 Response ( Item itemID, Int32 subjectTag, LinksDataSet.tblResponseDataTable dt ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			string select = string.Format("{0}={1} AND {2}={3}",
				subjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)itemID, dt.ItemColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
			Trace.Assert(drsRaw.Length == 1, "Exactly one row should be returned.");
			return drsRaw[0].Value;
		}
		internal static Int32 Response ( Int16 surveyYear, Item itemID, Int32 subjectTag, Int32 maxRows, LinksDataSet.tblResponseDataTable dt ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			string select = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				subjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)itemID, dt.ItemColumn.ColumnName,
				surveyYear, dt.SurveyYearColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
			Trace.Assert(drsRaw.Length <= maxRows, "At most, " + maxRows + " row(s) should be returned.");
			return drsRaw[0].Value;
		}
		//internal static Int32 Response ( Int16 surveyYear, Item itemID, SurveySource surveySource, Int32 subjectTag, LinksDataSet.tblResponseDataTable dt ) {
		//   if ( dt == null ) throw new ArgumentNullException("dt");
		//   string select = string.Format("{0}={1} AND {2}={3} AND {4}={5} AND {6}={7}",
		//      subjectTag, dt.SubjectTagColumn.ColumnName,
		//      (byte)itemID, dt.ItemColumn.ColumnName,
		//      surveyYear, dt.SurveyYearColumn.ColumnName,
		//      (byte)surveySource, dt.SurveySourceColumn.ColumnName);
		//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
		//   Trace.Assert(drsRaw.Length ==1, "Exactly one row should be returned.");
		//   return drsRaw[0].Value;
		//}
		//internal static Int32 Response ( Int16 surveyYear, Item itemID, SurveySource surveySource, Int32 subjectTag, Int32 minRowCount, Int32 maxRowCount, LinksDataSet.tblResponseDataTable dt ) {
		//   if ( dt == null ) throw new ArgumentNullException("dt");
		//   string select = string.Format("{0}={1} AND {2}={3} AND {4}={5} AND {6}={7}",
		//      subjectTag, dt.SubjectTagColumn.ColumnName,
		//      (byte)itemID, dt.ItemColumn.ColumnName,
		//      surveyYear, dt.SurveyYearColumn.ColumnName,
		//      (byte)surveySource, dt.SurveySourceColumn.ColumnName);
		//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
		//   Trace.Assert(drsRaw.Length >= minRowCount, "At least " + minRowCount + " row(s) should be returned.");
		//   Trace.Assert(drsRaw.Length <= maxRowCount, "At most " + maxRowCount + " row(s) should be returned.");
		//   return drsRaw[0].Value;
		//}
		//internal static Int16[] ResponseArray ( Item itemID, Int32 subjectTag, byte loopIndex, LinksDataSet.tblResponseDataTable dt ) {
		//   if ( dt == null ) throw new ArgumentNullException("dt");
		//   string select = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
		//      subjectTag, dt.SubjectTagColumn.ColumnName,
		//      loopIndex, dt.LoopIndexColumn.ColumnName,
		//      (byte)itemID, dt.ItemColumn.ColumnName);
		//   LinksDataSet.tblResponseRow[] drs = (LinksDataSet.tblResponseRow[])dt.Select(select);
		//   IEnumerable<Int16> values = from dr in drs
		//                               orderby dr.SurveyYear
		//                               select dr.Value;
		//   return values.ToArray();
		//}
		#endregion
		#region ResponseNullPossible
		internal static Int32? ResponseNullPossible ( Item itemID, Int32 subjectTag, LinksDataSet.tblResponseDataTable dt ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			string select = string.Format("{0}={1} AND {2}={3}",
				subjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)itemID, dt.ItemColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
			Trace.Assert(drsRaw.Length <= 1, "At most one row should be returned.");
			if ( drsRaw.Length == 0 )
				return null;
			else
				return drsRaw[0].Value;
		}
		internal static Int32? ResponseNullPossible ( Int16 surveyYear, Item itemID, Int32 subjectTag,  LinksDataSet.tblResponseDataTable dt ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			string select = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				subjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)itemID, dt.ItemColumn.ColumnName,
				surveyYear, dt.SurveyYearColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
			Trace.Assert(drsRaw.Length <= 1, "At most one row should be returned.");
			if ( drsRaw.Length == 0 )
				return null;
			else
				return drsRaw[0].Value;
		}
		internal static Int32? ResponseNullPossible ( Int16 surveyYear, Item itemID, Int32 subjectTag, byte loopIndex, LinksDataSet.tblResponseDataTable dt ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			string select = string.Format("{0}={1} AND {2}={3} AND {4}={5} AND {6}={7}",
				subjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)itemID, dt.ItemColumn.ColumnName,
				surveyYear, dt.SurveyYearColumn.ColumnName,
				loopIndex, dt.LoopIndexColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
			Trace.Assert(drsRaw.Length <= 1, "At most one row should be returned.");
			if ( drsRaw.Length == 0 )
				return null;
			else
				return drsRaw[0].Value;
		}
		internal static Int32? ResponseNullPossible (  Item itemID, SurveySource surveySource, Int32 subjectTag, Int32 maxRows, LinksDataSet.tblResponseDataTable dt ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			string select = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				subjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)itemID, dt.ItemColumn.ColumnName,
				(byte)surveySource, dt.SurveySourceColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
			Trace.Assert(drsRaw.Length <= maxRows, "At most, " + maxRows + " row(s) should be returned.");
			if ( drsRaw.Length == 0 )
				return null;
			else
				return drsRaw[0].Value;
		}
		internal static Int32? ResponseNullPossible ( Int16 surveyYear, Item itemID, SurveySource surveySource, Int32 subjectTag, Int32 maxRows, LinksDataSet.tblResponseDataTable dt ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			string select = string.Format("{0}={1} AND {2}={3} AND {4}={5} AND {6}={7}",
				subjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)itemID, dt.ItemColumn.ColumnName,
				surveyYear, dt.SurveyYearColumn.ColumnName,
				(byte)surveySource, dt.SurveySourceColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])dt.Select(select);
			Trace.Assert(drsRaw.Length <= maxRows, "At most, " + maxRows + " row(s) should be returned.");
			if ( drsRaw.Length == 0 )
				return null;
			else
				return drsRaw[0].Value;
		}
		#endregion
		#region ResponseSubset
		internal static void VerifyResponsesExistForItem ( Item[] items, LinksDataSet dsLinks ) {
			Int32 distinctCount = items.Distinct().Count();
			if ( distinctCount != items.Length ) throw new ArgumentException("Not all items are unique.");

			foreach ( Item item in items ) {
				string select = string.Format("{0}={1}", (byte)item, dsLinks.tblResponse.ItemColumn.ColumnName);
				LinksDataSet.tblResponseRow[] drs = (LinksDataSet.tblResponseRow[])dsLinks.tblResponse.Select(select);
				if ( !(drs.Length >= 1) ) throw new ArgumentOutOfRangeException("items", item, "The " + item.ToString() + " was not found in the local copy of dtResponse.");
			}
		}
		internal static LinksDataSet.tblResponseDataTable SubjectsRelevantResponseRows ( Int32 subjectTag, string itemIDsString, Int32 minRowCount,  LinksDataSet.tblResponseDataTable dtResponse ) {
			string select = string.Format("{0}={1} AND {2} in ({3})",
				subjectTag, dtResponse.SubjectTagColumn.ColumnName,
				dtResponse.ItemColumn.ColumnName, itemIDsString);
			LinksDataSet.tblResponseRow[] drs = (LinksDataSet.tblResponseRow[])dtResponse.Select(select);
			Trace.Assert(drs.Length >= minRowCount, "There should be at least " + minRowCount +" row(s) returned.");

			LinksDataSet.tblResponseDataTable dt = new LinksDataSet.tblResponseDataTable();
			foreach ( LinksDataSet.tblResponseRow dr in drs ) {
				dt.ImportRow(dr);
			}
			return dt;
		}
		internal static LinksDataSet.tblResponseDataTable ExtendedFamilyRelevantResponseRows ( Int32 extendedFamilyID, string itemIDsString, Int32 minRowCount, LinksDataSet.tblResponseDataTable dtResponse ) {
			string select = string.Format("{0}={1} AND {2} in ({3})",
				extendedFamilyID, dtResponse.ExtendedIDColumn.ColumnName,
				dtResponse.ItemColumn.ColumnName, itemIDsString);
			LinksDataSet.tblResponseRow[] drs = (LinksDataSet.tblResponseRow[])dtResponse.Select(select);

			Trace.Assert(drs.Length >= 0, "There should be at least " + minRowCount + "  row(s) returned.");

			LinksDataSet.tblResponseDataTable dt = new LinksDataSet.tblResponseDataTable();
			foreach ( LinksDataSet.tblResponseRow dr in drs ) {
				dt.ImportRow(dr);
			}
			return dt;
		}
		#endregion
		#region Other
		internal static LinksDataSet.tblSubjectRow[] SubjectsInExtendFamily ( Int32 extendedID, LinksDataSet.tblSubjectDataTable dtSubject ) {
			string select = string.Format("{0}={1}", extendedID, dtSubject.ExtendedIDColumn.ColumnName);
			LinksDataSet.tblSubjectRow[] drs = (LinksDataSet.tblSubjectRow[])dtSubject.Select(select);
			Trace.Assert(drs.Length > 0, "At least one member of the extended family should be returned.");
			return drs;
		}
		internal static EnumResponsesGen1.Gen1Roster Gen1Roster1979 ( LinksDataSet.tblRelatedStructureRow drRelated, LinksDataSet.tblResponseDataTable dt ) {//LinksDataSet.tblSubjectRow drSubject1, LinksDataSet.tblSubjectRow drSubject2 ) {
			if ( dt == null ) throw new ArgumentNullException("dt");
			if ( drRelated == null ) throw new ArgumentNullException("drRelated");
			const Int32 expectedSurveyYear = 1979;
			LinksDataSet.tblSubjectRow drSubject1 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject1;
			LinksDataSet.tblSubjectRow drSubject2 = drRelated.tblSubjectRowByFK_tblRelatedStructure_tblSubject_Subject2;

			//IEnumerable<LinksDataSet.tblResponseRow> drsResponse
			//   = from dr in _dsLinks.tblResponse
			//     where (dr.SubjectTag == drSubject1.SubjectTag) && (dr.Item == (byte)Item.IDOfOther1979RosterGen1) && (dr.Value == drSubject2.SubjectID)
			//     select dr;

			string selectToGetLoopIndex = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				drSubject1.SubjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)Item.IDOfOther1979RosterGen1, dt.ItemColumn.ColumnName,
				drSubject2.SubjectID, dt.ValueColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsForLoopIndex = (LinksDataSet.tblResponseRow[])dt.Select(selectToGetLoopIndex);
			Trace.Assert(drsForLoopIndex.Length == 1, "Exactly one row should be returned matching Subject2");
			Trace.Assert(drsForLoopIndex[0].SurveyYear == expectedSurveyYear, "The SurveyYear should be " + expectedSurveyYear);
			Int32 loopIndex = drsForLoopIndex[0].LoopIndex;

			string selectToRoster = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				drSubject1.SubjectTag, dt.SubjectTagColumn.ColumnName,
				(byte)Item.RosterGen1979, dt.ItemColumn.ColumnName,
				loopIndex, dt.LoopIndexColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsForRoster = (LinksDataSet.tblResponseRow[])dt.Select(selectToRoster);
			Trace.Assert(drsForRoster.Length == 1, "Exactly one row should be returned for the Roster relationship to Subject2");
			Trace.Assert(drsForRoster[0].SurveyYear == expectedSurveyYear, "The SurveyYear should be " + expectedSurveyYear);
			EnumResponsesGen1.Gen1Roster relationship = (EnumResponsesGen1.Gen1Roster)drsForRoster[0].Value;
			return relationship;
		}
		internal static Int32 SubjectTagFromSubjectIDAndGeneration ( Int32 subjectID, Generation generation, LinksDataSet dsLinks ) {
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( dsLinks.tblSubject.Count <= 0 ) throw new InvalidOperationException("There should be more than one row in tblSubject.");

			string select = string.Format("{0} = {1} AND {2} = {3}",
				 dsLinks.tblSubject.SubjectIDColumn.ColumnName, subjectID,
				(byte)generation, dsLinks.tblSubject.GenerationColumn.ColumnName);
			LinksDataSet.tblSubjectRow[] drs = (LinksDataSet.tblSubjectRow[])dsLinks.tblSubject.Select(select);
			Trace.Assert(drs.Length == 1, "The should be exactly one SubjectRow retreived.");
			return drs[0].SubjectTag;
		}
		internal static LinksDataSet.tblMzManualRow MzManualRecord ( LinksDataSet.tblSubjectRow dr1, LinksDataSet.tblSubjectRow dr2, LinksDataSet dsLinks ) {
			string select = string.Format("{0}={1} AND {2}={3}",
				dr1.SubjectTag, dsLinks.tblMzManual.Subject1TagColumn.ColumnName,
				dr2.SubjectTag, dsLinks.tblMzManual.Subject2TagColumn.ColumnName);
			LinksDataSet.tblMzManualRow[] drs = (LinksDataSet.tblMzManualRow[])dsLinks.tblMzManual.Select(select);
			switch ( drs.Length ) {
				case 0:
					DateTime? mob1 = Mob.Retrieve(dr1.SubjectTag, dsLinks.tblSubjectDetails);
					DateTime? mob2 = Mob.Retrieve(dr2.SubjectTag, dsLinks.tblSubjectDetails);
					if ( mob1.HasValue && mob2.HasValue ) {
						if ( (dr1.Generation == (byte)Generation.Gen2) || (dr1.Gender == dr2.Gender) ) {
							Int32 daysDifferenceAbsolute = (Int32)Math.Abs(mob2.Value.Subtract(mob1.Value).TotalDays);
							Trace.Assert(daysDifferenceAbsolute > Constants.MaxDaysBetweenTwinBirths, "If siblings have close birthdays, there should be a record in tblMzManual.");
						}
					}
					else {
						Trace.Assert(OverridesGen2.MissingMobInvalidSkip.Contains(dr1.SubjectID) || OverridesGen2.MissingMobInvalidSkip.Contains(dr2.SubjectID), "Subjects with missing MOBs should be recognized.");
					}
					return null;
				case 1:
					return drs[0];
				default:
					Trace.Fail("At most, one record should be retrieved.");
					throw new InvalidOperationException();
			}
		}

		//internal static LinksDataSet.tblMzManualRow MzGen1Hack ( LinksDataSet.tblSubjectRow dr1, LinksDataSet.tblSubjectRow dr2, LinksDataSet dsLinks, ImportDataSet dsImport ) {
		//   LinksDataSet.tblMzManualRow dr = dsLinks.tblMzManual.NewtblMzManualRow();
		//   dr.Subject1Tag = dr1.SubjectTag;
		//   dr.Subject2Tag = dr2.SubjectTag;
		//   dr.Generation = dr1.Generation;

		//   DateTime? mob1 = Mob.Retrieve(dr1.SubjectTag, dsLinks.tblSubjectDetails);
		//   DateTime? mob2 = Mob.Retrieve(dr2.SubjectTag, dsLinks.tblSubjectDetails);
		//   //if ( mob1.HasValue && mob2.HasValue ) {
		//   Int32 daysDifferenceAbsolute = (Int32)Math.Abs(mob2.Value.Subtract(mob1.Value).TotalDays);
		//   if ( daysDifferenceAbsolute > Constants.MaxDaysBetweenTwinBirths ) {
		//      dr.MultipleBirth = (byte)MultipleBirth.No;
		//      dr.IsMz = (byte)Tristate.No;
		//      dr.Undecided = false;
		//   }
		//   else if ( dr1.Gender != dr2.Gender ) {
		//      dr.MultipleBirth = (byte)MultipleBirth.TwinOrTrip;
		//      dr.IsMz = (byte)Tristate.No;
		//      dr.Undecided = false;
		//   }
		//   else {
		//      //They're double entered, so you don't need to check both combinations of (Subject1,Subject2) and (Subject2, Subject1)
		//      ImportDataSet.tblGen1MzDzDistinction2010Row drImport = dsImport.tblGen1MzDzDistinction2010.FindBySubject1IDSubject2ID(dr1.SubjectID, dr2.SubjectID);
		//      if ( drImport != null ) {
		//         Trace.Assert(drImport != null, "The retrieved row shouldn't be null.");
		//         MultipleBirthImportGen1MzDistinction importMultipleBirth = (MultipleBirthImportGen1MzDistinction)(drImport.MultipleBirth);
		//         switch ( importMultipleBirth ) {
		//            case MultipleBirthImportGen1MzDistinction.Twin: dr.MultipleBirth = (byte)MultipleBirth.Twin; break;
		//            case MultipleBirthImportGen1MzDistinction.Trip: dr.MultipleBirth = (byte)MultipleBirth.Trip; break;
		//            default: throw new InvalidOperationException("Only Twins and Trips should have gotten to this part of the routine.");
		//         }

		//         IsMzImportGen1MzDistinction importIsMz = (IsMzImportGen1MzDistinction)(drImport.IsMz);
		//         switch ( importIsMz ) {
		//            case IsMzImportGen1MzDistinction.Yes: dr.IsMz = (byte)Tristate.Yes; break;
		//            case IsMzImportGen1MzDistinction.No: dr.IsMz = (byte)Tristate.No; break;
		//            default: throw new InvalidOperationException("Only definite Yes/No MZs should have gotten to this part of the routine.");
		//         }
		//         dr.Undecided = false;
		//      }
		//      else {
		//         dr.MultipleBirth = (byte)MultipleBirth.TwinOrTrip;
		//         dr.IsMz = (byte)Tristate.DoNotKnow;
		//         dr.Undecided = true;
		//      }
		//   }
		//   return dr;		
		//}
		internal static byte? MotherLoopIndexForChildTag ( Int32 motherTag, LinksDataSet.tblSubjectRow drChild, LinksDataSet.tblResponseDataTable dtResponse ) {
			byte childTwoDigitID = CommonFunctions.LastTwoDigitsOfGen2SubjectID(drChild);
			const Item item = Item.Gen1ChildsIDByBirthOrder;
			string select = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
				motherTag, dtResponse.SubjectTagColumn.ColumnName,
				(byte)item, dtResponse.ItemColumn.ColumnName,
				childTwoDigitID, dtResponse.ValueColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drs = (LinksDataSet.tblResponseRow[])dtResponse.Select(select);
			Trace.Assert(drs.Length <= 1, "At most one row should be returned.");
			if ( drs.Length == 0 )
				return null;
			else
				return (byte)drs[0].Value;
		}
		#endregion
	}
}
#region OldResponses
//internal static Int32 Response ( Item itemID, Int32 subjectTag, LinksDataSet ds ) {
//   if ( ds == null ) throw new ArgumentNullException("ds");
//   string select = string.Format("{0}={1} AND {2}={3}",
//      subjectTag, ds.tblResponse.SubjectTagColumn.ColumnName,
//      (byte)itemID, ds.tblResponse.ItemColumn.ColumnName);
//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])ds.tblResponse.Select(select);
//   Trace.Assert(drsRaw.Length == 1, "Exactly one row should be returned.");
//   return drsRaw[0].Value;
//}
//internal static Int32 Response ( Int16 surveyYear, Item itemID, SurveySource surveySource, Int32 subjectTag, Int32 maxRows, LinksDataSet ds ) {
//   if ( ds == null ) throw new ArgumentNullException("ds");
//   string select = string.Format("{0}={1} AND {2}={3} AND {4}={5} AND {6}={7}",
//      subjectTag, ds.tblResponse.SubjectTagColumn.ColumnName,
//      (byte)itemID, ds.tblResponse.ItemColumn.ColumnName,
//      surveyYear, ds.tblResponse.SurveyYearColumn.ColumnName,
//      (byte)surveySource, ds.tblResponse.SurveySourceColumn.ColumnName);
//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])ds.tblResponse.Select(select);
//   Trace.Assert(drsRaw.Length <= maxRows, "At most, " + maxRows + " row(s) should be returned.");
//   return drsRaw[0].Value;
//}
//internal static Int32 Response ( Int16 surveyYear, Item itemID, Int32 subjectTag, Int32 maxRows, LinksDataSet ds ) {
//   if ( ds == null ) throw new ArgumentNullException("ds");
//   string select = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
//      subjectTag, ds.tblResponse.SubjectTagColumn.ColumnName,
//      (byte)itemID, ds.tblResponse.ItemColumn.ColumnName,
//      surveyYear, ds.tblResponse.SurveyYearColumn.ColumnName);
//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])ds.tblResponse.Select(select);
//   Trace.Assert(drsRaw.Length <= maxRows, "At most, " + maxRows + " row(s) should be returned.");
//   return drsRaw[0].Value;
//}
//internal static Int32? ResponseNullPossible ( Item itemID, Int32 subjectTag, LinksDataSet ds ) {
//   if ( ds == null ) throw new ArgumentNullException("ds");
//   string select = string.Format("{0}={1} AND {2}={3}",
//      subjectTag, ds.tblResponse.SubjectTagColumn.ColumnName,
//      (byte)itemID, ds.tblResponse.ItemColumn.ColumnName);
//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])ds.tblResponse.Select(select);
//   Trace.Assert(drsRaw.Length <= 1, "At most, one row should be returned.");
//   if ( drsRaw.Length == 0 )
//      return null;
//   else
//      return drsRaw[0].Value;
//}
//internal static Int32? ResponseNullPossible ( Int16 surveyYear, Item itemID, Int32 subjectTag, Int32 maxRows, LinksDataSet ds ) {
//   if ( ds == null ) throw new ArgumentNullException("ds");
//   string select = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
//      subjectTag, ds.tblResponse.SubjectTagColumn.ColumnName,
//      (byte)itemID, ds.tblResponse.ItemColumn.ColumnName,
//      surveyYear, ds.tblResponse.SurveyYearColumn.ColumnName);
//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])ds.tblResponse.Select(select);
//   Trace.Assert(drsRaw.Length <= maxRows, "At most, " + maxRows + " row(s) should be returned.");
//   if ( drsRaw.Length == 0 )
//      return null;
//   else
//      return drsRaw[0].Value;
//}
//internal static Int32? ResponseNullPossible ( Int16 surveyYear, Item itemID, SurveySource surveySource, Int32 subjectTag, Int32 maxRows, LinksDataSet ds ) {
//   if ( ds == null ) throw new ArgumentNullException("ds");
//   string select = string.Format("{0}={1} AND {2}={3} AND {4}={5} AND {6}={7}",
//      subjectTag, ds.tblResponse.SubjectTagColumn.ColumnName,
//      (byte)itemID, ds.tblResponse.ItemColumn.ColumnName,
//      surveyYear, ds.tblResponse.SurveyYearColumn.ColumnName,
//      (byte)surveySource, ds.tblResponse.SurveySourceColumn.ColumnName);
//   LinksDataSet.tblResponseRow[] drsRaw = (LinksDataSet.tblResponseRow[])ds.tblResponse.Select(select);
//   Trace.Assert(drsRaw.Length <= maxRows, "At most, " + maxRows + " row(s) should be returned.");
//   if ( drsRaw.Length == 0 )
//      return null;
//   else
//      return drsRaw[0].Value;
//}
#endregion