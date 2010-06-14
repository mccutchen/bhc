using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace QuarterMaster_Cleanup
{
	internal static class Repair_TaggedText_InDesign
	{
		internal static Dictionary<string, string> ReplacementMap = new Dictionary<string, string>()
		{
			# region Initial Values
			{@"<\#128>", "<0x00C4>"},  // Ä	Latin capital letter A with diaeresis
			{@"<\#129>", "<0x00C5>"},  // Å	Latin capital letter A with ring above
			{@"<\#130>", "<0x00C7>"},  // Ç	Latin capital letter C with cedilla
			{@"<\#131>", "<0x00C9>"},  // É	Latin capital letter E with acute
			{@"<\#132>", "<0x00D1>"},  // Ñ	Latin capital letter N with tilde
			{@"<\#133>", "<0x00D6>"},  // Ö	Latin capital letter O with diaeresis
			{@"<\#134>", "<0x00DC>"},  // Ü	Latin capital letter U with diaeresis
			{@"<\#135>", "<0x00E1>"},  // á	Latin small letter a with acute
			{@"<\#136>", "<0x00E0>"},  // à	Latin small letter a with grave
			{@"<\#137>", "<0x00E2>"},  // â	Latin small letter a with circumflex
			{@"<\#138>", "<0x00E4>"},  // ä	Latin small letter a with diaeresis
			{@"<\#139>", "<0x00E3>"},  // ã	Latin small letter a with tilde
			{@"<\#140>", "<0x00E5>"},  // å	Latin small letter a with ring above
			{@"<\#141>", "<0x00E7>"},  // ç	Latin small letter c with cedilla
			{@"<\#142>", "<0x00E9>"},  // é	Latin small letter e with acute
			{@"<\#143>", "<0x00E8>"},  // è	Latin small letter e with grave
			{@"<\#144>", "<0x00EA>"},  // ê	Latin small letter e with circumflex
			{@"<\#145>", "<0x00EB>"},  // ë	Latin small letter e with diaeresis
			{@"<\#146>", "<0x00ED>"},  // í	Latin small letter i with acute
			{@"<\#147>", "<0x00EC>"},  // ì	Latin small letter i with grave
			{@"<\#148>", "<0x00EE>"},  // î	Latin small letter i with circumflex
			{@"<\#149>", "<0x00EF>"},  // ï	Latin small letter i with diaeresis
			{@"<\#150>", "<0x00F1>"},  // ñ	Latin small letter n with tilde
			{@"<\#151>", "<0x00F3>"},  // ó	Latin small letter o with acute
			{@"<\#152>", "<0x00F2>"},  // ò	Latin small letter o with grave
			{@"<\#153>", "<0x00F4>"},  // ô	Latin small letter o with circumflex
			{@"<\#154>", "<0x00F6>"},  // ö	Latin small letter o with diaeresis
			{@"<\#155>", "<0x00F5>"},  // õ	Latin small letter o with tilde
			{@"<\#156>", "<0x00FA>"},  // ú	Latin small letter u with acute
			{@"<\#157>", "<0x00F9>"},  // ù	Latin small letter u with grave
			{@"<\#158>", "<0x00FB>"},  // û	Latin small letter u with circumflex
			{@"<\#159>", "<0x00FC>"},  // ü	Latin small letter u with diaeresis
			{@"<\#160>", "<0x2020>"},  // †	dagger
			{@"<\#161>", "<0x00B0>"},  // °	degree sign
			{@"<\#162>", "<0x00A2>"},  // ¢	cent sign
			{@"<\#163>", "<0x00A3>"},  // £	pound sign
			{@"<\#164>", "<0x00A7>"},  // §	section sign
			{@"<\#165>", "<0x2022>"},  // •	bullet
			{@"<\#166>", "<0x00B6>"},  // ¶	pilcrow sign
			{@"<\#167>", "<0x00DF>"},  // ß	Latin small letter sharp s
			{@"<\#168>", "<0x00AE>"},  // ®	registered sign
			{@"<\#169>", "<0x00A9>"},  // ©	copyright sign
			{@"<\#170>", "<0x2122>"},  // ™	trade mark sign
			{@"<\#171>", "<0x00B4>"},  // ´	acute accent
			{@"<\#172>", "<0x00A8>"},  // ¨	diaeresis
			{@"<\#173>", "<0x2260>"},  // ≠	not equal to
			{@"<\#174>", "<0x00C6>"},  // Æ	Latin capital letter AE
			{@"<\#175>", "<0x00D8>"},  // Ø	Latin capital letter O with stroke
			{@"<\#176>", "<0x221E>"},  // ∞	infinity
			{@"<\#177>", "<0x00B1>"},  // ±	plus-minus sign
			{@"<\#178>", "<0x2264>"},  // ≤	less-than or equal to
			{@"<\#179>", "<0x2265>"},  // ≥	greater-than or equal to
			{@"<\#180>", "<0x00A5>"},  // ¥	yen sign
			{@"<\#181>", "<0x00B5>"},  // µ	micro sign
			{@"<\#182>", "<0x2202>"},  // ∂	partial differential
			{@"<\#183>", "<0x2211>"},  // ∑	n-ary summation
			{@"<\#184>", "<0x220F>"},  // ∏	n-ary product
			{@"<\#185>", "<0x03C0>"},  // π	Greek small letter pi
			{@"<\#186>", "<0x222B>"},  // ∫	integral
			{@"<\#187>", "<0x00AA>"},  // ª	feminine ordinal Indicator
			{@"<\#188>", "<0x00BA>"},  // º	masculine ordinal Indicator
			{@"<\#189>", "<0x03A9>"},  // Ω	Greek Capital letter Omega
			{@"<\#190>", "<0x00E6>"},  // æ	Latin small letter ae
			{@"<\#191>", "<0x00F8>"},  // ø	Latin small letter o with stroke
			{@"<\#192>", "<0x00BF>"},  // ¿	inverted Question mark
			{@"<\#193>", "<0x00A1>"},  // ¡	inverted exclamation mark
			{@"<\#194>", "<0x00AC>"},  // ¬	not sign
			{@"<\#195>", "<0x221A>"},  // √	square root
			{@"<\#196>", "<0x0192>"},  // ƒ	Latin small letter f with hook
			{@"<\#197>", "<0x2248>"},  // ≈	almost equal to
			{@"<\#198>", "<0x2206>"},  // ∆	increment
			{@"<\#199>", "<0x00AB>"},  // «	left-pointing double angle Quotation mark
			{@"<\#200>", "<0x00BB>"},  // »	right-pointing double angle Quotation mark
			{@"<\#201>", "<0x2026>"},  // …	horizontal ellipsis
			{@"<\#202>", "<0x00A0>"},  //  	no-break space
			{@"<\#203>", "<0x00C0>"},  // À	Latin capital letter A with grave
			{@"<\#204>", "<0x00C3>"},  // Ã	Latin capital letter A with tilde
			{@"<\#205>", "<0x00D5>"},  // Õ	Latin capital letter O with tilde
			{@"<\#206>", "<0x0152>"},  // Œ	Latin capital ligature OE
			{@"<\#207>", "<0x0153>"},  // œ	Latin small ligature oe
			{@"<\#208>", "<0x2013>"},  // –	en dash
			{@"<\#209>", "<0x2014>"},  // —	em dash
			{@"<\#210>", "<0x201C>"},  // “	left double Quotation mark
			{@"<\#211>", "<0x201D>"},  // ”	right double Quotation mark
			{@"<\#212>", "<0x2018>"},  // ‘	left single Quotation mark
			{@"<\#213>", "<0x2019>"},  // ’	right single Quotation mark
			{@"<\#214>", "<0x00F7>"},  // ÷	division sign
			{@"<\#215>", "<0x25CA>"},  // ◊	lozenge
			{@"<\#216>", "<0x00FF>"},  // ÿ	Latin small letter y with diaeresis
			{@"<\#217>", "<0x0178>"},  // Ÿ	Latin capital letter Y with diaeresis
			{@"<\#218>", "<0x2044>"},  // ⁄	fraction slash
			{@"<\#219>", "<0x20AC>"},  // €	euro sign
			{@"<\#220>", "<0x2039>"},  // ‹	single left-pointing angle Quotation mark
			{@"<\#221>", "<0x203A>"},  // ›	single right-pointing angle Quotation mark
			{@"<\#222>", "<0xFB01>"},  // ﬁ	Latin small ligature fi
			{@"<\#223>", "<0xFB02>"},  // ﬂ	Latin small ligature fl
			{@"<\#224>", "<0x2021>"},  // ‡	double dagger
			{@"<\#225>", "<0x00B7>"},  // ·	middle dot
			{@"<\#226>", "<0x201A>"},  // ‚	single low-9 Quotation mark
			{@"<\#227>", "<0x201E>"},  // „	double low-9 Quotation mark
			{@"<\#228>", "<0x2030>"},  // ‰	per mille sign
			{@"<\#229>", "<0x00C2>"},  // Â	Latin capital letter A with circumflex
			{@"<\#230>", "<0x00CA>"},  // Ê	Latin capital letter E with circumflex
			{@"<\#231>", "<0x00C1>"},  // Á	Latin capital letter A with acute
			{@"<\#232>", "<0x00CB>"},  // Ë	Latin capital letter E with diaeresis
			{@"<\#233>", "<0x00C8>"},  // È	Latin capital letter E with grave
			{@"<\#234>", "<0x00CD>"},  // Í	Latin capital letter I with acute
			{@"<\#235>", "<0x00CE>"},  // Î	Latin capital letter I with circumflex
			{@"<\#236>", "<0x00CF>"},  // Ï	Latin capital letter I with diaeresis
			{@"<\#237>", "<0x00CC>"},  // Ì	Latin capital letter I with grave
			{@"<\#238>", "<0x00D3>"},  // Ó	Latin capital letter O with acute
			{@"<\#239>", "<0x00D4>"},  // Ô	Latin capital letter O with circumflex
			{@"<\#240>", "<0xF8FF>"},  // 	Apple logo
			{@"<\#241>", "<0x00D2>"},  // Ò	Latin capital letter O with grave
			{@"<\#242>", "<0x00DA>"},  // Ú	Latin capital letter U with acute
			{@"<\#243>", "<0x00DB>"},  // Û	Latin capital letter U with circumflex
			{@"<\#244>", "<0x00D9>"},  // Ù	Latin capital letter U with grave
			{@"<\#245>", "<0x0131>"},  // ı	Latin capital letter dotless i
			{@"<\#246>", "<0x02C6>"},  // ˆ	Modifier letter circumflex accent
			{@"<\#247>", "<0x02DC>"},  // ˜	small tilde
			{@"<\#248>", "<0x00AF>"},  // ¯	macron
			{@"<\#249>", "<0x02D8>"},  // ˘	breve
			{@"<\#250>", "<0x02D9>"},  // ˙	dot above
			{@"<\#251>", "<0x02DA>"},  // ˚	ring above
			{@"<\#252>", "<0x00B8>"},  // ¸	cedilla
			{@"<\#253>", "<0x02DD>"},  // ˝	double acute accent
			{@"<\#254>", "<0x02DB>"},  // ˛	ogonek
			{@"<\#255>", "<0x02C7>"}  // ˇ	caron
			# endregion Initial Values

			# region Resources
			// CS5 Tagged Text reference:  http://help.adobe.com/en_US/indesign/cs/taggedtext/indesign_cs5_taggedtext.pdf
			// Mac ASCII codes reference:  http://ascii-table.com/ascii-extended-mac-list.php
			# endregion Resources
		};

		internal static bool Repair(string path)
		{
			// read file
			string data = String.Empty;
			try
			{
				data = FileIO.ReadText(path);
			}
			catch (Exception e)
			{
				Console.WriteLine(String.Format("Unable to load file {0}.\n{1}", path, e.ToString()));
				return false;
			}

			// replace items
			List<string> tags = FindTags(data);
			foreach (string tag in tags)
				if (ReplacementMap.Keys.Contains(tag))
					data = data.Replace(tag, ReplacementMap[tag]);
				else
					Console.WriteLine(String.Format("Unknown value found: {0}.", tag));

			// write file
			string new_path = AdjustPath(path, "_clean");
			try
			{
				FileIO.WriteText(new_path, data);
			}
			catch (Exception e)
			{
				Console.WriteLine(String.Format("Unable to write file {0}.\n{1}", new_path, e.ToString()));
				return false;
			}

			// if we got here, all went according to plan
			return true;
		}

		private static string AdjustPath(string path, string suffix)
		{
			string old_filename = Path.GetFileName(path);
			string new_filename = old_filename.Insert(old_filename.IndexOf(Path.GetExtension(path)), suffix);
			return path.Replace(old_filename, new_filename);
		}

		private static List<string> FindTags(string data)
		{
			List<string> list = new List<string>();
			Regex pattern = new Regex(@"(\<\\#([0-9]+)\>)");

			foreach (Match m in pattern.Matches(data))
			{
				if (m.Success)
				{
					string val = m.Groups[1].Value;
					if (!list.Contains(val))
					{
						Console.WriteLine(String.Format("Found {0}.", val));
						list.Add(val);
					}
				}
			}

			return list;
		}
	}
}