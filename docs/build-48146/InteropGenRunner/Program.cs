using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Security.Cryptography;
using System.Text;
using AssetRipper.Primitives;
using Cpp2IL.Core;
using Cpp2IL.Core.Api;
using Cpp2IL.Core.InstructionSets;
using Cpp2IL.Core.OutputFormats;
using Cpp2IL.Core.ProcessingLayers;
using Il2CppInterop.Common;
using Il2CppInterop.Generator;
using Il2CppInterop.Generator.Runners;
using LibCpp2IL;
using Microsoft.Extensions.Logging;
using SharpHDiffPatch.Core;

internal static class Program
{
    public static int Main(string[] args)
    {
        var swTotal = Stopwatch.StartNew();
        var liveGameDir = @"C:\Battlestate Games\Escape from Tarkov";
        var gameAssemblyPath = Path.Combine(liveGameDir, "GameAssembly.dll");
        var origMetadataPath = Path.Combine(liveGameDir, @"EscapeFromTarkov_Data\il2cpp_data\Metadata\global-metadata.dat");
        var deltaPath = @"c:\Users\james\source\repos\SP-Tushonka\launcher\SPTushonka.Core\SPT_Data\Launcher\Patches\SPT-core\EscapeFromTarkov_Data\il2cpp_data\Metadata\global-metadata.dat.delta";

        var workDir = @"C:\Users\james\source\repos\SP-Tushonka\.gamedir-48146";
        var bepInExDir = Path.Combine(workDir, "BepInEx");
        var coreDir = Path.Combine(bepInExDir, "core");
        var unityLibsDir = Path.Combine(bepInExDir, "unity-libs");
        var interopDir = Path.Combine(bepInExDir, "interop");
        var patchedMetadataPath = Path.Combine(workDir, "global-metadata.dat");

        Directory.CreateDirectory(coreDir);
        Directory.CreateDirectory(unityLibsDir);
        Directory.CreateDirectory(interopDir);

        Console.WriteLine("[1/4] Syncing BepInEx/core into " + coreDir);
        foreach (var f in Directory.GetFiles(@"c:\Users\james\source\repos\SP-Tushonka\bento\assets\il2cpp\BepInEx\core"))
        {
            File.Copy(f, Path.Combine(coreDir, Path.GetFileName(f)), true);
        }

        Console.WriteLine("[2/4] Applying global-metadata.dat.delta for 48146...");
        var patcher = new HDiffPatch();
        HDiffPatch.LogVerbosity = Verbosity.Quiet;
        patcher.Initialize(deltaPath);
        patcher.Patch(origMetadataPath, patchedMetadataPath, false);
        Console.WriteLine($"      Patched metadata size: {new FileInfo(patchedMetadataPath).Length:N0} bytes");

        Console.WriteLine("[3/4] Extracting Unity 2022.3.43 base libraries...");
        foreach (var f in Directory.GetFiles(unityLibsDir, "*.dll"))
        {
            File.Delete(f);
        }
        var unityZipPath = @"c:\Users\james\source\repos\SP-Tushonka\bento\assets\il2cpp\BepInEx\unity-libs\2022.3.43.zip";
        ZipFile.ExtractToDirectory(unityZipPath, unityLibsDir, true);

        Console.WriteLine("[4/4] Running Cpp2IL & Il2CppInteropGenerator on 48146...");
        InstructionSetRegistry.RegisterInstructionSet<X86InstructionSet>(DefaultInstructionSets.X86_32);
        InstructionSetRegistry.RegisterInstructionSet<X86InstructionSet>(DefaultInstructionSets.X86_64);
        LibCpp2IlBinaryRegistry.RegisterBuiltInBinarySupport();

        Cpp2IL.Core.Logging.Logger.InfoLog += (message, s) => Console.WriteLine($"[Cpp2IL:{s}] {message.Trim()}");
        Cpp2IL.Core.Logging.Logger.WarningLog += (message, s) => Console.WriteLine($"[Cpp2IL:WARN:{s}] {message.Trim()}");
        Cpp2IL.Core.Logging.Logger.ErrorLog += (message, s) => Console.WriteLine($"[Cpp2IL:ERR:{s}] {message.Trim()}");

        var unityVersion = new UnityVersion(2022, 3, 43, UnityVersionType.Final, 2);
        Cpp2IlApi.InitializeLibCpp2Il(gameAssemblyPath, patchedMetadataPath, unityVersion, false);

        var processingLayers = new List<Cpp2IlProcessingLayer> { new AttributeInjectorProcessingLayer() };
        foreach (var layer in processingLayers)
            layer.PreProcess(Cpp2IlApi.CurrentAppContext, processingLayers);
        foreach (var layer in processingLayers)
            layer.Process(Cpp2IlApi.CurrentAppContext);

        var assemblies = new AsmResolverDllOutputFormatDefault().BuildAssemblies(Cpp2IlApi.CurrentAppContext);
        LibCpp2IlMain.Reset();
        Cpp2IlApi.CurrentAppContext = null;

        Console.WriteLine($"      Cpp2IL built {assemblies.Count} dummy assemblies. Running Il2CppInteropGenerator...");
        foreach (var f in Directory.GetFiles(interopDir, "*.dll"))
        {
            File.Delete(f);
        }

        var opts = new GeneratorOptions
        {
            GameAssemblyPath = gameAssemblyPath,
            Source = assemblies,
            OutputDir = interopDir,
            UnityBaseLibsDir = unityLibsDir,
        };

        using var loggerFactory = LoggerFactory.Create(b => b.AddProvider(new SimpleConsoleLoggerProvider()).SetMinimumLevel(LogLevel.Information));
        var logger = loggerFactory.CreateLogger("Il2CppInteropGen");

        Il2CppInteropGenerator.Create(opts)
            .AddLogger(logger)
            .AddInteropAssemblyGenerator()
            .Run();

        // Also write assembly-hash.txt matching BepInEx Il2CppInteropManager.ComputeHash()
        var hash = ComputeHash(gameAssemblyPath, unityLibsDir);
        File.WriteAllText(Path.Combine(interopDir, "assembly-hash.txt"), hash);

        swTotal.Stop();
        var generatedDlls = Directory.GetFiles(interopDir, "*.dll").Length;
        Console.WriteLine($"Done! Generated {generatedDlls} interop DLLs (hash={hash}) in {swTotal.Elapsed}.");
        return 0;
    }

    private static string ComputeHash(string gameAssemblyPath, string unityBaseLibsDirectory)
    {
        using var md5 = MD5.Create();

        static void HashFile(ICryptoTransform hash, string file)
        {
            const int defaultCopyBufferSize = 81920;
            using var fs = File.OpenRead(file);
            var buffer = new byte[defaultCopyBufferSize];
            int read;
            while ((read = fs.Read(buffer)) > 0)
                hash.TransformBlock(buffer, 0, read, buffer, 0);
        }

        static void HashString(ICryptoTransform hash, string str)
        {
            var buffer = Encoding.UTF8.GetBytes(str);
            hash.TransformBlock(buffer, 0, buffer.Length, buffer, 0);
        }

        HashFile(md5, gameAssemblyPath);

        if (Directory.Exists(unityBaseLibsDirectory))
        {
            foreach (var file in Directory.EnumerateFiles(unityBaseLibsDirectory, "*.dll", SearchOption.TopDirectoryOnly))
            {
                HashString(md5, Path.GetFileName(file));
                HashFile(md5, file);
            }
        }

        HashString(md5, typeof(InteropAssemblyGenerator).Assembly.GetName().Version.ToString());
        HashString(md5, typeof(Cpp2IlApi).Assembly.GetName().Version.ToString());
        HashString(md5, typeof(InteropAssemblyGenerator).Module.ModuleVersionId.ToString());
        HashString(md5, typeof(Cpp2IlApi).Module.ModuleVersionId.ToString());

        md5.TransformFinalBlock(Array.Empty<byte>(), 0, 0);

        var sb = new StringBuilder(md5.Hash.Length * 2);
        foreach (var b in md5.Hash)
            sb.Append(b.ToString("x2"));
        return sb.ToString();
    }

    private sealed class SimpleConsoleLoggerProvider : ILoggerProvider
    {
        public ILogger CreateLogger(string categoryName) => new SimpleConsoleLogger(categoryName);
        public void Dispose() { }
    }

    private sealed class SimpleConsoleLogger(string category) : ILogger
    {
        public IDisposable BeginScope<TState>(TState state) where TState : notnull => null;
        public bool IsEnabled(LogLevel logLevel) => logLevel >= LogLevel.Information;
        public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
        {
            if (!IsEnabled(logLevel)) return;
            Console.WriteLine($"[{category}:{logLevel}] {formatter(state, exception)}");
            if (exception != null) Console.WriteLine(exception);
        }
    }
}
