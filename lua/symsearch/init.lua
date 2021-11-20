local utils = require('symsearch.utils')
local M = {}

local function init()
    M.parser = utils.load_parser()
    M.qtable = utils.load_query_table()
end

local function load_symbols()
    if M.parser == nil or M.qtable == nil then
        init()
    end

    local root = utils.load_root(M.parser)

    local prepared_data = {}
    for key, query in pairs(M.qtable) do
        local data = utils.matched_data(query, root)
        prepared_data[key] = data
    end

    M.symbols = prepared_data
end

local function show_class_symbols()
    if M.symbols == nil then
        M.reload_symbols()
    end
    local symbol_key = "class"
    local data = M.symbols[symbol_key]

    if data == nil then
        error("No class symbol support added, check your configuration");
    end

    local telescope_data = {}
    for _, class in ipairs(data) do
        local parsed_data = {
            name = "📦" .. " " .. class.name.name,
            loc = class.name.loc
        }
        table.insert(telescope_data, parsed_data)
    end

    return utils.create_picker(require("telescope.themes").get_cursor(), "Available Class", telescope_data)
end

local function show_field_symbols()
    if M.symbols == nil then
        M.reload_symbols()
    end
    local symbol_key = "fields"
    local data = M.symbols[symbol_key]

    if data == nil then
        error("No field symbol support added, check your configuration");
    end

    local telescope_data = {}
    for _, field in ipairs(data) do
        local parsed_data = {
            name = field.access.name .. " " .. field.name.name .. ": " .. field.type.name,
            loc = field.name.loc
        }
        table.insert(telescope_data, parsed_data)
    end

    return utils.create_picker(require("telescope.themes").get_cursor(), "Available Fields", telescope_data)
end

local function show_method_symbols()
    if M.symbols == nil then
        M.reload_symbols()
    end
    local symbol_key = "methods"
    local data = M.symbols[symbol_key]

    if data == nil then
        error("No method symbol support added, check your configuration");
    end


    local telescope_data = {}
    for _, method in ipairs(data) do
        local parsed_data = {
            name = method.access.name .. " " .. method.name.name .. method.params.name .. ": " .. method.type.name,
            loc = method.name.loc
        }
        table.insert(telescope_data, parsed_data)
    end

    return utils.create_picker(require("telescope.themes").get_ivy(), "Available Methods", telescope_data)
end


M.reload_symbols = load_symbols
M.show_class_symbols = show_class_symbols
M.show_field_symbols = show_field_symbols
M.show_method_symbols = show_method_symbols

return M
