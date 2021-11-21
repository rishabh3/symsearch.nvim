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

local function show_symbols(type)
    if M.symbols == nil then
        M.reload_symbols()
    end

    local current_picker_config = nil

    if type == "class" then
        current_picker_config = utils.config.opts.picker_config[vim.bo.filetype].class_picker_config
    elseif type == "methods" then
        current_picker_config = utils.config.opts.picker_config[vim.bo.filetype].method_picker_config
    elseif type == "fields" then
        current_picker_config = utils.config.opts.picker_config[vim.bo.filetype].field_picker_config
    end

    if current_picker_config == nil then
        error("No support added for " .. vim.bo.filetype .. " filetype, please check your configuration")
    end

    local data = M.symbols[type]

    local telescope_data = current_picker_config.ts_data_creator(data)

    return utils.create_picker(current_picker_config.picker_opts, current_picker_config.title, telescope_data)
end

local function setup(config)
    return utils.setup_helper(config)
end

local function cleanup()
    M.symbols = nil
    M.parser = nil
    M.qtable = nil
end


M.reload_symbols = load_symbols
M.show_symbols = show_symbols
M.cleanup = cleanup
M.setup = setup

return M
