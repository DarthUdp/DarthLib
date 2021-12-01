module parsing.ini_parser;

import std.string;
import std.algorithm;
import std.array;

/// Parse a list of key value pairs from a file in the format (aka ini file):
/// ```ini
/// # comment
/// some_key = some_value
/// # also supports sections, sections cna be named anything
/// [some_section]
/// # sections namespace keys to access the follwing key access the key "some_section.some_key"
/// some_key = some value
/// ```
/// Comment, key value delimiter and space stripping can be configured with
/// constructor parameters this parser will not accept duplicate keys by default
/// to allow duplicate keys pass allowOverride to the constructor, it will enforce
/// the last instance of a key is the final value for that key.
class IniParser
{
	string[string] items;
	this(
		string inBuffer,
		bool paseSections = false,
		bool stripSpaces = true,
		bool allowOverride = false,
		string commentChar = "#",
		string keyValueSep = "="
	)
	{
		auto currentSection = "";
		// strip the inBuffer of any white space or spurious whitespace before processing
		inBuffer = strip(inBuffer);
		// Split with lineSplitter as a lazy range, and alloc only once
		// ignore any comment lines
		auto lines = inBuffer.lineSplitter()
			.map!(line => strip(line))
			.filter!(line => !line.startsWith(commentChar))
			.map!((line) {
				// taking care of inline comments
				if (auto split = line.findSplit(commentChar))
					return split[0];
				else
					return line;
			})
			.map!(line => strip(line))
			.array();

		foreach (line; lines)
		{
			// We will parse sections for namespacing purposes
			if (line.startsWith("[") && paseSections)
			{
				if (auto split = line.findSplit("]"))
					currentSection = strip(split[0][1 .. $]) ~ ".";
				else
					throw new Exception(format("Malformed section line: %s", line));
				continue;
			}

			if (auto split = line.findSplit(keyValueSep))
			{
				string key = currentSection ~ strip(split[0]);
				if (key in items && !allowOverride)
					throw new Exception(format("key %s already seen", line));
				// split any
				if (stripSpaces)
					items[key] = strip(split[2]);
				else
					items[key] = split[2];
			}
			else
				throw new Exception(format("Malformed line: %s", line));
		}
	}

	string opIndex(string key)
	{
		return items[key];
	}

	ulong lenght()
	{
		return items.length;
	}

	unittest
	{
		import std.exception;

		auto testStr = "
		# some comment
		mainDrive = /dev/sda # some inline comment
		secondaryDrive = /dev/sdb
		";
		auto testStrSections = "
		# some comment
		[scsi]
		mainDrive = /dev/sda # some inline comment
		[ sata ]
		mainDrive = /dev/sdb
		";
		auto testStrInvalid = "
		# some comment
		mainDrive = /dev/sda # some inline comment
		secondaryDrive = /dev/sdb
		/dev/sdc
		";
		IniParser cl = new IniParser(testStr);
		assert(cl["mainDrive"] == "/dev/sda", "inline comment not stripped");
		assert(cl["secondaryDrive"] == "/dev/sdb", "second line wasn't parsed correctly");
		assertThrown(new IniParser(testStrInvalid));
		IniParser cls = new IniParser(testStrSections, true);
		assert(cls["scsi.mainDrive"] == "/dev/sda", "inline comment not stripped");
		assert(cls["sata.mainDrive"] == "/dev/sdb", "second line wasn't parsed correctly");
	}
}
