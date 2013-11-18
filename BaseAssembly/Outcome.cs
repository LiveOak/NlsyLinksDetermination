using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace Nls.BaseAssembly {
    public class Outcome {
        #region Fields
        private readonly LinksDataSet _ds;
        private readonly Item[] _items = { Item.Gen1HeightInches, Item.Gen1WeightPounds, Item.Gen1AfqtScaled5Decimals };
        private readonly string _itemIDsString = "";
        #endregion
        #region Constructor
        public Outcome( LinksDataSet ds ) {
            if( ds == null ) throw new ArgumentNullException("ds");
            if( ds.tblSubject.Count <= 0 ) throw new InvalidOperationException("tblSubject must NOT be empty.");
            if( ds.tblResponse.Count <= 0 ) throw new InvalidOperationException("tblResponse must NOT be empty.");
            if( ds.tblSurveyTime.Count <= 0 ) throw new InvalidOperationException("tblSurveyTime must NOT be empty.");
            if( ds.tblOutcome.Count != 0 ) throw new InvalidOperationException("tblOutcome must be empty before creating rows for it.");
            _ds = ds;

            _itemIDsString = CommonCalculations.ConvertItemsToString(_items);
        }
        #endregion
        #region Public Methods
        public string Go( ) {
            const Int32 minRowCount = 1;//This is somewhat arbitrary.
            Stopwatch sw = new Stopwatch();
            sw.Start();
            Retrieve.VerifyResponsesExistForItem(_items, _ds);
            Int32 recordsAddedTotal = 0;
            _ds.tblOutcome.BeginLoadData();
            Int16[] extendedIDs = CommonFunctions.CreateExtendedFamilyIDs(_ds);
            Parallel.ForEach(extendedIDs, ( extendedID ) => {//
                //foreach(Int32 extendedID in  extendedIDs){
                LinksDataSet.tblResponseDataTable dtExtended = Retrieve.ExtendedFamilyRelevantResponseRows(extendedID, _itemIDsString, minRowCount, _ds.tblResponse);
                LinksDataSet.tblSubjectRow[] subjectsInExtendedFamily = Retrieve.SubjectsInExtendFamily(extendedID, _ds.tblSubject);
                foreach( LinksDataSet.tblSubjectRow drSubject in subjectsInExtendedFamily ) {
                    Int32 recordsAddedForLoop = ProcessSubject(drSubject, dtExtended);//subjectsInExtendedFamily
                    Interlocked.Add(ref recordsAddedTotal, recordsAddedForLoop);
                }
            });
            _ds.tblOutcome.EndLoadData();
            Trace.Assert(recordsAddedTotal == Constants.Gen1Count + Constants.Gen2Count, "The number of Gen1+Gen2 subjects should be correct.");
            //Trace.Assert(recordsAddedTotal == Constants.Gen1Count , "The number of Gen1+Gen2 subjects should be correct.");


            sw.Stop();
            return string.Format("{0:N0} SubjectDetails records were created.\nElapsed time: {1}", recordsAddedTotal, sw.Elapsed.ToString());
        }
        #endregion
        #region Private Methods
        private Int32 ProcessSubject( LinksDataSet.tblSubjectRow drSubject, LinksDataSet.tblResponseDataTable dtExtended ) {
            Int32 subjectTag = drSubject.SubjectTag;
            byte? heightInchesLateTeens = null;
            Int16? weightPoundsLateTeens = null;
            float? afqt = null;

            if( drSubject.Generation == (byte)Generation.Gen1 ) {
                heightInchesLateTeens = DetermineHeightIn1982(drSubject, dtExtended);
                weightPoundsLateTeens = DetermineWeightIn1982(drSubject, dtExtended);
                afqt = DetermineAfqtIn1985(drSubject, dtExtended);
                AddRow(subjectTag, heightInchesLateTeens, weightPoundsLateTeens, afqt);
                return 1;
            } else if( drSubject.Generation == (byte)Generation.Gen2 ) {
                AddRow(subjectTag, null, null, null);

                return 1;
            } else {
                return 0;
            }

        }
        private byte? DetermineHeightIn1982( LinksDataSet.tblSubjectRow drSubject, LinksDataSet.tblResponseDataTable dtExtended ) {
            const Int16 surveyYear = 1982;
            const Item item = Item.Gen1HeightInches;
            const SurveySource source = SurveySource.Gen1;
            const byte maxRows = 1;
            Int32? response = Retrieve.ResponseNullPossible(surveyYear, item, source, drSubject.SubjectTag, maxRows, dtExtended);
            byte? converted = (byte?)response;
            return converted;
        }
        private Int16? DetermineWeightIn1982( LinksDataSet.tblSubjectRow drSubject, LinksDataSet.tblResponseDataTable dtExtended ) {
            const Int16 surveyYear = 1982;
            const Item item = Item.Gen1WeightPounds;
            const SurveySource source = SurveySource.Gen1;
            const byte maxRows = 1;
            Int32? response = Retrieve.ResponseNullPossible(surveyYear, item, source, drSubject.SubjectTag, maxRows, dtExtended);
            return (Int16?)response;
        }
        private float? DetermineAfqtIn1985( LinksDataSet.tblSubjectRow drSubject, LinksDataSet.tblResponseDataTable dtExtended ) {
            const Int16 surveyYear = 1981;
            const Item item = Item.Gen1AfqtScaled5Decimals;
            const SurveySource source = SurveySource.Gen1;
            const byte maxRows = 1;
            Int32? response = Retrieve.ResponseNullPossible(surveyYear, item, source, drSubject.SubjectTag, maxRows, dtExtended);

            if( response.HasValue && response >= 0 )
                return ((float)(response / (double)100000));
            else
                return null;
        }
        private void AddRow( Int32 subjectTag, byte? heightInchesLateTeens, Int16? weightPoundsLateTeens, float? afqt ) {
            lock( _ds.tblSubjectDetails ) {
                LinksDataSet.tblOutcomeRow drNew = _ds.tblOutcome.NewtblOutcomeRow();
                drNew.SubjectTag = subjectTag;

                //if( heightInchesLateTeens.HasValue ) drNew.HeightInchesLateTeens = (byte)heightInchesLateTeens;
                //else drNew.SetHeightInchesLateTeensNull();

                //if( weightPoundsLateTeens.HasValue ) drNew.WeightPoundsLateTeens = (Int16)weightPoundsLateTeens;
                //else drNew.SetWeightPoundsLateTeensNull();

                //if( afqt.HasValue ) drNew.AfqtRescaled2006Bounded = (float)afqt;
                //else drNew.SetAfqtRescaled2006BoundedNull();

                _ds.tblOutcome.AddtblOutcomeRow(drNew);
            }
        }
        #endregion
    }
}
