
local helpers = {
	tabl = {}
}

function helpers.tabl.has_value(tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

return helpers
