using System;

namespace Nls.BaseAssembly {
	interface IAssignPass1 {
		Int32 IDLeft { get; }
		//Int32 IDRight { get; }
		MultipleBirth MultipleBirthIfSameSex { get; }
		Tristate IsMZ { get; }
		//Int16 RosterAssignmentID { get; }
		//float? RRoster { get; }

		float? RImplicitPass1 { get; }
		float? RImplicit2004 { get; }
		float? RExplicitOldestSibVersion { get; }
		float? RExplicitYoungestSibVersion { get; }
		float? RExplicitPass1 { get; }
		float? RPass1 { get; }
	}
}