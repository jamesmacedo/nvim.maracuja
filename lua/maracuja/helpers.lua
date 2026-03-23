
local helpers = {
	tabl = {}
}

function helpers.tabl.has_value(tab, val)
	for _, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end

function helpers.tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return helpers
