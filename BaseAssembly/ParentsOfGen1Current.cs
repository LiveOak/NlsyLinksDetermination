using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Nls.BaseAssembly {
	public sealed class ParentsOfGen1Current {
		#region Fields
		private readonly LinksDataSet _ds;
		private readonly Item[] _items = { Item.Gen1FatherAlive, Item.Gen1FatherDeathCause, Item.Gen1FatherDeathAge, Item.Gen1FatherBirthCountry, Item.Gen1FatherHighestGrade, Item.Gen1GrandfatherBirthCountry,
													Item.Gen1MotherAlive, Item.Gen1MotherDeathCause, Item.Gen1MotherDeathAge, Item.Gen1MotherBirthCountry, Item.Gen1MotherHighestGrade};
		private readonly string _itemIDsString = "";
		#endregion
		#region Constructor
		public ParentsOfGen1Current ( LinksDataSet ds ) {
		   if ( ds == null ) throw new ArgumentNullException("ds");
		   if ( ds.tblResponse.Count <= 0 ) throw new InvalidOperationException("tblResponse must NOT be empty.");
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
			throw new NotImplementedException();
			Int32 subjectTag = drSubject.SubjectTag;

			//   foreach ( Int16 surveyYear in ItemYears.Gen1BiomomInHH ) {
			//      foreach ( byte loopIndexAndAge in loopIndicesAndAges ) {
			//         YesNo biodadInHH = DetermineBiodadInHH(Item.Gen1LivedWithFatherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);
			//         YesNo biomomInHH = DetermineBiodadInHH(Item.Gen1LivedWithMotherAtAgeX, surveyYear, subjectTag, loopIndexAndAge, dtExtendedResponse);



			Int16 biodadAliveLastAsked;
			YesNo biodadAlive;
			byte biodadDeathCause;
			byte biodadDeathAge;
			byte biodadBirthCountry;
			byte biodadHighestGrade;
			byte biograndfatherBirthCountry;

			Int16 biomomAliveLastAsked;
			YesNo biomomAlive;
			byte biomomDeathCause;
			byte biomomDeathAge;
			byte biomomBirthCountry;
			byte biomomHighestGrade;

			AddRow(subjectTag, biodadAliveLastAsked, biodadAlive, biodadDeathCause, biodadDeathAge, biodadBirthCountry, biodadHighestGrade, biograndfatherBirthCountry,
				biomomAliveLastAsked, biomomAlive, biomomDeathCause, biomomDeathAge, biomomBirthCountry, biomomHighestGrade);
			
			const Int32 recordsAdded = 0;
			return recordsAdded;
		}
		//private static YesNo DetermineBiodadInHH ( Item item, Int16 surveyYear, Int32 subjectTag, byte loopIndex, LinksDataSet.tblResponseDataTable dtExtended ) {
		//   Int32? response = Retrieve.ResponseNullPossible(surveyYear, item, subjectTag, loopIndex, dtExtended);
		//   if ( !response.HasValue )
		//      return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;

		//   EnumResponsesGen1.BioparentOfGen1InHH codedResponse = (EnumResponsesGen1.BioparentOfGen1InHH)response.Value;
		//   switch ( codedResponse ) {
		//      case EnumResponsesGen1.BioparentOfGen1InHH.NonInterview:
		//      case EnumResponsesGen1.BioparentOfGen1InHH.ValidSkip:
		//      case EnumResponsesGen1.BioparentOfGen1InHH.InvalidSkip:
		//      case EnumResponsesGen1.BioparentOfGen1InHH.DoNotKnow:
		//      case EnumResponsesGen1.BioparentOfGen1InHH.Refusal:
		//         return YesNo.ValidSkipOrNoInterviewOrNotInSurvey;
		//      case EnumResponsesGen1.BioparentOfGen1InHH.No:
		//         return YesNo.No;
		//      case EnumResponsesGen1.BioparentOfGen1InHH.Yes:
		//         return YesNo.Yes;
		//      default: throw new InvalidOperationException("The response " + codedResponse + " was not recognized.");
		//   }
		//}
		private void AddRow ( Int32 subjectTag, Int16 biodadAliveLastAsked, YesNo biodadAlive, byte biodadDeathCause, byte biodadDeathAge, byte biodadBirthCountry, byte biodadHighestGrade, byte biograndfatherBirthCountry,
			Int16 biomomAliveLastAsked, YesNo biomomAlive, byte biomomDeathCause, byte biomomDeathAge, byte biomomBirthCountry, byte biomomHighestGrade ) {

			//lock ( _ds.tblFatherOfGen2 ) {
			LinksDataSet.tblParentsOfGen1CurrentRow drNew = _ds.tblParentsOfGen1Current.NewtblParentsOfGen1CurrentRow();
			drNew.SubjectTag = subjectTag;
			drNew.BiodadAliveLastAsked = Convert.ToInt16(biodadAliveLastAsked);
			drNew.BiodadAlive = Convert.ToInt16(biodadAlive);
			drNew.BiodadDeathCause = biodadDeathCause;
			drNew.BiodadDeathAge = biodadDeathAge;
			drNew.BiodadBirthCountry = biodadBirthCountry;
			drNew.BiodadHighestGrade = biodadHighestGrade;
			drNew.BiograndfatherBirthCountry = biograndfatherBirthCountry;

			drNew.BiomomAliveLastAsked = Convert.ToInt16(biomomAliveLastAsked);
			drNew.BiomomAlive = Convert.ToInt16(biomomAlive);
			drNew.BiomomDeathCause = biomomDeathCause;
			drNew.BiomomDeathAge = biomomDeathAge;
			drNew.BiomomBirthCountry = biomomBirthCountry;
			drNew.BiomomHighestGrade = biomomHighestGrade;

			_ds.tblParentsOfGen1Current.AddtblParentsOfGen1CurrentRow(drNew);
			//}
		}
		#endregion
		#region Public/Private Static
		#endregion
	}
}