using Nls.BaseAssembly;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace Nls.Tests.BaseFixture {

	[TestClass()]
	public class CommonFunctionsFixture {

		[TestMethod()]
		public void LastTwoDigitsOfGen2SubjectIDTest2 ( ) {
			LinksDataSet ds = new LinksDataSet();
			LinksDataSet.tblSubjectRow dr = ds.tblSubject.NewtblSubjectRow();
			dr.ExtendedID = 10;
			dr.SubjectID = 1002;
			dr.Generation = (byte)Generation.Gen2;
			dr.Gender = (byte)Gender.Male;
			Int32 expected = 2; 
			Int32 actual = CommonFunctions.LastTwoDigitsOfGen2SubjectID(dr);
			Assert.AreEqual(expected, actual);
		}
		[TestMethod()]
		public void LastTwoDigitsOfGen2SubjectIDTest22 ( ) {
			LinksDataSet ds = new LinksDataSet();
			LinksDataSet.tblSubjectRow dr = ds.tblSubject.NewtblSubjectRow();
			dr.ExtendedID = 4000;
			dr.SubjectID = 400122;
			dr.Generation = (byte)Generation.Gen2;
			dr.Gender = (byte)Gender.Male;
			Int32 expected = 22; 
			Int32 actual = CommonFunctions.LastTwoDigitsOfGen2SubjectID(dr);
			Assert.AreEqual(expected, actual);
		}
	}
}