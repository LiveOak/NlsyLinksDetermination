using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;

namespace Nls.BaseAssembly {
	public static class CommonFunctions {
		public static byte LastTwoDigitsOfGen2SubjectID ( LinksDataSet.tblSubjectRow drSubject ) {
			if ( drSubject == null ) throw new ArgumentNullException("drSubject");
			if ( drSubject.Generation != (byte)Generation.Gen2 ) throw new ArgumentOutOfRangeException("drSubject", drSubject.Generation, "This function is valid for only Gen2 subjects.");
			string subjectIDString = drSubject.SubjectID.ToString();
			Int32 startIndex = subjectIDString.Length - 2;
			return Convert.ToByte(subjectIDString.Substring(startIndex));
		}
		public static Int16[] CreateExtendedFamilyIDs ( LinksDataSet dsLinks ) {
			if ( dsLinks == null ) throw new ArgumentNullException("dsLinks");
			if ( dsLinks.tblSubject.Count <= 0 ) throw new ArgumentException("The tblSubject is empty.", "dsLinks");
			IEnumerable<Int16> ids = (from dr in dsLinks.tblSubject
											  select dr.ExtendedID).Distinct();
			return ids.ToArray();
		}
		internal static bool BothGen1 ( LinksDataSet.tblSubjectRow drSubject1, LinksDataSet.tblSubjectRow drSubject2 ) {
			if ( drSubject1 == null ) throw new ArgumentNullException("drSubject1");
			if ( drSubject2 == null ) throw new ArgumentNullException("drSubject2");
			return drSubject1.Generation == (byte)Generation.Gen1 && drSubject2.Generation == (byte)Generation.Gen1;
		}
		//internal static bool BothGen1 ( LinksDataSet.tblRelatedRow drRelated ) {
		//   if ( drRelated == null ) throw new ArgumentNullException("drRelated");
		//   LinksDataSet.tblSubjectRow drSubject1 = drRelated.tblSubjectRowByFK_tblRelated_tblSubject_Subject1;
		//   LinksDataSet.tblSubjectRow drSubject2 = drRelated.tblSubjectRowByFK_tblRelated_tblSubject_Subject2;
		//   return BothGen1(drSubject1, drSubject2);
		//}
		//internal static bool BothGen2 ( LinksDataSet.tblSubjectRow drSubject1, LinksDataSet.tblSubjectRow drSubject2 ) {
		//   if ( drSubject1 == null ) throw new ArgumentNullException("drSubject1");
		//   if ( drSubject2 == null ) throw new ArgumentNullException("drSubject2");
		//   return drSubject1.Generation == (byte)Generation.Gen2 && drSubject2.Generation == (byte)Generation.Gen2;
		//}		
	}
}