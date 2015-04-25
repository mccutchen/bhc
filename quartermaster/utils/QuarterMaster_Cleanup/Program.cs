using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace QuarterMaster_Cleanup
{
	class Program
	{
		static int Main(string[] args)
		{
			if (args.Length != 1)
			{
				Console.WriteLine("USAGE:\n1st parameter is the path to the file. No other parameters are accepted.");
				Console.ReadLine();
				return 1;
			}

			else if (!FileIO.Exists(args[0]))
			{
				Console.WriteLine(String.Format("Unable to locate {0}.", args[0]));
				Console.ReadLine();
				return 2;
			}

			else
			{
				if (Repair_TaggedText_InDesign.Repair(args[0]))
					return 0;
				else
				{
					Console.WriteLine("Repair failed.");
					Console.ReadLine();
					return 3;
				}
			}
		}
	}
}
