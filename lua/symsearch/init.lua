local utils = require('symsearch.utils')

local M = {}


M.test =  function()
    local parser = utils.load_parser()
    local root = utils.load_root(parser)

    local qtable = utils.load_query_table()

    local prepared_data = {}
    for key, query in pairs(qtable) do
        local data = utils.matched_data(query, root)
        prepared_data[key] = data
    end

    utils.print_debug(prepared_data)
    return prepared_data
end

return M
