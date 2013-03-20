using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Nls.BaseAssembly.Trend;

namespace Nls.BaseAssembly {
	public sealed class ParentsOfGen2Retro {
		#region Fields
		private readonly LinksDataSet _ds;
		private readonly Item[] _items = { Item.DateOfBirthMonth, Item.DateOfBirthYearGen1, Item.Gen1LivedWithFatherAtAgeX, Item.Gen1LivedWithMotherAtAgeX, Item.Gen1AlwaysLivedWithBothParents };
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
			Int16 surveyYear = ItemYears.Gen1BioparentInHH;
			const byte loopIndexForNever =  255 ;
			byte[] loopIndicesAndAges = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 };

			Int32 subjectTag = drSubject.SubjectTag;
			Int16 yob = Convert.ToInt16(Mob.Retrieve(drSubject, dtExtendedResponse).Value.Year);
			Int32 recordsAdded = 0;

			YesNo bothParentsAlways = DetermineBothParentsAlwaysInHH(surveyYear, subjectTag, yob, dtExtendedResponse);
			YesNo responseDadEver = DetermineOneParentEverInHH(Item.Gen1LivedWithFatherAtAgeX, surveyYear, subjectTag, loopIndexForNever, dtExtendedResponse);
			YesNo responseMomEver = DetermineOneParentEverInHH(Item.Gen1LivedWithMotherAtAgeX, surveyYear, subjectTag, loopIndexForNever, dtExtendedResponse);



			foreach ( byte loopIndexAndAge in loopIndicesAndAges ) {
				YesNo biodadInHH;
				YesNo biomomInHH;
				if ( bothParentsAlways == YesNo.Yes ) {
					biodadInHH = YesNo.Yes;
					biomomInHH = YesNo.Yes;
				}
				else if ( responseDadEver == YesNo.No & responseMomEver == YesNo.No ) {
					biodadInHH = YesNo.No;
					biomomInHH = YesNo.No;
				}
				else if ( responseDadEver == YesNo.Yes & responseMomEver == YesNo.Yes ) {
					biodadInHH = DetermineParentInHH(Item.Gen1LivedWithFatherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);
					biomomInHH = DetermineParentInHH(Item.Gen1LivedWithMotherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);
				}
				else if ( responseDadEver == YesNo.No & responseMomEver == YesNo.Yes ) {
					biodadInHH = YesNo.No;
					biomomInHH = DetermineParentInHH(Item.Gen1LivedWithMotherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);
				}
				else if ( responseDadEver == YesNo.Yes & responseMomEver == YesNo.Yes ) {
					biodadInHH = DetermineParentInHH(Item.Gen1LivedWithFatherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);
					biomomInHH = YesNo.No;
				}
				else {
					biodadInHH = YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
					biomomInHH = YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
					Trace.WriteLine(string.Format("SubjectTag {0} didn't fall cleanly into the Gen1LivedWithFatherAtAgeX loop for index {1} with dad and mom values of {2} and {3}.", subjectTag, loopIndexAndAge, responseDadEver, responseMomEver));
				}
				
				//Trace.Assert(bothParentsAlways != YesNo.Yes, "If the subject said they always lived with both parents, then they shouldn't have answered the items for specific years.");
				Int16 yearInHH = Convert.ToInt16(yob + loopIndexAndAge);
				AddRow(subjectTag, surveyYear, biodadInHH, biomomInHH, loopIndexAndAge, yearInHH);
				recordsAdded += 1;
			}
			return recordsAdded;
		}
		private static YesNo DetermineBothParentsAlwaysInHH ( Int16 surveyYear, Int32 subjectTag, Int16 yob, LinksDataSet.tblResponseDataTable dtExtended ) {
			Item item = Item.Gen1AlwaysLivedWithBothParents;
			Int32? responseBothAlways = Retrieve.ResponseNullPossible(surveyYear, item, subjectTag, dtExtended);
			if ( !responseBothAlways.HasValue )
				return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
			else
				return (YesNo)responseBothAlways;
		}
		private static YesNo DetermineOneParentEverInHH ( Item item, Int16 surveyYear, Int32 subjectTag, byte loopIndex, LinksDataSet.tblResponseDataTable dtExtended ) {
			Int32? response = Retrieve.ResponseNullPossible(surveyYear, item, subjectTag, loopIndex, dtExtended);
			if ( !response.HasValue )
				return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
			else
				return CommonFunctions.ReverseYesNo((YesNo)response);
		}
		private static YesNo DetermineParentInHH ( Item item, Int16 surveyYear, Int32 subjectTag, byte loopIndex, LinksDataSet.tblResponseDataTable dtExtended ) {
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
		public static TrendLineGen0InHH RetrieveTrend ( Bioparent bioparent, Int32 subjectTag, LinksDataSet.tblParentsOfGen1RetroDataTable dtRetro ) { //, LinksDataSet.tblSubjectDetailsDataTable dtDetail ) {
			if ( dtRetro == null )
				return new TrendLineGen0InHH(yob: 0, hasAnyRecords: false, everAtHome: false, years: null, values: null, ages: null);
			else if ( dtRetro.Count <= 0 )
				throw new ArgumentException("There should be at least one row in tblParentsOfGen1Retro.");

			string selectNever = string.Format("{0}={1} AND {2}={3}",
				subjectTag, dtRetro.SubjectTagColumn.ColumnName,
				byte.MaxValue, dtRetro.AgeColumn.ColumnName);
			LinksDataSet.tblParentsOfGen1RetroRow[] drNever = (LinksDataSet.tblParentsOfGen1RetroRow[])dtRetro.Select(selectNever);
			Trace.Assert(drNever.Length == 1, "Exactly one record should be retrieved from tblParentsOfGen1Retro for 'Never Lived in HH'.");
			Int32 yob = drNever[0].Year;

			string selectYears = string.Format("{0}!={1} AND {2}={3}",
				subjectTag, dtRetro.SubjectTagColumn.ColumnName,
				byte.MaxValue, dtRetro.AgeColumn.ColumnName);
			LinksDataSet.tblParentsOfGen1RetroRow[] drsYes = (LinksDataSet.tblParentsOfGen1RetroRow[])dtRetro.Select(selectNever);
			Trace.Assert(drsYes.Length >= 0, "At least zero records should be retrieved from tblParentsOfGen1Retro.");

			YesNo everInHH = YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
			Int16[] years = new Int16[drsYes.Length];
			YesNo[] values = new YesNo[drsYes.Length];
			byte[] ages = new byte[drsYes.Length];

			switch ( bioparent ) {
				case Bioparent.Dad:
					everInHH = (YesNo)drNever[0].BiodadInHH;
					//values = (from dr in drsYes select (YesNo)dr.BiodadInHH).ToArray();
					for ( Int32 i = 0; i < drsYes.Length; i++ ) {
						values[i] = (YesNo)drsYes[i].BiodadInHH;
					}
					break;
				case Bioparent.Mom:
					everInHH = (YesNo)drNever[0].BiomomInHH;
					for ( Int32 i = 0; i < drsYes.Length; i++ ) {
						values[i] = (YesNo)drsYes[i].BiomomInHH;
					}
					break;
				default:
					throw new ArgumentOutOfRangeException("bioparent");
			}


			switch ( everInHH ) {
				case YesNo.No:
					Trace.Assert(drsYes.Length == 0, "If the subject says the bioparent has never lived in the HH, then there shouldn't be any more records.");
					break;
				case YesNo.Yes:
					//This is ok.  Execute the statements following the switch statement.
					break;
				default:
					throw new ArgumentOutOfRangeException("bioparent");
			}

			for ( Int32 i = 0; i < drsYes.Length; i++ ) {
				years[i] = drsYes[i].Year;
				ages[i] = drsYes[i].Age;
			}

			return new TrendLineGen0InHH(yob: yob, hasAnyRecords: true, everAtHome: (everInHH == YesNo.Yes), years: years, values: values, ages: ages);
			//string select = string.Format("{0}={1}", subjectTag, dsLinks.tblParentsOfGen1Retro.SubjectTagColumn.ColumnName);
			//LinksDataSet.tblParentsOfGen1RetroRow[] drs = (LinksDataSet.tblParentsOfGen1RetroRow[])dsLinks.tblParentsOfGen1Retro.Select(select);
			////Trace.Assert(drs.Length >= 1, "There should be at least one row.");
			//LinksDataSet.tblParentsOfGen1RetroDataTable dt = new LinksDataSet.tblParentsOfGen1RetroDataTable();
			//foreach ( LinksDataSet.tblParentsOfGen1RetroRow dr in drs ) {
			//   dt.ImportRow(dr);
			//}
			//return dt;
		}
		public static LinksDataSet.tblParentsOfGen1RetroDataTable RetrieveRows ( Int32 subject1Tag, Int32 subject2Tag, LinksDataSet dsLinks ) {
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( dsLinks.tblParentsOfGen1Retro.Count <= 0 ) throw new ArgumentException("There should be at least one row in tblParentsOfGen1Retro.");

			string select = string.Format("{0}={1} OR {2}={3}",
				subject1Tag, dsLinks.tblParentsOfGen1Retro.SubjectTagColumn.ColumnName,
				subject2Tag, dsLinks.tblParentsOfGen1Retro.SubjectTagColumn.ColumnName);
			LinksDataSet.tblParentsOfGen1RetroRow[] drs = (LinksDataSet.tblParentsOfGen1RetroRow[])dsLinks.tblParentsOfGen1Retro.Select(select);
			//Trace.Assert(drs.Length >= 1, "There should be at least one row.");

			LinksDataSet.tblParentsOfGen1RetroDataTable dt = new LinksDataSet.tblParentsOfGen1RetroDataTable();
			foreach ( LinksDataSet.tblParentsOfGen1RetroRow dr in drs ) {
				dt.ImportRow(dr);
			}
			return dt;
		}
		//public static LinksDataSet.tblParentsOfGen1RetroDataTable RetrieveRows ( Int32 subjectTag, LinksDataSet dsLinks ) {
		//   if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
		//   if ( dsLinks.tblParentsOfGen1Retro.Count <= 0 ) throw new ArgumentException("There should be at least one row in tblParentsOfGen1Retro.");

		//   string select = string.Format("{0}={1}", subjectTag, dsLinks.tblParentsOfGen1Retro.SubjectTagColumn.ColumnName);
		//   LinksDataSet.tblParentsOfGen1RetroRow[] drs = (LinksDataSet.tblParentsOfGen1RetroRow[])dsLinks.tblParentsOfGen1Retro.Select(select);
		//   //Trace.Assert(drs.Length >= 1, "There should be at least one row.");
		//   LinksDataSet.tblParentsOfGen1RetroDataTable dt = new LinksDataSet.tblParentsOfGen1RetroDataTable();
		//   foreach ( LinksDataSet.tblParentsOfGen1RetroRow dr in drs ) {
		//      dt.ImportRow(dr);
		//   }
		//   return dt;
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