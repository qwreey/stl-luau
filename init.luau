local arr = require("./src/arr")
local set = require("./src/set")

export type arr<T> = arr.arr<T>
export type set<T> = set.set<T>

-- stylua: ignore start
local function run_test()
	local test = require("./libs/test-luau")
	test("stl-luau")(
		require("./tests/arr")()
	)
end
-- stylua: ignore end

return {
	arr = arr,
	set = set,
	run_test = run_test,
}
