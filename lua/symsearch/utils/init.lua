local config = require('symsearch.config')
local q = require('vim.treesitter.query')

local M = {}

local function print_debug(a)
    print(vim.inspect(a))
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
    if vim.bo.filetype == "" then
        return nil
    end
    return config.opts.query[vim.bo.filetype]
end

local function load_available_qprops()
    if vim.bo.filetype == "" then
        return nil
    end
    return config.opts.qprops[vim.bo.filetype]
end

local function load_query_table()

    local available_query = load_queries()

    if available_query == nil then
        print("Please open supported file")
        return nil
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

local function collect_data(nodes, capture_metadata, metadata)
    local collected_data = {}
    for index, node in ipairs(nodes) do
        local data = {
            name = q.get_node_text(node, 0),
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

    return collected_data
end

local function preprocess_captures(captures, patterns)
    local metadata = {}
    for _, capture in ipairs(captures) do
        local data = {
            capture_name = capture,
            metadata = false
        }
        table.insert(metadata, data)
    end
    for _, pattern in ipairs(patterns) do
        local index = pattern[2]
        metadata[index].metadata = true
    end
    return metadata
end


local function matched_data(query, root)
    local data = {}
    for _, nodes, metadata in query:iter_matches(root, 0) do
        local capture_metadata = preprocess_captures(query.captures, query.info.patterns[1])
        local info = collect_data(nodes, capture_metadata, metadata)
        table.insert(data, info)
    end
    return data
end

M.print_debug = print_debug
M.load_parser = load_parser
M.load_root = load_root
M.load_query_table = load_query_table
M.matched_data = matched_data

return M
