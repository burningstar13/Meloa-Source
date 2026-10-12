extends RefCounted














const MAX_FRAMES: = 600


const PIX_BUDGET: = 20000000


const MAX_SHEET: = 2048
const MIN_FPS: = 1.0
const MAX_FPS: = 50.0
const WEBP_QUALITY: = 0.85




static func decode(bytes: PackedByteArray) -> Dictionary:
	var n: = bytes.size()
	if n < 13 or bytes.slice(0, 3).get_string_from_ascii() != "GIF":
		return {"ok": false, "error": "not a GIF file"}
	var w: = bytes[6] | (bytes[7] << 8)
	var h: = bytes[8] | (bytes[9] << 8)
	if w <= 0 or h <= 0 or w > 4096 or h > 4096:
		return {"ok": false, "error": "unsupported GIF size %dx%d" % [w, h]}
	var packed: = bytes[10]
	var bg_index: = bytes[11]
	var pos: = 13
	var gct: = PackedByteArray()
	if packed & 128:
		var size: = 3 * (1 << ((packed & 7) + 1))
		gct = bytes.slice(pos, pos + size)
		pos += size
	var frames: Array = []
	var delays: Array = []
	var canvas: = PackedByteArray()
	canvas.resize(w * h * 4)
	var prev_canvas: = PackedByteArray()
	var prev_disposal: = 0
	var prev_rect: = Rect2i()

	var delay: = 0.1
	var transparent: = -1
	var disposal: = 0
	while pos < n:
		var b: = bytes[pos]
		pos += 1
		if b == 59:
			break
		elif b == 33:
			if pos >= n:
				break
			var label: = bytes[pos]
			pos += 1
			if label == 249 and pos + 5 <= n:
				var bs: = bytes[pos]
				var pk: = bytes[pos + 1]
				disposal = (pk >> 2) & 7
				var d: = bytes[pos + 2] | (bytes[pos + 3] << 8)
				delay = float(d) / 100.0
				if delay < 0.02:
					delay = 0.1
				transparent = bytes[pos + 4] if (pk & 1) else -1
				pos += bs + 1

				while pos < n and bytes[pos] != 0:
					pos += bytes[pos] + 1
				pos += 1
			else:

				while pos < n and bytes[pos] != 0:
					pos += bytes[pos] + 1
				pos += 1
		elif b == 44:
			if pos + 9 > n:
				break
			var ix: = bytes[pos] | (bytes[pos + 1] << 8)
			var iy: = bytes[pos + 2] | (bytes[pos + 3] << 8)
			var iw: = bytes[pos + 4] | (bytes[pos + 5] << 8)
			var ih: = bytes[pos + 6] | (bytes[pos + 7] << 8)
			var ipk: = bytes[pos + 8]
			pos += 9
			var ct: = gct
			if ipk & 128:
				var lsize: = 3 * (1 << ((ipk & 7) + 1))
				ct = bytes.slice(pos, pos + lsize)
				pos += lsize
			var interlaced: = (ipk & 64) != 0
			if pos >= n:
				break
			var mcs: = bytes[pos]
			pos += 1

			var data: = PackedByteArray()
			while pos < n and bytes[pos] != 0:
				var sz: = bytes[pos]
				data.append_array(bytes.slice(pos + 1, pos + 1 + sz))
				pos += sz + 1
			pos += 1
			if iw <= 0 or ih <= 0 or ct.is_empty():
				continue

			iw = mini(iw, w - ix)
			ih = mini(ih, h - iy)
			if iw <= 0 or ih <= 0:
				continue
			var idx: = _lzw(data, mcs, iw * ih)

			if prev_disposal == 2:
				_clear_rect(canvas, w, prev_rect)
			elif prev_disposal == 3 and not prev_canvas.is_empty():
				canvas = prev_canvas.duplicate()
			if disposal == 3:
				prev_canvas = canvas.duplicate()
			_paint(canvas, w, ix, iy, iw, ih, idx, ct, transparent, interlaced)
			frames.append(Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, canvas))
			delays.append(delay)
			prev_disposal = disposal
			prev_rect = Rect2i(ix, iy, iw, ih)

			delay = 0.1
			transparent = -1
			disposal = 0
			if frames.size() >= MAX_FRAMES:
				break
		else:
			break
	if frames.is_empty():
		return {"ok": false, "error": "no frame could be decoded"}
	return {"ok": true, "w": w, "h": h, "frames": frames, "delays": delays, 
		"bg": bg_index}


static func _clear_rect(canvas: PackedByteArray, w: int, r: Rect2i) -> void :
	for y in range(r.position.y, r.end.y):
		var o: = (y * w + r.position.x) * 4
		for x in r.size.x:
			canvas[o] = 0
			canvas[o + 1] = 0
			canvas[o + 2] = 0
			canvas[o + 3] = 0
			o += 4




static func _paint(canvas: PackedByteArray, w: int, ix: int, iy: int, iw: int, 
		ih: int, idx: PackedByteArray, ct: PackedByteArray, transparent: int, 
		interlaced: bool) -> void :
	var ncol: = floori(float(ct.size()) / 3.0)
	var rows: = PackedInt32Array()
	rows.resize(ih)
	if interlaced:
		var r: = 0
		for pass_def in [[0, 8], [4, 8], [2, 4], [1, 2]]:
			var y: int = pass_def[0]
			while y < ih:
				rows[r] = y
				r += 1
				y += pass_def[1]
	else:
		for y in ih:
			rows[y] = y
	var src: = 0
	for r in ih:
		var y: int = rows[r]
		var o: = ((iy + y) * w + ix) * 4
		for x in iw:
			var i: = idx[src]
			src += 1
			if i == transparent or i >= ncol:
				o += 4
				continue
			var c: = i * 3
			canvas[o] = ct[c]
			canvas[o + 1] = ct[c + 1]
			canvas[o + 2] = ct[c + 2]
			canvas[o + 3] = 255
			o += 4





static func _lzw(data: PackedByteArray, mcs: int, npix: int) -> PackedByteArray:
	var out: = PackedByteArray()
	out.resize(npix)
	if mcs < 2 or mcs > 8:
		return out
	var clear: = 1 << mcs
	var eoi: = clear + 1
	var prefix: = PackedInt32Array()
	prefix.resize(4096)
	var suffix: = PackedByteArray()
	suffix.resize(4096)
	var firsts: = PackedByteArray()
	firsts.resize(4096)
	var lens: = PackedInt32Array()
	lens.resize(4096)
	for i in clear:
		prefix[i] = -1
		suffix[i] = i
		firsts[i] = i
		lens[i] = 1
	var code_size: = mcs + 1
	var mask: = (1 << code_size) - 1
	var next: = eoi + 1
	var prev: = -1
	var bitbuf: = 0
	var bits: = 0
	var pos: = 0
	var n: = data.size()
	var op: = 0
	while op < npix:
		while bits < code_size and pos < n:
			bitbuf |= data[pos] << bits
			bits += 8
			pos += 1
		if bits < code_size:
			break
		var code: = bitbuf & mask
		bitbuf >>= code_size
		bits -= code_size
		if code == clear:
			code_size = mcs + 1
			mask = (1 << code_size) - 1
			next = eoi + 1
			prev = -1
			continue
		if code == eoi:
			break
		if prev == -1:
			if code >= clear:
				break
			out[op] = suffix[code]
			op += 1
			prev = code
			continue
		var length: int
		var first: int
		if code < next:
			length = lens[code]
			first = firsts[code]

			var k: = code
			var j: = op + length - 1
			while k >= 0 and j >= op:
				if j < npix:
					out[j] = suffix[k]
				j -= 1
				k = prefix[k]
		elif code == next:

			length = lens[prev] + 1
			first = firsts[prev]
			var j2: = op + length - 1
			if j2 < npix:
				out[j2] = first
			var k2: = prev
			j2 -= 1
			while k2 >= 0 and j2 >= op:
				if j2 < npix:
					out[j2] = suffix[k2]
				j2 -= 1
				k2 = prefix[k2]
		else:
			break
		op += length
		if next < 4096:
			prefix[next] = prev
			suffix[next] = first
			firsts[next] = firsts[prev]
			lens[next] = lens[prev] + 1
			next += 1
			if next > mask and code_size < 12:
				code_size += 1
				mask = (1 << code_size) - 1
		prev = code
	return out







static func import_to_sheet(bytes: PackedByteArray, out_path: String) -> Dictionary:
	var dec: = decode(bytes)
	if not bool(dec.get("ok", false)):
		return dec
	var frames: Array = dec.frames
	var delays: Array = dec.delays
	if frames.size() > MAX_FRAMES:
		frames = frames.slice(0, MAX_FRAMES)
		delays = delays.slice(0, MAX_FRAMES)
	var n: = frames.size()
	var w: int = dec.w
	var h: int = dec.h


	var s: = minf(1.0, sqrt(float(PIX_BUDGET) / float(n * w * h)))
	s = minf(s, minf(float(MAX_SHEET) / float(w), float(MAX_SHEET) / float(h)))
	var fw: = maxi(int(floor(w * s)), 1)
	var fh: = maxi(int(floor(h * s)), 1)
	var cols: = maxi(int(floor(float(MAX_SHEET) / float(fw))), 1)
	var rows_max: = maxi(int(floor(float(MAX_SHEET) / float(fh))), 1)
	var per: = cols * rows_max
	var sheets: = int(ceil(float(n) / float(per)))
	var base: = out_path.get_basename()
	var ext: = out_path.get_extension().to_lower()
	var files: Array = []
	for si in sheets:
		var i0: = si * per
		var cnt: = mini(per, n - i0)
		var rows: = int(ceil(float(cnt) / float(cols)))
		var sheet: = Image.create(cols * fw, rows * fh, false, Image.FORMAT_RGBA8)
		for j in cnt:
			var img: Image = frames[i0 + j]
			if s < 1.0:
				img = img.duplicate()
				img.resize(fw, fh, Image.INTERPOLATE_BILINEAR)
			sheet.blit_rect(img, Rect2i(0, 0, fw, fh), 
				Vector2i((j % cols) * fw, floori(float(j) / float(cols)) * fh))
		var path: = out_path if si == 0 else "%s_%d.%s" % [base, si + 1, ext]


		var err: = sheet.save_webp(path, true, WEBP_QUALITY) if ext == "webp"\
		else sheet.save_png(path)
		if err != OK:
			return {"ok": false, "error": "could not write the sprite sheet"}
		files.append(path.get_file())
	var total: = 0.0
	var uniform: = true
	for d in delays:
		total += float(d)
		if absf(float(d) - float(delays[0])) > 0.0015:
			uniform = false
	var out: = {"ok": true, "frames": n, "cols": cols, "per": per, "sheets": sheets, 
		"cw": fw, "ch": fh, "duration": snappedf(total, 0.001), "files": files, 
		"scale": s}
	if uniform:
		out["fps"] = snappedf(1.0 / maxf(float(delays[0]), 0.001), 0.01)
	else:
		var ds: Array = []
		for d in delays:
			ds.append(snappedf(float(d), 0.001))
		out["delays"] = ds
	return out
