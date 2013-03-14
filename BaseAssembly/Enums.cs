using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Nls.BaseAssembly {
	public enum QuadState : byte {
		No = 0,
		Yes = 1,
		Conflicting = 3,
		Missing = 255,
	}
}
