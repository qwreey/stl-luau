local exports = {}

export type falsely = false?
export type truely = true | { any } | (...any) -> ...any | number | string | buffer | thread | vector

export type Comparator<T> = (a: T, b: T) -> boolean & (a: T, b: T) -> number
function exports.compareTo<T>(a: T, b: T, comp: Comparator<T>?): number
	if comp then
		local result = comp(a, b)
		if result == true then
			return 1
		elseif result == false then
			return -1
		end
		return result
	end
	return a :: any - b :: any
end

return exports
