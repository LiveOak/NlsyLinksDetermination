using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Nls.BaseAssembly {
	public sealed class ParentsOfGen2Retro {
		#region Fields
		private readonly LinksDataSet _ds;
		private readonly Item[] _items = { Item.DateOfBirthMonth, Item.DateOfBirthYearGen1, Item.Gen1LivedWithFatherAtAgeX, Item.Gen1LivedWithMotherAtAgeX };
		private readonly string _itemIDsString = "";
		#endregion
		#region Constructor
		public ParentsOfGen2Retro ( LinksDataSet ds ) {
		   if ( ds == null ) throw new ArgumentNullException("ds");
		   if ( ds.tblResponse.Count <= 0 ) throw new InvalidOperationException("tblResponse must NOT be empty.");
			if ( ds.tblParentsOfGen1Retro.Count != 0 ) throw new InvalidOperationException("tblParentsOfGen1Retro must be empty before creating rows for it.");
		   _ds = ds;

		   _itemIDsString = CommonCalculations.ConvertItemsToString(_items);
		}
		#endregion
		#region Public Methods
		public string Go ( ) {
			const Int32 minRowCount = 0;//There are some extended families with no children.
			Stopwatch sw = new Stopwatch();
			sw.Start();
			Retrieve.VerifyResponsesExistForItem(_items, _ds);
			Int32 recordsAddedTotal = 0;
			_ds.tblParentsOfGen1Retro.BeginLoadData();

			Int16[] extendedIDs = CommonFunctions.CreateExtendedFamilyIDs(_ds);
			//Parallel.ForEach(extendedIDs, ( extendedID ) => {//
			foreach ( Int32 extendedID in extendedIDs ) {
				LinksDataSet.tblResponseDataTable dtExtendedResponse = Retrieve.ExtendedFamilyRelevantResponseRows(extendedID, _itemIDsString, minRowCount, _ds.tblResponse);
				LinksDataSet.tblSubjectRow[] subjectsInExtendedFamily = Retrieve.SubjectsInExtendFamily(extendedID, _ds.tblSubject);
				foreach ( LinksDataSet.tblSubjectRow drSubject in subjectsInExtendedFamily ) {
					if ( (Generation)drSubject.Generation == Generation.Gen1 ) {
						Int32 recordsAddedForLoop = ProcessSubjectGen1(drSubject, dtExtendedResponse);
						Interlocked.Add(ref recordsAddedTotal, recordsAddedForLoop);
					}
				}
			}
			_ds.tblParentsOfGen1Retro.EndLoadData();
			sw.Stop();
			return string.Format("{0:N0} tblParentsOfGen1Retro records were created.\nElapsed time: {1}", recordsAddedTotal, sw.Elapsed.ToString());
		}
		#endregion
		#region Private Methods
		private Int32 ProcessSubjectGen1 ( LinksDataSet.tblSubjectRow drSubject, LinksDataSet.tblResponseDataTable dtExtendedResponse ) {
			byte[] loopIndicesAndAges = { 255, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 };
			//Int16[] ages = { -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 };
			Int32 subjectTag = drSubject.SubjectTag;
			Int32 yob = Mob.Retrieve(drSubject, dtExtendedResponse).Value.Year;

			Int32 recordsAdded = 0;
			foreach ( Int16 surveyYear in ItemYears.Gen1BiomomInHH ) {
				foreach ( byte loopIndexAndAge in loopIndicesAndAges ) {
					YesNo biodadInHH = DetermineBiodadInHH(Item.Gen1LivedWithFatherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);
					YesNo biomomInHH = DetermineBiodadInHH(Item.Gen1LivedWithMotherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);

					if ( biodadInHH != YesNo.ValidSkipOrNoInterviewOrNotInSurvey && biomomInHH != YesNo.ValidSkipOrNoInterviewOrNotInSurvey ) {
						Int16 yearInHH = Convert.ToInt16(yob + loopIndexAndAge);
						if ( loopIndexAndAge == byte.MaxValue ) yearInHH = 0;


						AddRow(subjectTag, surveyYear, biodadInHH, biomomInHH, loopIndexAndAge, yearInHH);
						recordsAdded += 1;
					}
				}
			}
			return recordsAdded;
		}
		private static YesNo DetermineBiodadInHH ( Item item, Int16 surveyYear, Int32 subjectTag, byte loopIndex, LinksDataSet.tblResponseDataTable dtExtended ) {
			Int32? response = Retrieve.ResponseNullPossible(surveyYear, item, subjectTag, loopIndex, dtExtended);
			if ( !response.HasValue )
				return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;

			EnumResponsesGen1.BioparentOfGen1InHH codedResponse = (EnumResponsesGen1.BioparentOfGen1InHH)response.Value;
			switch ( codedResponse ) {
				case EnumResponsesGen1.BioparentOfGen1InHH.NonInterview:
				case EnumResponsesGen1.BioparentOfGen1InHH.ValidSkip:
				case EnumResponsesGen1.BioparentOfGen1InHH.InvalidSkip:
				case EnumResponsesGen1.BioparentOfGen1InHH.DoNotKnow:
				case EnumResponsesGen1.BioparentOfGen1InHH.Refusal:
					return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
				case EnumResponsesGen1.BioparentOfGen1InHH.No:
					return YesNo.No;
				case EnumResponsesGen1.BioparentOfGen1InHH.Yes:
					return YesNo.Yes;
				default: throw new InvalidOperationException("The response " + codedResponse + " was not recognized.");
			}
		}
		private void AddRow ( Int32 subjectTag, Int16 surveyYear, YesNo biodadInHH, YesNo biomomInHH, byte age, Int16 yearInHH ) {
			//lock ( _ds.tblFatherOfGen2 ) {
			LinksDataSet.tblParentsOfGen1RetroRow drNew = _ds.tblParentsOfGen1Retro.NewtblParentsOfGen1RetroRow();
			drNew.SubjectTag = subjectTag;
			drNew.SurveyYear = surveyYear;
			drNew.BiodadInHH = (Int16)biodadInHH;
			drNew.BiomomInHH = (Int16)biomomInHH;
			drNew.Age = age;
			drNew.Year = yearInHH;
			_ds.tblParentsOfGen1Retro.AddtblParentsOfGen1RetroRow(drNew);
			//}
		}
		#endregion
		#region Public/Private Static
		//public static LinksDataSet.tblFatherOfGen2DataTable RetrieveRows ( Int32 subjectTag, LinksDataSet dsLinks ) {
		//   if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
		//   if ( dsLinks.tblFatherOfGen2.Count <= 0 ) throw new ArgumentException("There should be at least one row in tblFatherOfGen2.");

		//   string select = string.Format("{0}={1}", subjectTag, dsLinks.tblFatherOfGen2.SubjectTagColumn.ColumnName);
		//   LinksDataSet.tblFatherOfGen2Row[] drs = (LinksDataSet.tblFatherOfGen2Row[])dsLinks.tblFatherOfGen2.Select(select);
		//   //Trace.Assert(drs.Length >= 1, "There should be at least one row.");
		//   LinksDataSet.tblFatherOfGen2DataTable dt = new LinksDataSet.tblFatherOfGen2DataTable();
		//   foreach ( LinksDataSet.tblFatherOfGen2Row dr in drs ) {
		//      dt.ImportRow(dr);
		//   }
		//   return dt;
		//}
		//private static LinksDataSet.tblFatherOfGen2Row RetrieveRow ( Int32 subjectTag, Int16 surveyYear, LinksDataSet.tblFatherOfGen2DataTable dtInput ) {
		//   string select = string.Format("{0}={1} AND {2}={3}",
		//      subjectTag, dtInput.SubjectTagColumn.ColumnName,
		//      surveyYear, dtInput.SurveyYearColumn.ColumnName);
		//   LinksDataSet.tblFatherOfGen2Row[] drs = (LinksDataSet.tblFatherOfGen2Row[])dtInput.Select(select);
		//   //if ( drs == null ) {
		//   if ( drs.Length <=0 ) {
		//      return null;
		//   }
		//   else {
		//      Trace.Assert(drs.Length <= 1, "There should be no more than one row.");
		//      return drs[0];
		//   }
		//}
		//public static Int16?[] RetrieveInHH ( Int32 subjectTag, Int16[] surveyYears, LinksDataSet.tblFatherOfGen2DataTable dtInput ) {
		//   if ( dtInput == null ) throw new ArgumentNullException("dtInput");
		//   if ( surveyYears == null ) throw new ArgumentNullException("surveyYears");
		//   if ( dtInput.Count <= 0 ) throw new ArgumentException("There should be at least one row in tblFatherOfGen2.");

		//   Int16?[] values = new Int16?[surveyYears.Length];
		//   for ( Int32 i = 0; i < values.Length; i++ ) {
		//      LinksDataSet.tblFatherOfGen2Row dr = RetrieveRow(subjectTag, surveyYears[i], dtInput);
		//      if ( dr == null )
		//         values[i] = null;
		//      else if ( (YesNo)dr.BiodadInHH == YesNo.ValidSkipOrNoInterviewOrNotInSurvey )
		//         values[i] = null;
		//      else if ( (YesNo)dr.BiodadInHH == YesNo.InvalidSkip )
		//         values[i] = null;
		//      else
		//         values[i] = dr.BiodadInHH;
		//   }
		//   return values;
		//}
		#endregion
	}
}