local common = require("./common")
local compareTo = common.compareTo

local arr = {}
function arr.__call<T>(_, ...: T): arr<T>
	local result = table.pack(...)
	result.__arr__ = true
	setmetatable(result, arr)
	return result :: arr<T>
end
arr.__index = arr
setmetatable(arr, arr)
function arr.sized<T>(length: number, fill: T): arr<T>
	local result = table.create(length)
	result.n = length
	arr.__arr__ = true
	if fill ~= nil then
		for idx = 1, length do
			arr[idx] = fill
		end
	end
	setmetatable(result, arr)
	return result
end
local arr_sized = arr.sized

function arr.unpack<T>(self: arr<T>): ...T
	return table.unpack(self, 1, self.n)
end

function arr.push<T>(self: arr<T>, ...: T): arr<T>
	local src = table.pack(...)
	local src_len = src.n
	if src_len == 0 then
		return self
	elseif src_len == 1 then
		local arr_len = self.n + 1
		self[arr_len] = ...
		self.n = arr_len
		return self
	end
	local arr_len = self.n
	self.n = arr_len + src_len
	table.move(src, 1, src_len, arr_len + 1, self)
	return self
end
local arr_push = arr.push

function arr.range(arr_len: number, start: number?, last: number?): (number, number)
	return if start == nil then 1 elseif start < 0 then (arr_len + start + 1) else start,
		if last == nil then arr.n elseif last < 0 then (arr_len + last + 1) else last
end
local arr_range = arr.range

function arr.insert<T>(self: arr<T>, at: number, ...: T): arr<T>
	local src = table.pack(...)
	local src_len = src.n
	if src_len == 0 then
		return self
	end
	local arr_len = self.n
	table.move(self, at, arr_len, at + src_len)
	table.move(src, 1, src_len, at, self)
	self.n = arr_len + src_len
	return self
end

function arr.consume<T>(self: arr<T>, fn: CallBack<T, any>): arr<T>
	for idx = 1, self.n do
		fn(self[idx], idx, self)
	end
	table.clear(self)
	self.n = 0
	return self
end

function arr.clear<T>(self: arr<T>): arr<T>
	table.clear(self)
	self.n = 0
	return self
end

function arr.offer() end

function arr.reverse(arr, start, last, to, to_start) end
function arr.reverse_inplace(arr, start, last) end

function arr.rotate(arr, shift, start, last, to) end
function arr.rotate_inplace(arr, shift, start, last) end

function arr.sorted(arr, comp) end

function arr.merge<T>(...: arr<T>): arr<T>
	local len = select("#", ...)
	local total = 0
	local result = {}
	for idx = 1, len do
		local item = select(idx, ...)
		local item_len = item.n
		if item_len == 0 then
			continue
		elseif item_len == 1 then
			result[total + 1] = item[1]
		else
			table.move(item, 1, item_len, total + 1, result)
		end
		total += item_len
	end
	result.n = total
	return result
end
function arr.merge_inplace<T>(self: arr<T>, ...: arr<T>): arr<T>
	local len = select("#", ...)
	local total = self.n
	for idx = 1, len do
		local item = select(idx, ...)
		local item_len = item.n
		if item_len == 0 then
			continue
		elseif item_len == 1 then
			self[total + 1] = item[1]
		else
			table.move(item, 1, item_len, total + 1, self)
		end
		total += item_len
	end
	self.n = total
	return self
end

function arr.flatmap<T, G>(self: arr<T>, fn: CallBackVar<T, G>, to: arr<G>?): arr<G>
	to = to or arr_sized(0)
	for i = 1, self.n do
		arr_push(to, fn(self[i], i, self))
	end
	return to :: arr<G>
end
function arr.flatmap_inplace<T, G>(self: arr<T>, fn: CallBackVar<T, G>)
	local idx = 1
	local old_len = self.n
	local len = old_len
	local last
	local last_len
	local offset = 0 -- should be uninited
	while idx <= len do
		last = table.pack(fn(self[idx], idx, self))
		last_len = last.n
		if last_len == 0 then
			offset += 1
			idx += 1
			continue
		elseif last_len == 1 then
			self[idx - offset] = last[1]
			idx += 1
			continue
		end
		table.move(self, idx + 1, len, idx + last_len - offset)
		table.move(last, 1, last_len, idx - offset, self)
		len += last_len - 1 - offset
		idx += last_len - offset
		offset = 0
	end
	self.n = len
	for i = len + 1, old_len do
		self[i] = nil
	end
	return self
end

function arr.map<T, G>(self: arr<T>, fn: CallBack<T, G>, to: arr<G>?): arr<G>
	local offset = if to then to.n else 0
	local arr_len = self.n
	to = to or arr_sized(arr_len)
	for idx = 1, arr_len do
		(to :: arr<G>)[offset + idx] = fn(self[idx], idx, self)
	end
	return to :: arr<G>
end
function arr.map_inplace<T, G>(self: arr<T>, fn: CallBack<T, G>): arr<G>
	local idx = 1
	local old_len = self.n
	local len = old_len
	local last
	local last_len
	local offset = 0 -- should be uninited
	while idx <= len do
		last = table.pack(fn(self[idx], idx, self))
		last_len = last.n
		if last_len == 0 then
			offset += 1
			idx += 1
			continue
		elseif last_len == 1 then
			self[idx - offset] = last[1]
			idx += 1
			continue
		end
		table.move(self, idx + 1, len, idx + last_len - offset)
		table.move(last, 1, last_len, idx - offset, self)
		len += last_len - 1 - offset
		idx += last_len - offset
		offset = 0
	end
	self.n = len
	for i = len + 1, old_len do
		self[i] = nil
	end
	return (self :: unknown) :: arr<G>
end

type CallBack<T, Ret> = (element: T, index: number, arr: arr<T>) -> Ret
type CallBackVar<T, Ret> = (element: T, index: number, arr: arr<T>) -> ...Ret
type CallBackWithUserdata<T, Ret, Userdata> = (element: T, index: number, arr: arr<T>, userdata: Userdata) -> Ret

--[=[
    Filter and save elements to another arr with function
]=]
function arr.filter<T>(self: arr<T>, fn: CallBack<T, boolean>, to: arr<T>?, to_start: number?): arr<T>
	to = to or arr_sized(0)
	local to_len = (to :: arr<T>).n
	to_start = to_start or (to_len + 1)
	local idx = 1
	local len = self.n
	local item
	local defer = 0
	local in_range
	while idx <= len do
		in_range = idx <= len
		item = if in_range then self[idx] else nil
		if in_range and fn(item, idx, self) then
			defer += 1
		elseif defer ~= 0 then
			table.move(self, idx - defer, idx - 1, to_len + 1, to)
			to_len += defer
			defer = 0
		end
		idx += 1
	end
	return to :: arr<T>
end
function arr.filter_inplace<T>(self: arr<T>, fn: CallBack<T, boolean>, start: number?, last: number?): arr<T>
	local idx = 1
	local len = self.n
	local item
	local filtered = 0
	local should_move = 0
	local back
	while idx <= len do
		item = self[idx]
		if not fn(item, idx, self) then
			if should_move == 0 then
			elseif should_move == 1 then
				back = idx - 1
				self[back - filtered] = self[back]
			else
				local move = idx - should_move
				table.move(self, move, idx - 1, move - filtered)
				should_move = 0
			end
			filtered += 1
		elseif filtered ~= 0 then
			should_move += 1
		end
		idx += 1
	end
	self.n -= filtered
	for i = len - filtered - 1, len do
		self[i] = nil
	end
	return self, len - filtered
end

function arr.some<T, G>(self: arr<T>, fn: CallBack<T, G>, start: number?, last: number?): G?
	local arr_len = self.n
	start, last = arr_range(arr_len, start, last)
	local result
	for i = start :: number, last :: number do
		result = fn(self[i], i, self)
		if result then
			return result
		end
	end
	return result
end
function arr.all<T>(self: arr<T>, fn: CallBack<T, boolean>, start: number?, last: number?): boolean
	for i = 1, self.n do
		if not fn(self[i], i, self) then
			return false
		end
	end
	return true
end

function arr.flat<T>(self: arr<T>, start: number?, last: number?, to: arr<T>?): arr<T>
	local arr_len = self.n
	start, last = arr_range(arr_len, start, last)
	to = to or arr_sized(0)
	local to_len = (to :: arr<T>).n
	local inner
	local inner_len
	local defer = 0
	local inner_isarr
	for idx = start :: number, last :: number do
		inner = self[idx]
		inner_isarr = type(inner) == "table" and rawget(inner, "__arr__")
		if inner_isarr or idx == last then
			if not inner_isarr then
				defer += 1
			end
			if defer == 0 then
			elseif defer == 1 then
				(to :: arr<T>)[to_len + 1] = self[idx - 1]
				to_len += 1
			else
				table.move(self, idx - defer, idx - 1, to_len + 1, to :: arr<T>)
				to_len += defer
				defer = 0
			end
			if inner_isarr then
				inner_len = inner.n
				if inner_len == 0 then
				elseif inner_len == 1 then
					(to :: arr<T>)[to_len + 1] = inner[1]
				else
					table.move(inner, 1, inner_len, to_len + 1, to :: arr<T>)
				end
				to_len += inner_len
			end
		else
			defer += 1
		end
	end
	(to :: arr<T>).n = to_len
	return to :: arr<T>
end
function arr.flat_inplace<T>(self: arr<T>, start: number?, last: number?): arr<T>
	local idx = 1
	local len = self.n
	local inner, inner_len
	while idx <= len do
		inner = self[idx]
		if type(inner) ~= "table" or not rawget(inner, "__arr__") then
			idx += 1
			continue
		end

		inner_len = inner.n
		if inner_len == 1 then
			self[idx] = inner_len[1]
			idx += 1
			continue
		elseif inner_len == 0 then
			table.remove(self, idx)
			len -= 1
			continue
		end

		table.move(self, idx + 1, len, idx + inner_len)
		table.move(inner, 1, inner_len, idx, self)

		len += inner_len - 1
		for inner_idx = 1, inner_len do
			table.insert(self, idx + inner_idx - 1, inner[inner_idx])
		end
		idx += inner_len
	end
	return self
end

function arr.fill<T>(self: arr<T>, item: T, start: number?, last: number?): arr<T>
	if item == nil then
		return self
	end
	local arr_len = self.n
	start = start or 1
	last = last or arr_len
	for idx = start :: number, last :: number do
		self[idx] = item
	end
	if last > arr_len then
		self.n = last :: number
	end
	return self
end

local function arr_iter<T>(self: arr<T>, idx: number): (number?, T?)
	idx += 1
	if self.n :: number >= idx then
		return idx, self[idx]
	end
	return nil, nil
end
function arr.iter<T>(self: arr<T>): ((self: arr<T>, idx: number) -> (number?, T?), arr<T>, number)
	return arr_iter, self, 0
end

function arr.len(self: arr<any>): number
	return self.n
end
function arr.empty(self: arr<any>): boolean
	return self.n == 0
end
function arr.each<T, Userdata>(self: arr<T>, fn: CallBackWithUserdata<T, Userdata?, Userdata?>, base: Userdata?): Userdata?
	base = nil
	local done
	for i = 1, self.n do
		base, done = fn(self[i], i, self, base)
		if done then
			break
		end
	end
	return base
end
function arr.join<T>(self: arr<T>, delimiter: string?): string
	return table.concat(self, delimiter, 1, self.n)
end
function arr.count<T>(self: arr<T>, fn: CallBack<T, any>): number
	local count = 0
	for i = 1, self.n do
		if fn(self[i], i, self) then
			count += 1
		end
	end
	return count
end
function arr.find<T>(self: arr<T>, fn: CallBack<T, any>): (T?, number?)
	local item
	for i = 1, self.n do
		item = self[i]
		if fn(item, i, self) then
			return item, i
		end
	end
	return nil, nil
end
function arr.sum<T>(self: arr<T>, base: T?): T
	base = base or 0 :: any
	for i = 1, self.n do
		base += self[i] :: any
	end
	return base :: T
end
function arr.prod<T>(self: arr<T>, base: T?): T
	base = base or 1 :: any
	for i = 1, self.n do
		base *= self[i] :: any
	end
	return base :: T
end
function arr.max<T>(self: arr<T>, base: T?, comp: common.Comparator<T>): T?
	local item
	for i = 1, self.n do
		item = self[i]
		if base == nil or compareTo(item, base) < 0 then
			base = item
		end
	end
	return base
end
function arr.min<T>(self: arr<T>, base: T?, comp: common.Comparator<T>): T?
	local item
	for i = 1, self.n do
		item = self[i]
		if base == nil or compareTo(item, base) > 0 then
			base = item
		end
	end
	return base
end

function arr.slice<T>(self: arr<T>, start: number?, last: number?, to: arr<T>?, to_start: number?): arr<T>
	start, last = arr_range(self.n, start, last)
	local move_len = last :: number - start :: number + 1
	if to then
		local to_len = to.n
		if to_start == nil then
			to_start = to_len + 1
		end
		to.n = to_len + move_len
		if to_len >= to_start then
			table.move(to, to_len - to_start + 1, to_len, to_start + move_len)
		end
	else
		to = { n = move_len }
	end
	if move_len == 0 then
	elseif move_len == 1 then
		(to :: arr<T>)[to_start :: number] = self[start :: any]
	else
		table.move(self, start :: number, last :: number, to_start :: number, to :: arr<T>)
	end
	return to :: arr<T>
end
function arr.slice_inplace<T>(self: arr<T>, start: number?, last: number?): arr<T>
	-- Empty: arr length is 0
	local arr_len = self.n
	if arr_len == 0 then
		return self
	end

	-- Empty: start and last across
	start, last = arr_range(arr_len, start, last)
	if start > last then
		table.clear(self)
		self.n = 0
		return self
	end

	-- No action required
	if start == 1 and last == arr_len then
		return self
	end

	-- Move elements to front
	if start ~= 1 then
		table.move(self, start :: number, last :: number, 1)
	end

	-- Remove tailing
	for idx = last :: number - start :: number + 2, arr_len do
		self[idx] = nil
	end

	-- Update length
	self.n = last :: number - start :: number + 1
	return self
end

function arr.equal<T>(self: arr<T>, to: arr<T>): boolean
	local arr_len = self.n
	if arr_len ~= to.n then
		return false
	end
	for idx = 1, arr_len do
		if self[idx] ~= to[idx] then
			return false
		end
	end
	return true
end
arr.__eq = arr.equal

export type arr<T> = {
	n: number,
	[number]: T,
} & typeof(arr)

return (arr :: unknown) :: <T>(...T) -> arr<T> & arr<T>
