﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

using Nls.BaseAssembly.EnumResponsesGen1;

namespace Nls.BaseAssembly {
	public sealed class ParentsOfGen1Current {
		#region Fields
		private readonly LinksDataSet _ds;
		private readonly Item[] _items = { Item.Gen1FatherAlive, Item.Gen1FatherDeathCause, Item.Gen1FatherDeathAge, Item.Gen1FatherBirthCountry, Item.Gen1FatherHighestGrade, Item.Gen1GrandfatherBirthCountry,
													Item.Gen1MotherAlive, Item.Gen1MotherDeathCause, Item.Gen1MotherDeathAge, Item.Gen1MotherBirthCountry, Item.Gen1MotherHighestGrade,
													Item.Gen1FatherBirthYear, Item.Gen1FatherAge, //Item.Gen1FatherBirthMonth, 
													Item.Gen1MotherBirthYear, Item.Gen1MotherAge	 //Item.Gen1MotherBirthMonth, 
													};
		private readonly string _itemIDsString = "";
		#endregion
		#region Constructor
		public ParentsOfGen1Current ( LinksDataSet ds ) {
			if ( ds == null ) throw new ArgumentNullException("ds");
			if ( ds.tblResponse.Count <= 0 ) throw new InvalidOperationException("tblResponse must NOT be empty.");
			if ( ds.tblSurveyTime.Count <= 0 ) throw new InvalidOperationException("tblSurveyTime must NOT be empty.");
			if ( ds.tblParentsOfGen1Current.Count != 0 ) throw new InvalidOperationException("tblParentsOfGen1Current must be empty before creating rows for it.");
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
			return string.Format("{0:N0} tblParentsOfGen1Current records were created.\nElapsed time: {1}", recordsAddedTotal, sw.Elapsed.ToString());
		}
		#endregion
		#region Private Methods
		private Int32 ProcessSubjectGen1 ( LinksDataSet.tblSubjectRow drSubject, LinksDataSet.tblResponseDataTable dtExtendedResponse ) {
			Int32 subjectTag = drSubject.SubjectTag;

			//For Biodad
			Int16? biodadBirthYearReported = DetermineBioparentBirthYearReported(Item.Gen1FatherBirthYear, subjectTag, dtExtendedResponse);
			Int16? biodadBirthYearEstimated = biodadBirthYearReported; //If subjects don't answer the DOB item, they're asked their age.
			if ( !biodadBirthYearEstimated.HasValue ) biodadBirthYearEstimated = DetermineBioparentBirthYearEstimated(Item.Gen1FatherAge, subjectTag, dtExtendedResponse, _ds);

			Int16? biodadYearLastAsked = null;
			YesNo biodadAlive = YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
			Gen1BioparentDeathCause biodadDeathCause = Gen1BioparentDeathCause.ValidSkipOrNoInterviewOrNotInSurvey;
			byte? biodadDeathAge = null;
			byte? lastHealthModuleBiodadIndex = DetermineLastHealthModuleIndex(Item.Gen1FatherAlive, subjectTag, dtExtendedResponse);
			if ( lastHealthModuleBiodadIndex.HasValue ) {
				biodadYearLastAsked = null;
				biodadAlive = DetermineBioparentAlive(Item.Gen1FatherAlive, lastHealthModuleBiodadIndex.Value, subjectTag, dtExtendedResponse);
				biodadDeathCause = DetermineBioparentDeathCause(Item.Gen1FatherDeathCause, lastHealthModuleBiodadIndex.Value, subjectTag, dtExtendedResponse);
				biodadDeathAge = DetermineBioparentDeathAge(Item.Gen1FatherDeathAge, lastHealthModuleBiodadIndex.Value, subjectTag, dtExtendedResponse);
			}

			YesNo biodadUSBorn = DetermineUSBorn(Item.Gen1FatherBirthCountry, subjectTag, dtExtendedResponse);
			byte? biodadHighestGrade = DetermineHighestGrade(Item.Gen1FatherHighestGrade, subjectTag, dtExtendedResponse);
			YesNo biograndfatherUSBorn = DetermineUSBorn(Item.Gen1GrandfatherBirthCountry, subjectTag, dtExtendedResponse);

			//For Biomom
			Int16? biomomBirthYearReported = DetermineBioparentBirthYearReported(Item.Gen1MotherBirthYear, subjectTag, dtExtendedResponse);
			Int16? biomomBirthYearEstimated = biomomBirthYearReported; //If subjects don't answer the DOB item, they're asked their age.
			if ( !biomomBirthYearEstimated.HasValue ) biomomBirthYearEstimated = DetermineBioparentBirthYearEstimated(Item.Gen1MotherAge, subjectTag, dtExtendedResponse, _ds);

			Int16? biomomYearLastAsked = null;
			YesNo biomomAlive = YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
			Gen1BioparentDeathCause biomomDeathCause = Gen1BioparentDeathCause.ValidSkipOrNoInterviewOrNotInSurvey;
			byte? biomomDeathAge = null;
			byte? lastHealthModuleBiomomIndex = DetermineLastHealthModuleIndex(Item.Gen1MotherAlive, subjectTag, dtExtendedResponse);
			if ( lastHealthModuleBiomomIndex.HasValue ) {
				biomomYearLastAsked = null;
				biomomAlive = DetermineBioparentAlive(Item.Gen1MotherAlive, lastHealthModuleBiomomIndex.Value, subjectTag, dtExtendedResponse);
				biomomDeathCause = DetermineBioparentDeathCause(Item.Gen1MotherDeathCause, lastHealthModuleBiomomIndex.Value, subjectTag, dtExtendedResponse);
				biomomDeathAge = DetermineBioparentDeathAge(Item.Gen1MotherDeathAge, lastHealthModuleBiomomIndex.Value, subjectTag, dtExtendedResponse);
			}

			YesNo biomomUSBorn = DetermineUSBorn(Item.Gen1MotherBirthCountry, subjectTag, dtExtendedResponse);
			byte? biomomHighestGrade = DetermineHighestGrade(Item.Gen1MotherHighestGrade, subjectTag, dtExtendedResponse);

			//Add row to in-memory database.
			AddRow(subjectTag,
				biodadBirthYearReported, biodadBirthYearEstimated, biodadYearLastAsked, biodadAlive, biodadDeathCause, biodadDeathAge, biodadUSBorn, biodadHighestGrade, biograndfatherUSBorn,
				biomomBirthYearReported, biomomBirthYearEstimated, biomomYearLastAsked, biomomAlive, biomomDeathCause, biomomDeathAge, biomomUSBorn, biomomHighestGrade);

			const Int32 recordsAdded = 1;
			return recordsAdded;
		}

		private static Gen1BioparentDeathCause DetermineBioparentDeathCause ( Item item, byte loopIndex, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
			const Int16 surveyYear = ItemYears.Gen1BioparentDeathCause;

			Int32? response = Retrieve.ResponseNullPossible(surveyYear: surveyYear, itemID: item, subjectTag: subjectTag, loopIndex: loopIndex, dt: dtExtended);

			if ( !response.HasValue || response.Value < 0 )
				return Gen1BioparentDeathCause.ValidSkipOrNoInterviewOrNotInSurvey;
			else
				return (EnumResponsesGen1.Gen1BioparentDeathCause)response.Value;
		}
		private static Int16? DetermineBioparentBirthYearEstimated ( Item itemBirthYear, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended, LinksDataSet ds ) {
			Int16[] surveyYears = ItemYears.Gen1BioparentAge;
			Trace.Assert(surveyYears.Length == 2, "This function only works if the item exists in only two survey waves.");

			Int32? age2 = Retrieve.ResponseNullPossible(surveyYears[1], itemBirthYear, subjectTag, dtExtended);
			Int32? age1 = Retrieve.ResponseNullPossible(surveyYears[0], itemBirthYear, subjectTag, dtExtended);

			Int32? result = null;
			if ( age2.HasValue && age2.Value > 0 ) {
				DateTime? surveyDate2 = SurveyTime.RetrieveSubjectSurveyDate(subjectTag, surveyYears[1], ds);
				if ( surveyDate2.HasValue )
					result = surveyDate2.Value.Year - age2;
			}

			if ( result == null && age1.HasValue && age1.Value > 0 ) {
				DateTime? surveyDate1 = SurveyTime.RetrieveSubjectSurveyDate(subjectTag, surveyYears[0], ds);
				if ( surveyDate1.HasValue )
					result = surveyDate1.Value.Year - age1;
			}

			if ( result.HasValue ) {
				Trace.Assert(Constants.Gen1BioparentBirthYearEsimatedMin <= result.Value && result.Value <= Constants.Gen1BioparentBirthYearEsimatedMax, "The birth year of the Gen1Parent should be within the allowed bounds.");
				return Convert.ToInt16(result.Value);
			}
			else {
				return null;
			}
		}
		private static Int16? DetermineBioparentBirthYearReported ( Item itemBirthYear, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
			Int16[] surveyYears = ItemYears.Gen1BioparentBirthYear;
			Trace.Assert(surveyYears.Length == 2, "This function only works if the item exists in only two survey waves.");

			Int32? birthYear2 = Retrieve.ResponseNullPossible(surveyYears[1], itemBirthYear, subjectTag, dtExtended);
			Int32? birthYear1 = Retrieve.ResponseNullPossible(surveyYears[0], itemBirthYear, subjectTag, dtExtended);

			Int32? result = null;
			if ( birthYear2.HasValue && birthYear2.Value >= 0 )
				result = 1900 + birthYear2.Value;
			else if ( birthYear1.HasValue && birthYear1.Value >= 0 )
				result = 1900 + birthYear1.Value;


			if ( result.HasValue ) {
				Trace.Assert(Constants.Gen1BioparentBirthYearReportedMin <= result.Value && result.Value <= Constants.Gen1BioparentBirthYearReportedMax, "The birth year of the Gen1Parent should be within the allowed bounds.");
				return Convert.ToInt16(result.Value);
			}
			else {
				return null;
			}
		}
		private static byte? DetermineBioparentDeathAge ( Item item, byte loopIndex, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
			const Int16 surveyYear = ItemYears.Gen1BioparentDeathAge;
			Int32? response = Retrieve.ResponseNullPossible(surveyYear: surveyYear, itemID: item, subjectTag: subjectTag, loopIndex: loopIndex, dt: dtExtended);
			if ( !response.HasValue )
				return null;
			else if ( response.Value < 0 )
				return null;
			else
				return Convert.ToByte(response);
		}
		private static YesNo DetermineBioparentAlive ( Item item, byte loopIndex, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
			const Int16 surveyYear = ItemYears.Gen1BioparentAlive;
			Int32? response = Retrieve.Response(surveyYear: surveyYear, itemID: item, subjectTag: subjectTag, maxRows: 1, loopIndex: loopIndex, dt: dtExtended);

			EnumResponsesGen1.Gen1BioparentAlive codedResponse = (EnumResponsesGen1.Gen1BioparentAlive)response.Value;
			switch ( codedResponse ) {
				case EnumResponsesGen1.Gen1BioparentAlive.ValidSkip:
				case EnumResponsesGen1.Gen1BioparentAlive.DoNotKnow:
				case EnumResponsesGen1.Gen1BioparentAlive.Refusal:
					return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
				case EnumResponsesGen1.Gen1BioparentAlive.No:
					return YesNo.No;
				case EnumResponsesGen1.Gen1BioparentAlive.Yes:
					return YesNo.Yes;
				default: throw new InvalidOperationException("The response " + codedResponse + " was not recognized.");
			}
		}
		//The questions about their parent's death are asked in the Health-40, (as in 40 years old) and Health-50 module.
		private static byte? DetermineLastHealthModuleIndex ( Item item, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
			const Int16 surveyYear = ItemYears.Gen1BioparentAlive;

			string selectToGetLoopIndex = string.Format("{0}={1} AND {2}={3} AND {4}={5} AND {6}>=0",
				subjectTag, dtExtended.SubjectTagColumn.ColumnName,
				Convert.ToInt16(item), dtExtended.ItemColumn.ColumnName,
				surveyYear, dtExtended.SurveyYearColumn.ColumnName,
				dtExtended.ValueColumn.ColumnName);
			LinksDataSet.tblResponseRow[] drsForLoopIndex = (LinksDataSet.tblResponseRow[])dtExtended.Select(selectToGetLoopIndex);

			if ( drsForLoopIndex.Length <= 0 ) {
				return null;
			}
			else {
				byte maxLoopIndex = (from dr in drsForLoopIndex select dr.LoopIndex).Max();
				return maxLoopIndex;
			}
		}
		private static YesNo DetermineUSBorn ( Item item, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
			const Int16 surveyYear = ItemYears.Gen1BioparentUSBorn;

			Int32? response = Retrieve.ResponseNullPossible(surveyYear: surveyYear, itemID: item, subjectTag: subjectTag, dt: dtExtended);
			if ( !response.HasValue )
				return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
			EnumResponsesGen1.Gen1BioparentBirthCountry codedResponse = (EnumResponsesGen1.Gen1BioparentBirthCountry)response.Value;
			switch ( codedResponse ) {
				case EnumResponsesGen1.Gen1BioparentBirthCountry.InvalidSkip:
				case EnumResponsesGen1.Gen1BioparentBirthCountry.DoNotKnow:
				case EnumResponsesGen1.Gen1BioparentBirthCountry.Refusal:
					return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
				case EnumResponsesGen1.Gen1BioparentBirthCountry.NotUS:
					return YesNo.No;
				case EnumResponsesGen1.Gen1BioparentBirthCountry.US:
					return YesNo.Yes;
				case EnumResponsesGen1.Gen1BioparentBirthCountry.DidNotKnowParent:
					return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
				default: throw new InvalidOperationException("The response " + codedResponse + " was not recognized.");
			}
		}
		private static byte? DetermineHighestGrade ( Item item, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
			const Int16 surveyYear = ItemYears.Gen1BioparentHighestGrade;

			Int32? response = Retrieve.ResponseNullPossible(surveyYear: surveyYear, itemID: item, subjectTag: subjectTag, dt: dtExtended);
			if ( !response.HasValue )
				return null;
			else if ( response.Value < 0 )
				return null;
			else
				return Convert.ToByte(response.Value);
		}
		private void AddRow ( Int32 subjectTag,
			Int16? biodadBirthYearReported, Int16? biodadBirthYearEstimated, Int16? biodadYearLastAsked, YesNo biodadAlive, Gen1BioparentDeathCause biodadDeathCause, byte? biodadDeathAge, YesNo biodadUSBorn, byte? biodadHighestGrade, YesNo biograndfatherUSBorn,
			Int16? biomomBirthYearReported, Int16? biomomBirthYearEstimated, Int16? biomomYearLastAsked, YesNo biomomAlive, Gen1BioparentDeathCause biomomDeathCause, byte? biomomDeathAge, YesNo biomomUSBorn, byte? biomomHighestGrade ) {

			//lock ( _ds.tblFatherOfGen2 ) {
			LinksDataSet.tblParentsOfGen1CurrentRow drNew = _ds.tblParentsOfGen1Current.NewtblParentsOfGen1CurrentRow();
			drNew.SubjectTag = subjectTag;

			//Items about biodad (and one about biograndfather)
			if ( biodadBirthYearReported.HasValue ) drNew.BiodadBirthYearReported = biodadBirthYearReported.Value;
			else drNew.SetBiodadBirthYearReportedNull();

			if ( biodadBirthYearEstimated.HasValue ) drNew.BiodadBirthYearEstimated = biodadBirthYearEstimated.Value;
			else drNew.SetBiodadBirthYearEstimatedNull();

			if ( biodadYearLastAsked.HasValue ) drNew.BiodadYearLastAsked = Convert.ToInt16(biodadYearLastAsked);
			else drNew.SetBiodadYearLastAskedNull();

			drNew.BiodadAlive = Convert.ToInt16(biodadAlive);
			drNew.BiodadDeathCause = Convert.ToInt16(biodadDeathCause);

			if ( biodadDeathAge.HasValue ) drNew.BiodadDeathAge = biodadDeathAge.Value;
			else drNew.SetBiodadDeathAgeNull();

			drNew.BiodadUSBorn = Convert.ToInt16(biodadUSBorn);

			if ( biodadHighestGrade.HasValue ) drNew.BiodadHighestGrade = biodadHighestGrade.Value;
			else drNew.SetBiodadHighestGradeNull();

			drNew.BiograndfatherUSBorn = Convert.ToInt16(biograndfatherUSBorn);

			//Items about biomom
			if ( biomomBirthYearReported.HasValue ) drNew.BiomomBirthYearReported = biomomBirthYearReported.Value;
			else drNew.SetBiomomBirthYearReportedNull();

			if ( biomomBirthYearEstimated.HasValue ) drNew.BiomomBirthYearEstimated = biomomBirthYearEstimated.Value;
			else drNew.SetBiomomBirthYearEstimatedNull();

			if ( biomomYearLastAsked.HasValue ) drNew.BiomomYearLastAsked = Convert.ToInt16(biomomYearLastAsked);
			else drNew.SetBiomomYearLastAskedNull();

			drNew.BiomomAlive = Convert.ToInt16(biomomAlive);
			drNew.BiomomDeathCause = Convert.ToInt16(biomomDeathCause);

			if ( biomomDeathAge.HasValue ) drNew.BiomomDeathAge = biomomDeathAge.Value;
			else drNew.SetBiomomDeathAgeNull();

			drNew.BiomomUSBorn = Convert.ToInt16(biomomUSBorn);

			if ( biomomHighestGrade.HasValue ) drNew.BiomomHighestGrade = biomomHighestGrade.Value;
			else drNew.SetBiomomHighestGradeNull();

			//if ( drNew.BiomomAlive < 0 ) {
			//   Console.Beep();
			//}


			_ds.tblParentsOfGen1Current.AddtblParentsOfGen1CurrentRow(drNew);
			//}
		}
		#endregion
		#region Public/Private Static
		#endregion
	}
}

//private static Int16 DetermineLastHealthModuleYear ( Item item,byte loopIndex, Int32 subjectTag, LinksDataSet.tblResponseDataTable dtExtended ) {
//   const Int16 surveyYear = ItemYears.Gen1BioparentAlive;

//   string selectToGetLoopIndex = string.Format("{0}={1} AND {2}={3} AND {4}={5}",
//      subjectTag, dtExtended.SubjectTagColumn.ColumnName,
//      Convert.ToInt16(item), dtExtended.ItemColumn.ColumnName,
//      loopIndex, dtExtended.LoopIndexColumn.ColumnName);
//   LinksDataSet.tblResponseRow[] drsForLoopIndex = (LinksDataSet.tblResponseRow[])dtExtended.Select(selectToGetLoopIndex);
//   Trace.Assert(drsForLoopIndex.Length==1, "Exactly one row should be retrieved; nulls should have been filtered before it got to this function.");

//   Int16 response = Convert.ToInt16(drsForLoopIndex[0].Value);
//   Trace.Assert(response 
//}