using System.IO;
using System.Text;

namespace QuarterMaster_Cleanup
{
	internal static class FileIO
	{
		internal static string ReadText(string path)
		{
			return File.ReadAllText(path, Encoding.ASCII);
		}
		internal static void WriteText(string path, string data)
		{
			File.WriteAllText(path, data, Encoding.ASCII);
		}

		internal static bool Exists(string path)
		{
			return File.Exists(path);
		}
	}
}