"""Read-only, sample-specific APT inspection. No writer or bytecode execution.

Layout reference consulted 2026-10-14:
https://github.com/LibreSAGE/AptTools/blob/main/crates/apt/src/parse.rs
https://github.com/LibreSAGE/AptTools/blob/main/crates/apt/src/constfile.rs
https://github.com/LibreSAGE/AptTools/blob/main/crates/apt/src/io.rs
This partial reader is not a compatibility claim for AptTools or other samples.
Frosty's DAT member carries Apt Data; its APT member carries Apt1 constants.
"""
from pathlib import Path
import hashlib
import json
import math
import struct

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    'leaguestats.APT': 'a2feb529aaca898259dfd1664e5602c7d4371f24cd1a383f1bf51f50faea121a',
    'leaguestats.DAT': 'a35474d5834ac3be04a2a25622da52123d0f20536af1f0972a5d0114128dc58b',
}


class Cursor:
    def __init__(self, data, offset=0):
        self.data, self.pos = data, offset

    def read(self, fmt):
        size = struct.calcsize('<' + fmt)
        if self.pos < 0 or self.pos + size > len(self.data):
            raise ValueError(f'Out-of-bounds read at {self.pos}, size {size}')
        result = struct.unpack_from('<' + fmt, self.data, self.pos)
        self.pos += size
        return result[0] if len(result) == 1 else list(result)

    def ptr(self):
        self.pos = (self.pos + 7) & ~7
        return self.read('Q')

    def string(self, offset):
        if not offset:
            return ''
        if not 0 <= offset < len(self.data):
            raise ValueError(f'Invalid string offset {offset}')
        end = self.data.find(b'\0', offset)
        if end == -1:
            raise ValueError(f'Unterminated string at {offset}')
        return self.data[offset:end].decode('latin-1')


def bounded(value, limit, label):
    if not 0 <= value <= limit:
        raise ValueError(f'Invalid {label}: {value}')
    return value


def character(data, offset):
    c = Cursor(data, offset)
    kind = c.read('i')
    magic = c.ptr()
    if magic != 0x09876543:
        raise ValueError(f'Unexpected character marker at {offset}: {magic:#x}')
    c.read('I')  # decoupled word; not interpreted here
    c.ptr()  # runtime-only pointer slot
    return kind, c


def frames(data, offset, count, owner):
    result = []
    fc = Cursor(data, offset)
    for frame in range(bounded(count, 10000, 'frame count')):
        fc.pos = (fc.pos + 7) & ~7
        n_controls = bounded(fc.read('i'), 10000, 'control count')
        pc = Cursor(data, fc.ptr())
        for _ in range(n_controls):
            control_offset = pc.ptr()
            c = Cursor(data, control_offset)
            kind = c.read('i')
            if kind not in (3, 9):
                continue  # other controls/bytecode deliberately not decoded
            c.pos = (c.pos + 7) & ~7
            flags, depth, char_id = c.read('3i')
            matrix_offset = c.pos
            matrix = c.read('6f')
            if not all(math.isfinite(v) for v in matrix):
                raise ValueError('Nonfinite placement matrix')
            c.read('2I')
            c.read('f')
            name_offset = c.ptr()
            name = c.string(name_offset) if flags & 0x20 else ''
            if name:
                result.append({'owner_character': owner, 'frame': frame,
                               'control_offset': control_offset, 'name': name,
                               'character_id': char_id if flags & 2 else None,
                               'depth': depth, 'flags': flags,
                               'matrix_offset': matrix_offset if flags & 4 else None,
                               'matrix_a_b_c_d_tx_ty': matrix if flags & 4 else None})
    return result


def inspect(apt, dat):
    if not apt.startswith(b'Apt1') or dat[:16] != b'Apt Data:1:7:8\x1a\0':
        raise ValueError('Unsupported headers; this reader only accepts this 8-byte variant')
    cc = Cursor(apt, 20)
    root_offset = cc.ptr()
    n_constants = bounded(cc.read('i'), 10000, 'constant count')
    table_offset = cc.ptr()
    # Bounds for the constant table, without claiming to decode action streams.
    if table_offset + n_constants * 16 > len(apt):
        raise ValueError('Constant table exceeds input')
    kind, c = character(dat, root_offset)
    if kind != 9:
        raise ValueError(f'Expected root animation, got {kind}')
    n_frames, frame_offset = c.read('i'), c.ptr()
    c.ptr()
    n_chars = bounded(c.read('i'), 10000, 'character count')
    char_table = c.ptr()
    stage_width, stage_height, milliseconds = c.read('3I')
    n_imports, import_offset = c.read('i'), c.ptr()
    n_exports, export_offset = c.read('i'), c.ptr()
    imports = []
    ic = Cursor(dat, import_offset)
    for _ in range(bounded(n_imports, 10000, 'import count')):
        movie, name = ic.string(ic.ptr()), ic.string(ic.ptr())
        char_id = ic.read('i')
        ic.ptr()
        imports.append({'movie': movie, 'name': name, 'character_id': char_id})
    exports = []
    ec = Cursor(dat, export_offset)
    for _ in range(bounded(n_exports, 10000, 'export count')):
        exports.append({'name': ec.string(ec.ptr()), 'character_id': ec.read('i')})
    texts, placements = [], frames(dat, frame_offset, n_frames, 'root')
    pc = Cursor(dat, char_table)
    for char_id in range(n_chars):
        off = pc.ptr()
        if off == 0 or off == root_offset:
            continue
        kind, c = character(dat, off)
        if kind == 2:
            bounds_offset = c.pos
            bounds = c.read('4f')
            font_id, alignment, color, height = c.read('i'), c.read('i'), c.read('I'), c.read('f')
            c.read('3i')
            initial_text, variable = c.string(c.ptr()), c.string(c.ptr())
            texts.append({'character_id': char_id, 'offset': off,
                          'bounds_offset': bounds_offset, 'bounds_left_top_right_bottom': bounds,
                          'font_id': font_id, 'alignment': alignment,
                          'font_height': height, 'initial_text': initial_text, 'variable': variable})
        elif kind == 5:
            n, ptr = c.read('i'), c.ptr()
            placements.extend(frames(dat, ptr, n, char_id))
    return {'interpretation': 'partial, read-only; no action decoding or write support',
            'root_offset': root_offset, 'constant_count': n_constants,
            'constant_table_offset': table_offset, 'character_count': n_chars,
            'root_frames': n_frames, 'stage_width': stage_width, 'stage_height': stage_height,
            'milliseconds_per_frame': milliseconds, 'imports': imports,
            'exports': exports, 'text_characters': texts, 'named_placements': placements}


def main():
    blobs = {}
    for name, expected in EXPECTED.items():
        data = (ROOT / 'work' / 'original' / name).read_bytes()
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError(f'Unexpected input hash: {name}')
        blobs[name] = data
    print(json.dumps(inspect(blobs['leaguestats.APT'], blobs['leaguestats.DAT']),
                     indent=2, ensure_ascii=True, allow_nan=False))


if __name__ == '__main__':
    main()
