﻿using System;

namespace Nls.BaseAssembly {
	public static class ItemYears {
		public const Int16 Gen1Roster = 1979;

		public readonly static Int16[] Gen1AndGen2 = { 1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };

		public readonly static Int16[] ShareBiodad = { 2006, 2008, 2010 };
		public readonly static Int16[] FatherAsthmaGen2 = { 2004, 2006, 2008 };

		public readonly static Int16[] BabyDaddyItems = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyInHH = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyIsAlive = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyInHHEver = { 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyLeftHHMonthOrNeverLivedInHH = { 1992 };
		public readonly static Int16[] BabyDaddyLeftHHMonth = { 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyLeftHHYearNeverAsked = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991 };
		public readonly static Int16[] BabyDaddyLeftHHYearTwoDigit = { 1992, 1993 };
		public readonly static Int16[] BabyDaddyLeftHHYearFourDigit = { 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyLeftHHDate = { 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };

		public readonly static Int16[] BabyDaddyDeathNeverAsked = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991 };
		public readonly static Int16[] BabyDaddyDeathTwoDigitYear = { 1992, 1993 };
		public readonly static Int16[] BabyDaddyDeathFourDigitYear = { 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyDeathDate = { 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyDistanceFromHHFuzzyCeiling = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] BabyDaddyAsthma = { 2004, 2006, 2008, 2010 };


		public readonly static Int16[] Gen2CFatherItems = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1991, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };
		public readonly static Int16[] Gen2CFatherInHH = { 1984, 1985, 1986, 1987, 1988, 1989, 1990, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };//No 1991
		public readonly static Int16[] Gen2CFatherAlive = { 1984, 1985, 1986, 1988, 1990, 1992, 1993, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 }; //No 1987, 1989, 1991 (but 1993 is present)
		public readonly static Int16[] Gen2CFatherDistanceFromMotherFuzzyCeiling = { 1984, 1985, 1986, 1988, 1990, 1992, 1994, 1996, 1998, 2000, 2002, 2004, 2006, 2008, 2010 };//No odd years after 1985

	}
}