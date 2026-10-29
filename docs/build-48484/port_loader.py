"""Experimental port of the hash-verified October 10 loader, NOT a team release."""
from pathlib import Path
import hashlib, json, re, struct

import argparse
parser = argparse.ArgumentParser(description="Experimental 48484 loader operand adaptation; does not prove runtime compatibility")
parser.add_argument('--donor', type=Path, required=True)
parser.add_argument('--game-assembly', type=Path, required=True)
parser.add_argument('--output-dir', type=Path, required=True)
args = parser.parse_args()
root = args.output_dir
root.mkdir(parents=True, exist_ok=True)
if (root/'version-48484-experimental.dll').exists():
    raise FileExistsError('Refusing to overwrite prior loader output')
donor = args.donor.read_bytes()
assert hashlib.sha256(donor).hexdigest() == '07bc012d0f0126fd32f536f3f99e103dff2af16b6e513086259c1fed7578e9ee'
game = args.game_assembly.read_bytes()
assert hashlib.sha256(game).hexdigest() == 'f812e85bed756e6f2cea6a5f8645f93fb2dc25908a2e78e1082ed88a50c280ea'
pe = struct.unpack_from('<I', game, 0x3c)[0]
section_table = pe + 24 + struct.unpack_from('<H', game, pe+20)[0]
sections = {}
for i in range(struct.unpack_from('<H', game, pe+6)[0]):
    offset = section_table + i*40
    name = game[offset:offset+8].rstrip(b'\0').decode()
    size, rva, raw_size, raw = struct.unpack_from('<4I', game, offset+8)
    sections[name] = (rva, raw, raw_size)
rva, raw, size = sections['.text']
report = {'donor': hashlib.sha256(donor).hexdigest(), 'sites': {}}
for name, pattern_rva, length in [('versiongate',0x6e90,20),('cipher2',0x6ee0,16),('fld_lea',0x6e50,16),('cipher1',0x6d60,29)]:
    values = struct.unpack_from('<'+'i'*length, donor, pattern_rva-0x6000+0x4c00)
    pattern = b''.join(b'.' if x < 0 else re.escape(bytes([x])) for x in values)
    matches = list(re.finditer(pattern, game[raw:raw+size], re.DOTALL))
    assert len(matches)==1, (name,len(matches))
    report['sites'][name] = hex(rva+matches[0].start())
rva, raw, size = sections['.rdata']
cave = game.find(b'\0'*128, raw, raw+size)
assert cave >= 0
report['sites']['scratch'] = hex(rva+cave-raw)
timestamp = struct.unpack_from('<I',game,pe+8)[0]
image_size = struct.unpack_from('<I',game,pe+0x50)[0]
assert donor[0x271d:0x272d] == bytes.fromhex('41 81 f9 e3 8d c6 6a 75 12 3d 00 a0 73 06 75 0b')
out = bytearray(donor)
struct.pack_into('<I',out,0x2720,timestamp)
struct.pack_into('<I',out,0x2727,image_size)
report['timestamp'] = hex(timestamp)
report['image_size'] = hex(image_size)
report['changed_byte_offsets'] = [hex(i) for i,(a,b) in enumerate(zip(donor,out)) if a!=b]
report['result_sha256'] = hashlib.sha256(out).hexdigest()
report['limitation'] = 'Unique pattern matches and guarded PE checks permit an experiment; they do not prove runtime compatibility.'
(root/'version-48484-experimental.dll').write_bytes(out)
(root/'loader-port-report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
