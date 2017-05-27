
-- local _M = {}

local function get_table_length( table )
  local count = 0
  for _, el in pairs( table ) do
    count = count + 1
  end
  return count
end

return {
  get_table_length = get_table_length
}
