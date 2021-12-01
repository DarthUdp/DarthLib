module parsing.data_sizes;

import std.algorithm;
import std.string;
import std.conv;
import std.uni;

class DataSizeParsing
{
	private ulong[string] unitsTableBin;
	private ulong[string] unitsTableDec;
	this()
	{
		// Init lookup tables for division and multiplication sizes
		unitsTableBin = [
			"b": 1,
			"kib": 1024,
			"mib": 1_048_576,
			"gib": 1_073_741_824,
			"tib": 1_099_511_627_776,
			"pib": 1_125_899_906_842_620,
		];

		unitsTableDec = [
			"b": 1,
			"kb": 1000,
			"mb": 1_000_000,
			"gb": 1_000_000_000,
			"tb": 1_000_000_000_000,
			"pb": 1_000_000_000_000_000
		];
	}

	/// Parse a string i.e 10MiB to a value in bytes, supported suffixes are B, KiB..PiB and KB..PB
	/// Params:
	///   input = string in the form ie `10MiB`
	/// Returns: ulong with the size in bytes based on the suffix
	ulong fromHumanToBytes(string input)
	{
		string rawNum;
		string suffix;

		foreach (i, c; input)
		{
			// if we have anything in the suffix yet ignore the rest of the string
			if (c.isNumber && suffix.length == 0)
				rawNum ~= c;
			else
				suffix ~= c;
		}
		suffix = suffix.toLower;
		// Don't bother with lookup if the suffix is too large to exist in the table
		if (suffix.length <= 3 && suffix in unitsTableBin)
			return parse!ulong(rawNum) * unitsTableBin[suffix];
		else if(suffix.length <= 2 && suffix in unitsTableDec)
			return parse!ulong(rawNum) * unitsTableDec[suffix];
		else
			throw new Exception(format("Invalid suffix %s", suffix));
	}

	unittest
	{
		DataSizeParsing dsp = new DataSizeParsing;

		assert(dsp.fromHumanToBytes("100MiB") == 104_857_600);
	}
}
