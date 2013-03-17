using System;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using Nls.BaseAssembly.Assign;

namespace Nls.BaseAssembly {
	public sealed class RelatedValues {
		#region Fields
		private readonly ImportDataSet _dsImport;
		private readonly LinksDataSet _dsLinks;
		#endregion
		#region Constructor
		public RelatedValues ( ImportDataSet dsImport, LinksDataSet dsLinks ) {
			if ( dsImport == null ) throw new ArgumentNullException("dsImport");
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( dsLinks.tblRelatedStructure.Count <= 0 ) throw new ArgumentException("There should NOT be zero rows in tblRelatedStructure.");
			if ( dsLinks.tblMarkerGen1.Count <= 0 ) throw new ArgumentException("There should NOT be zero rows in tblMarkerGen1.");
			if ( dsLinks.tblMarkerGen2.Count <= 0 ) throw new ArgumentException("There should NOT be zero rows in tblMarkerGen2.");
			if ( dsLinks.vewSurveyTimeMostRecent.Count <= 0 ) throw new ArgumentException("There should NOT be zero rows in vewSurveyTimeMostRecent.");
			if ( dsLinks.tblRelatedValues.Count != 0 ) throw new ArgumentException("There should be zero rows in tblRelatedValues.");
			_dsImport = dsImport;
			_dsLinks = dsLinks;
		}
		#endregion
		#region Public Methods
		public string Go ( ) {
			Stopwatch sw = new Stopwatch();
			sw.Start();
			Int32 gen1HousematesCount = Gen1Housemates();
			Int32 gen2SiblingsCount = Gen2Siblings();
			Int32 gen2CousinsCount = Gen2Cousins();
			Int32 parentChildCount = ParentChild();
			Int32 auntNieceCount = AuntNiece();
			//Int32 gen2SiblingsCount = 0;// Gen2Siblings();
			//Int32 gen2CousinsCount = 0;//Gen2Cousins();// 0;
			//Int32 parentChildCount = 0;//ParentChild();
			//Int32 auntNieceCount = 0;// AuntNiece();			

			if ( gen1HousematesCount > 0 ) Trace.Assert(gen1HousematesCount == Constants.Gen1HousematesPathCount, "The number of Gen1 Housemate paths should be correct.");
			if ( gen2SiblingsCount > 0 ) Trace.Assert(gen2SiblingsCount == Constants.Gen2SiblingsPathCount, "The number of Gen2 Sibling paths should be correct.");
			if ( gen2CousinsCount > 0 ) Trace.Assert(gen2CousinsCount == Constants.Gen2CousinsPathCount, "The number of Gen2 Cousins paths should be correct.");
			if ( parentChildCount > 0 ) Trace.Assert(parentChildCount == Constants.ParentChildPathCount, "The number of ParentChild paths should be correct.");
			if ( auntNieceCount > 0 ) Trace.Assert(auntNieceCount == Constants.AuntNiecePathCount, "The number of AuntNiece paths should be correct.");

			Int32 recordsAdded = gen1HousematesCount + gen2SiblingsCount + gen2CousinsCount + parentChildCount + auntNieceCount;
			sw.Stop();
			return string.Format("{0:N0} RelatedValues records were processed.\nElapsed time: {1}", recordsAdded, sw.Elapsed.ToString());
		}
		public static string Archive ( Int16 algorithmVersion, LinksDataSet ds ) {
			Stopwatch sw = new Stopwatch();
			sw.Start();
			Int32 recordsAdded = 0;
			foreach ( LinksDataSet.tblRelatedValuesRow drValues in ds.tblRelatedValues ) {
				LinksDataSet.tblRelatedValuesArchiveRow drNew = ds.tblRelatedValuesArchive.NewtblRelatedValuesArchiveRow();
				drNew.AlgorithmVersion = algorithmVersion;
				drNew.Subject1Tag = drValues.tblRelatedStructureRow.Subject1Tag;
				drNew.Subject2Tag = drValues.tblRelatedStructureRow.Subject2Tag;
				drNew.MultipleBirthIfSameSex = drValues.MultipleBirthIfSameSex;
				drNew.IsMz = drValues.IsMz;

				//if ( drValues.IsS() ) drNew.SetSubject1LastSurveyNull();
				//else drNew.Subject1LastSurvey = drValues.Subject1LastSurvey;

				LinksDataSet.tblRelatedStructureRow drStructure = ds.tblRelatedStructure.FindByID(drValues.ID);

				if ( drStructure.RelationshipPath == (byte)RelationshipPath.Gen1Housemates ) {
					LinksDataSet.tblRosterGen1Row drRoster = ds.tblRosterGen1.FindByRelatedID(drValues.ID);
					drNew.RosterAssignmentID = drRoster.RosterAssignmentID;
					drNew.SameGeneration = drRoster.SameGeneration;

					if ( drRoster.IsRNull() ) drNew.SetRRosterNull();
					else drNew.RRoster = drRoster.R;
				}
				else {
					drNew.SetRosterAssignmentIDNull();
					drNew.SetRRosterNull();
					drNew.SetSameGenerationNull();
				}

				if ( drValues.IsSubject1LastSurveyNull() ) drNew.SetSubject1LastSurveyNull();
				else drNew.Subject1LastSurvey = drValues.Subject1LastSurvey;

				if ( drValues.IsSubject2LastSurveyNull() ) drNew.SetSubject2LastSurveyNull();
				else drNew.Subject2LastSurvey = drValues.Subject2LastSurvey;

				if ( drValues.IsRImplicitPass1Null() ) drNew.SetRImplicitPass1Null();
				else drNew.RImplicitPass1 = drValues.RImplicitPass1;

				if ( drValues.IsRImplicitNull() ) drNew.SetRImplicitNull();
				else drNew.RImplicit = drValues.RImplicit;

				if ( drValues.IsRImplicitSubjectNull() ) drNew.SetRImplicitSubjectNull();
				else drNew.RImplicitSubject = drValues.RImplicitSubject;

				if ( drValues.IsRImplicitMotherNull() ) drNew.SetRImplicitMotherNull();
				else drNew.RImplicitMother = drValues.RImplicitMother;

				if ( drValues.IsRImplicit2004Null() ) drNew.SetRImplicit2004Null();
				else drNew.RImplicit2004 = drValues.RImplicit2004;

				if ( drValues.IsRExplicitOlderSibVersionNull() ) drNew.SetRExplicitOldestSibVersionNull();
				else drNew.RExplicitOldestSibVersion = drValues.RExplicitOlderSibVersion;

				if ( drValues.IsRExplicitYoungerSibVersionNull() ) drNew.SetRExplicitYoungestSibVersionNull();
				else drNew.RExplicitYoungestSibVersion = drValues.RExplicitYoungerSibVersion;

				if ( drValues.IsRExplicitPass1Null() ) drNew.SetRExplicitPass1Null();
				else drNew.RExplicitPass1 = drValues.RExplicitPass1;

				if ( drValues.IsRExplicitNull() ) drNew.SetRExplicitNull();
				else drNew.RExplicit = drValues.RExplicit;

				if ( drValues.IsRPass1Null() ) drNew.SetRPass1Null();
				else drNew.RPass1 = drValues.RPass1;

				if ( drValues.IsRNull() ) drNew.SetRNull();
				else drNew.R = drValues.R;

				if ( drValues.IsRFullNull() ) drNew.SetRFullNull();
				else drNew.RFull = drValues.RFull;

				if ( drValues.IsRPeekNull() ) drNew.SetRPeekNull();
				else drNew.RPeek = drValues.RPeek;

				ds.tblRelatedValuesArchive.AddtblRelatedValuesArchiveRow(drNew);
				recordsAdded += 1;
			}
			sw.Stop();
			string message = string.Format("{0:N0} RelatedValues records were archived.\n\nElapsed time: {1}", recordsAdded, sw.Elapsed.ToString());
			return message;
		}

		public static LinksDataSet.tblRelatedValuesRow Retrieve ( LinksDataSet ds, RelationshipPath relationshipPath, Int32 subject1Tag, Int32 subject2Tag ) {
			if ( ds.tblRelatedValues.Count <= 0 ) throw new ArgumentException("tblRelatedValues should have more than one row.", "ds");

			Int32 subjectTagSmaller = Int32.MinValue;
			Int32 subjectTagLarger = Int32.MinValue;
			if ( subject1Tag < subject2Tag ) {
				subjectTagSmaller = subject1Tag;
				subjectTagLarger = subject2Tag;
			}
			else {
				subjectTagSmaller = subject2Tag;
				subjectTagLarger = subject1Tag;
			}

			LinksDataSet.tblRelatedStructureRow drStructure = RelatedStructure.Retrieve(ds, relationshipPath, subjectTagSmaller, subjectTagLarger);
			Trace.Assert(drStructure != null, "The retrieved row should not be null.");
			return ds.tblRelatedValues.FindByID(drStructure.ID);
		}
		#endregion
		#region Private Methods
		private Int32 Gen1Housemates ( ) {
			const RelationshipPath path = RelationshipPath.Gen1Housemates;
			Int32 recordsAdded = 0;
			foreach ( LinksDataSet.tblRelatedStructureRow drLeft in SelectLefthand(path) ) {
				LinksDataSet.tblRelatedStructureRow drRight = SelectRighthand(drLeft);
				RGen1Pass1 pass1 = new RGen1Pass1(_dsImport, _dsLinks, drLeft, drRight);
				AddRow(pass1, pass1.IDLeft, drLeft.Subject1Tag, drLeft.Subject2Tag);
			}
			//foreach ( LinksDataSet.tblRelatedStructureRow drLeft in SelectLefthand(path) ) {
			Parallel.ForEach(SelectLefthand(path), ( drLeft ) => {
				LinksDataSet.tblRelatedStructureRow drRight = SelectRighthand(drLeft);
				RGen1Pass2 pass2 = new RGen1Pass2(_dsLinks, drLeft, drRight);
				UpdateRow(pass2, pass2.IDLeft);
				Interlocked.Increment(ref recordsAdded);
			});
			return recordsAdded;
		}
		private Int32 Gen2Siblings ( ) {
			const RelationshipPath path = RelationshipPath.Gen2Siblings;
			Int32 recordsAdded = 0;
			foreach ( LinksDataSet.tblRelatedStructureRow drLeft in SelectLefthand(path) ) {
				//Parallel.ForEach(SelectLefthand(path), ( drLeft ) => {
				LinksDataSet.tblRelatedStructureRow drRight = SelectRighthand(drLeft);
				RGen2Pass1 rGen2Pass1 = new RGen2Pass1(_dsImport, _dsLinks, drLeft, drRight);
				AddRow(rGen2Pass1, rGen2Pass1.IDLeft, drLeft.Subject1Tag, drLeft.Subject2Tag);
			}
			//foreach ( LinksDataSet.tblRelatedStructureRow drLeft in SelectLefthand(path) ) {
			Parallel.ForEach(SelectLefthand(path), ( drLeft ) => {
				LinksDataSet.tblRelatedStructureRow drRight = SelectRighthand(drLeft);
				RGen2Pass2 rGen2Pass2 = new RGen2Pass2(_dsLinks, drLeft, drRight);
				UpdateRow(rGen2Pass2, rGen2Pass2.IDLeft);
				Interlocked.Increment(ref recordsAdded);
			});
			return recordsAdded;
		}
		private Int32 ParentChild ( ) {
			const RelationshipPath path = RelationshipPath.ParentChild;
			Int32 recordsAdded = 0;
			foreach ( LinksDataSet.tblRelatedStructureRow drLeft in SelectLefthand(path) ) {
				RParentChild rParentChild = new RParentChild(_dsLinks, drLeft);
				AddRow(rParentChild, rParentChild.IDLeft, drLeft.Subject1Tag, drLeft.Subject2Tag);
				UpdateRow(rParentChild, rParentChild.IDLeft);
				recordsAdded += 1;
			}
			return recordsAdded;
		}
		private Int32 AuntNiece ( ) {
			const RelationshipPath path = RelationshipPath.AuntNiece;
			Int32 recordsAdded = 0;
			foreach ( LinksDataSet.tblRelatedStructureRow drLeft in SelectLefthand(path) ) {
				RAuntNiece rAuntNiece = new RAuntNiece(_dsLinks, drLeft); //drRight
				AddRow(rAuntNiece, rAuntNiece.IDLeft, drLeft.Subject1Tag, drLeft.Subject2Tag);
				UpdateRow(rAuntNiece, rAuntNiece.IDLeft);
				recordsAdded += 1;
			}
			return recordsAdded;
		}
		private Int32 Gen2Cousins ( ) {
			const RelationshipPath path = RelationshipPath.Gen2Cousins;
			Int32 recordsAdded = 0;
			foreach ( LinksDataSet.tblRelatedStructureRow drLeft in SelectLefthand(path) ) {
				RGen2Cousins rGen2Cousins = new RGen2Cousins(_dsLinks, drLeft); //drRight
				AddRow(rGen2Cousins, rGen2Cousins.IDLeft, drLeft.Subject1Tag, drLeft.Subject2Tag);
				UpdateRow(rGen2Cousins, rGen2Cousins.IDLeft);
				recordsAdded += 1;
			}
			return recordsAdded;
		}
		private LinksDataSet.tblRelatedStructureRow[] SelectLefthand ( RelationshipPath path ) {
			//"Lefthand" is my slang for the lower/smaller SubjectTag corresponds to Subject1.
			string select = string.Format("{0}={1} AND {2}<{3}",
				(byte)path, _dsLinks.tblRelatedStructure.RelationshipPathColumn.ColumnName,
				 _dsLinks.tblRelatedStructure.Subject1TagColumn.ColumnName, _dsLinks.tblRelatedStructure.Subject2TagColumn.ColumnName);
			return (LinksDataSet.tblRelatedStructureRow[])_dsLinks.tblRelatedStructure.Select(select);
		}
		private LinksDataSet.tblRelatedStructureRow SelectRighthand ( LinksDataSet.tblRelatedStructureRow drLeft ) {
			//"Lefthand" is my slang for the lower/smaller SubjectTag corresponds to Subject1.
			string select = string.Format("{0}={1} AND {2}={3}", //Why is the second comparison "="  (Will -June 7, 2012)
				drLeft.Subject1Tag, _dsLinks.tblRelatedStructure.Subject2TagColumn.ColumnName,
				drLeft.Subject2Tag, _dsLinks.tblRelatedStructure.Subject1TagColumn.ColumnName);
			LinksDataSet.tblRelatedStructureRow[] drs = (LinksDataSet.tblRelatedStructureRow[])_dsLinks.tblRelatedStructure.Select(select);
			Trace.Assert(drs.Length == 1, "Exactly 1 row should be selected.");
			return drs[0];
		}

		private void AddRow ( IAssignPass1 assignPass1, Int32 relatedID, Int32 subject1Tag, Int32 subject2Tag ) {
			lock ( _dsLinks.tblRelatedValues ) {
				LinksDataSet.tblRelatedValuesRow drNew = _dsLinks.tblRelatedValues.NewtblRelatedValuesRow();
				drNew.ID = relatedID;
				drNew.MultipleBirthIfSameSex = (byte)assignPass1.MultipleBirthIfSameSex;
				drNew.IsMz = (byte)assignPass1.IsMZ;

				Int16? subject1MostRecent = SurveyTimeMostRecent(subject1Tag);
				if ( subject1MostRecent.HasValue ) drNew.Subject1LastSurvey = subject1MostRecent.Value;
				else drNew.SetSubject1LastSurveyNull();

				Int16? subject2MostRecent = SurveyTimeMostRecent(subject2Tag);
				if ( subject2MostRecent.HasValue ) drNew.Subject2LastSurvey = subject2MostRecent.Value;
				else drNew.SetSubject2LastSurveyNull();

				if ( assignPass1.RImplicitPass1.HasValue ) drNew.RImplicitPass1 = assignPass1.RImplicitPass1.Value;
				else drNew.SetRImplicitPass1Null();

				if ( assignPass1.RImplicit2004.HasValue ) drNew.RImplicit2004 = assignPass1.RImplicit2004.Value;
				else drNew.SetRImplicit2004Null();

				if ( assignPass1.RExplicitOldestSibVersion.HasValue ) drNew.RExplicitOlderSibVersion = assignPass1.RExplicitOldestSibVersion.Value;
				else drNew.SetRExplicitOlderSibVersionNull();

				if ( assignPass1.RExplicitYoungestSibVersion.HasValue ) drNew.RExplicitYoungerSibVersion = assignPass1.RExplicitYoungestSibVersion.Value;
				else drNew.SetRExplicitYoungerSibVersionNull();

				if ( assignPass1.RExplicitPass1.HasValue ) drNew.RExplicitPass1 = assignPass1.RExplicitPass1.Value;
				else drNew.SetRExplicitPass1Null();

				if ( assignPass1.RPass1.HasValue ) drNew.RPass1 = assignPass1.RPass1.Value;
				else drNew.SetRPass1Null();

				//The following will be set during Pass2 (below)
				drNew.SetRImplicitNull();
				drNew.SetRImplicitSubjectNull();
				drNew.SetRImplicitMotherNull();
				drNew.SetRExplicitNull();
				drNew.SetRFullNull();
				drNew.SetRPeekNull();

				_dsLinks.tblRelatedValues.AddtblRelatedValuesRow(drNew);
			}
		}
		private void UpdateRow ( IAssignPass2 assignPass2, Int32 relatedID ) {
			lock ( _dsLinks.tblRelatedValues ) {
				LinksDataSet.tblRelatedValuesRow drUpdated = _dsLinks.tblRelatedValues.FindByID(relatedID);
				//lock ( drUpdated ) {
				if ( assignPass2.RImplicit.HasValue ) drUpdated.RImplicit = assignPass2.RImplicit.Value;
				else drUpdated.SetRImplicitNull();

				if ( assignPass2.RImplicitSubject.HasValue ) drUpdated.RImplicitSubject = assignPass2.RImplicitSubject.Value;
				else drUpdated.SetRImplicitSubjectNull();

				if ( assignPass2.RImplicitMother.HasValue ) drUpdated.RImplicitMother = assignPass2.RImplicitMother.Value;
				else drUpdated.SetRImplicitMotherNull();

				if ( assignPass2.RExplicit.HasValue ) drUpdated.RExplicit = assignPass2.RExplicit.Value;
				else drUpdated.SetRExplicitNull();

				if ( assignPass2.R.HasValue ) drUpdated.R = assignPass2.R.Value;
				else drUpdated.SetRNull();

				if ( assignPass2.RFull.HasValue ) drUpdated.RFull = assignPass2.RFull.Value;
				else drUpdated.SetRFullNull();

				if ( assignPass2.RPeek.HasValue ) drUpdated.RPeek = assignPass2.RPeek.Value;
				else drUpdated.SetRPeekNull();
			}
		}
		private Int16? SurveyTimeMostRecent ( Int32 subjectTag ) {
			LinksDataSet.vewSurveyTimeMostRecentRow dr = _dsLinks.vewSurveyTimeMostRecent.FindBySubjectTag(subjectTag);
			if ( dr == null )
				return null;
			else
				return dr.SurveyYearMostRecent;
		}
		#endregion
	}
}