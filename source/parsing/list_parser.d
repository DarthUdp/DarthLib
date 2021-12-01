module parsing.list_parser;

import std.string;
import std.algorithm;
import std.array;

/// Parse a list from a file in the format:
/// ---
/// # comment
/// One item per line # you can have inline comments too
/// ---
/// Comment character can be customized as the second argument to constructor
/// It will automatically strip spaces in the processed lines
class ConfigList
{
	string[] items;
	this(string inBuffer, bool stripSpaces = true, string commentChar = "#")
	{
		// strip the inBuffer of any white space or spurious whitespace before processing
		inBuffer = strip(inBuffer);
		// Split with lineSplitter as a lazy range, and alloc only once
		// ignore any comment lines
		items = inBuffer.lineSplitter()
			.map!(line => strip(line))
			.filter!(line => !line.startsWith(commentChar))
			// taking care of inline comments
			.map!((line){
				if (auto split = line.findSplit(commentChar))
					return split[0];
				else
					return line;
			})
			.map!(line => stripSpaces ? strip(line) : line)
			.array();
	}

	bool canFind(string x)
	{
		return items.canFind(x);
	}
	
	string opIndex(ulong key)
	{
		return items[key];
	}

	ulong lenght()
	{
		return items.length;
	}

	unittest
	{
		auto testStr = "
		# first line comment
		/dev/sda # some comment
		# comment in random line
		/dev/sdb
		/dev/sdc
		/dev/sde
		";
		ConfigList cl = new ConfigList(testStr);
		assert(cl.items[0] == "/dev/sda", "inline comment not stripped");
		assert(cl.items[1] == "/dev/sdb", "second line wasn't parsed correctly");
	}
}
