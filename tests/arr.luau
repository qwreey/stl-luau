local test = require("../libs/test-luau")
local arr = require("../src/arr")

-- stylua: ignore start
local function run_test()
	return test "arr" (
		test "slice_inplace"
			"start: 2, last: 2":assume_equal(
				arr(1, 2, 3, 4, 5):slice_inplace(2, 4),
				arr(2, 3, 4)
			)
			"start: 2, last: 4 (end)":assume_equal(
				arr(1, 2, 3, 4, 5):slice_inplace(2, 4),
				arr(2, 3, 4)
			)
			"start: -2, last: -1 (end)":assume_equal(
				arr(1, 2, 3, 4, 5):slice_inplace(-2, -1),
				arr(4, 5)
			)
			"start: -2, last: -2 (len = 1)":assume_equal(
				arr(1, 2, 3, 4, 5):slice_inplace(-2, -2),
				arr(4)
			)
			"start: -2, last: -3 (len = 0)":assume_equal(
				arr(1, 2, 3, 4, 5):slice_inplace(-2, -3),
				arr()
			)
			"start: -4, last: -2":assume_equal(
				arr(1, 2, 3, 4, 5):slice_inplace(-4, -2),
				arr(2, 3, 4)
			)
	)
end
-- stylua: ignore end

return run_test
