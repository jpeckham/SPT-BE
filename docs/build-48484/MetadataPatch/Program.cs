using System;
using System.IO;
using SharpHDiffPatch.Core;
if (args.Length != 3) throw new ArgumentException("Expected original, delta, output paths");
if (File.Exists(args[2])) throw new IOException("Refusing to overwrite output");
var patch = new HDiffPatch();
patch.Initialize(args[1]);
patch.Patch(args[0], args[2], false);
Console.WriteLine($"Patched metadata: {new FileInfo(args[2]).Length} bytes");
