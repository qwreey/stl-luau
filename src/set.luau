local set = {}

function set.from_function() end
function set.intersect_inplace<T>(self: set<T>) end
function set.intersect<T>(self: set<T>) end
function set.union_inplace<T>(self: set<T>) end
function set.union<T>(self: set<T>) end
function set.subtract_inplace<T>(self: set<T>) end
function set.subtract<T>(self: set<T>, target)
	for key in target do
	end
end
function set.size<T>(self: set<T>) end
function set.has<T>(self: set<T>, value)
	return set[value] or false
end
function set.add<T>(self: set<T>, value)
	set[value] = true
end
function set.exclusive_inplace<T>(self: set<T>) end
function set.exclusive<T>(self: set<T>) end
function set.is_subset_of<T>(self: set<T>, of) end

export type set<T> = {} & typeof(set)

return set
