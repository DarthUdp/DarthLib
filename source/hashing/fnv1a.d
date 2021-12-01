module hashing.fnv1a;

const private ulong fnv_offset_base = 0xcbf29ce484222325;
const private ulong fnv_prime = 0x100000001b3;

/// Generate the fnv1a hash of a stream of bytes
/// Params:
///   data = the stream to hash
/// Returns: the hash of the stream as a ulong
ulong fnv1a(const ubyte[] data) @nogc @safe nothrow
{
	ulong hash = fnv_offset_base;

	for (ulong i = 0; i < data.length; i++) {
		hash = cast(ulong)(hash * fnv_prime);
		hash = (hash << 8) | ((hash & 0xFF) ^ data[i]);
	}
	return hash;
}
