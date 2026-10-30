using System.Text.Json;
using Greed.Models;

if (args.Length != 1) throw new ArgumentException("Supply a NEW output preset JSON path.");
var config = new MainClass.MainConfig { PresetNotes = "Local BE installation baseline: all modification sections disabled. Choose settings in Greed, then Save and Apply." };
var gates = new[] { "Items", "Hideout", "Traders", "Loot", "Player", "Raids", "Fleamarket", "Services", "Quests", "CSM", "Scav", "Bots", "PMC", "Custom", "Prestige" };
foreach (var sectionName in gates)
{
    var section = typeof(MainClass.MainConfig).GetProperty(sectionName)!.GetValue(config)!;
    var gate = section.GetType().GetProperty("Enable" + sectionName);
    if (gate == null || gate.GetValue(section) is not false)
        throw new InvalidOperationException($"Unexpected enabled/missing gate for {sectionName}");
}
var text = JsonSerializer.Serialize(config, new JsonSerializerOptions { WriteIndented = true });
var roundtrip = JsonSerializer.Deserialize<MainClass.MainConfig>(text)!;
if (JsonSerializer.Serialize(config) != JsonSerializer.Serialize(roundtrip))
    throw new InvalidOperationException("Preset JSON roundtrip failed.");
using var file = new FileStream(args[0], FileMode.CreateNew);
using var writer = new StreamWriter(file);
writer.Write(text);
Console.WriteLine($"PASS: {gates.Length} sections disabled; typed JSON roundtrip matches. Wrote {args[0]}");
