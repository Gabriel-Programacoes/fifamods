"""Read-only inventory: hashes and ZIP metadata. Does not launch or extract tools."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def digest(path):
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def metadata(data):
    # PE version resource strings; evidence only, not a PE validation/parser.
    text = data.decode('utf-16-le', errors='ignore')
    result = {}
    for key in ('FileVersion', 'ProductVersion'):
        match = re.search(key + r'\x00+(\d[\d., ]+)', text)
        result[key] = match.group(1) if match else None
    return result


def main():
    manager = ROOT / 'FrostyModManager' / 'FrostyModManager'
    editor = ROOT / 'FrostyToolsuite-FIFA17editionv3fixed' / 'FrostyToolsuite-FIFA17editionv3fixed'
    for path in [ROOT / 'FIFA 17' / 'FIFA17.exe', ROOT / 'FIFA 17' / 'stp-fifa17.exe',
                 editor / 'FrostyEditor.exe', editor / 'FrostySdk.dll',
                 editor / 'Profiles' / 'Fifa17SDK.dll', manager / 'FrostyModManager.exe',
                 manager / 'FrostySdk.dll', manager / 'Profiles' / 'Fifa17SDK.dll']:
        if path.is_file():
            print(json.dumps({'file': str(path.relative_to(ROOT)), 'bytes': path.stat().st_size,
                              'sha256': digest(path)}, ensure_ascii=True))
    for path in ROOT.glob('FrostyToolsuite*/**/*.zip'):
        with zipfile.ZipFile(path) as archive:
            print(json.dumps({'archive': str(path.relative_to(ROOT)), 'bytes': path.stat().st_size,
                              'sha256': digest(path), 'entries': len(archive.infolist()),
                              'uncompressed_bytes': sum(x.file_size for x in archive.infolist())}))
            for name in archive.namelist():
                if name.endswith(('FrostyEditor.exe', 'FrostyModManager.exe', 'FrostySdk.dll',
                                  'Fifa17SDK.dll', 'FrostyCmd.exe')):
                    data = archive.read(name)
                    print(json.dumps({'member': name, 'sha256': hashlib.sha256(data).hexdigest(),
                                      **metadata(data)}))
                    local = manager / Path(name).name
                    if name.endswith('Fifa17SDK.dll'):
                        local = manager / 'Profiles' / 'Fifa17SDK.dll'
                    if local.is_file():
                        print(json.dumps({'compare_local': str(local.relative_to(ROOT)),
                                          'equal': digest(local) == hashlib.sha256(data).hexdigest()}))
                if name.endswith(('.config', 'README.md')):
                    print(json.dumps({'text_member': name,
                                      'text': archive.read(name).decode('utf-8', errors='replace')}))
                if '/Plugins/' in name and name.endswith('.dll'):
                    print(json.dumps({'plugin': name}))
    files = [p for p in (ROOT / 'FIFA 17').rglob('*') if p.is_file()]
    print(json.dumps({'game_files': len(files), 'game_bytes': sum(p.stat().st_size for p in files)}))


if __name__ == '__main__':
    main()
