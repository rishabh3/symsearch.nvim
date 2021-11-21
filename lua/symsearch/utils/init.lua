local config = require("symsearch.config")
local tsutils = require("nvim-treesitter.ts_utils")
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"


local M = {
    config = config
}

M.print_debug = function (a)
    print(vim.inspect(a))
end

local function setup_helper(new_config)
    new_config = new_config or {}
    M.config = vim.tbl_deep_extend("force", config, new_config)
end

local function load_parser()
    local bufnr = 0
    local ftype = vim.bo.filetype

    local parser = vim.treesitter.get_parser(bufnr, ftype)

    return parser
end

local function load_root(parser)
    local syntax_tree = parser:parse()

    local root = syntax_tree[1]:root()

    return root
end

local function load_queries()
    if M.config == nil then
        error("Please invoke setup method in your neovim configuration")
    end
    if vim.bo.filetype == "" then
        return nil
    end
    return M.config.opts.query[vim.bo.filetype]
end

local function load_available_qprops()
    if vim.bo.filetype == "" then
        return nil
    end
    return M.config.opts.qprops[vim.bo.filetype]
end

local function load_query_table()
    local available_query = load_queries()

    if available_query == nil then
        error("Please open supported file, check your config for supported file, default support is for java")
    end

    local available_qprops = load_available_qprops()

    local query_table = {}

    for _, value in ipairs(available_qprops) do
        local query = available_query[value]
        if query ~= nil then
            query_table[value] = vim.treesitter.parse_query(vim.bo.filetype, query)
        end
    end

    return query_table
end

local function trim(s)
    if s == nil then
        return "Null string"
    end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function substitute(name)
    for key, value in pairs(M.config.opts.symbols) do
        if string.find(name, key) then
            return value
        end
    end
    return name
end


local function clean_name(names, capture_name)
    local new_name = ""
    if capture_name ~= "access" then
        for index, name in ipairs(names) do
            if index > 1 then
                name = substitute(trim(name))
            end
            new_name = new_name .. name
        end
    else
        if #names > 1 then
            new_name = substitute(trim(names[#names]))
        else
            new_name = substitute(trim(names[1]))
        end
    end
    return new_name
end

local function collect_data(nodes, capture_metadata, metadata)
    local collected_data = {}
    if nodes ~= nil then
        for index, node in ipairs(nodes) do
            local unprocessed_name = tsutils.get_node_text(node, 0)
            local processed_name = clean_name(unprocessed_name, capture_metadata[index].capture_name)
            local data = {
                name = processed_name,
                loc = nil
            }
            collected_data[capture_metadata[index].capture_name] = data
        end

        local capture_no_metadata = 0

        for index, x in ipairs(capture_metadata) do
            if x.metadata then
                local location = metadata.content[index - capture_no_metadata]
                collected_data[x.capture_name].loc = {location[1] + 1, location[2]} -- lua is 1 index whereas C is 0 index (treesitter returns 0 based)
            else
                capture_no_metadata = capture_no_metadata + 1
            end
        end
    end

    return collected_data
end

local function preprocess_captures(captures, patterns)
    local metadata = {}
    if captures ~= nil then
        for _, capture in ipairs(captures) do
            local data = {
                capture_name = capture,
                metadata = false
            }
            table.insert(metadata, data)
        end
    end
    if patterns ~= nil then
        for _, pattern in ipairs(patterns) do
            local index = pattern[2]
            metadata[index].metadata = true
        end
    end
    return metadata
end

local function matched_data(query, root)
    if M.config == nil then
        error("Please invoke setup method in your neovim configuration")
    end
    local data = {}
    for _, nodes, metadata in query:iter_matches(root, 0) do
        local capture_metadata = preprocess_captures(query.captures, query.info.patterns[1])
        local info = collect_data(nodes, capture_metadata, metadata)
        table.insert(data, info)
    end
    return data
end

local function create_picker(opts, title, data)
    local prefix = "→ "
    opts.prompt_prefix = prefix
    opts.selection_caret = prefix
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = title,
        finder = finders.new_table {
            results = data,
            entry_maker = function (entry)
                return {
                    value = entry,
                    display = entry.name,
                    ordinal = entry.name
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection ~= nil then
                    local line_detail = selection.value.loc
                    vim.api.nvim_win_set_cursor(0, line_detail)
                end
            end)
            return true
        end
    }):find()
end

M.load_parser = load_parser
M.load_root = load_root
M.load_query_table = load_query_table
M.matched_data = matched_data
M.create_picker = create_picker
M.setup_helper = setup_helper

return M
