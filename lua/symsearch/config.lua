local themes =  require("telescope.themes")


local opts = {
    qprops = {
        java = {"class", "fields", "methods"}
    },
    symbols = {
        protected = "🔐",
        private = "🔒",
        public = "🔓"
    },
    picker_config = {
        java = {
            class_picker_config = {
                picker_opts = themes.get_cursor(),
                title = "Available Classes",
                ts_data_creator = function (data)
                    local telescope_data = {}
                    for _, class in ipairs(data) do
                        local parsed_data = {
                            name = "📦" .. " " .. class.name.name,
                            loc = class.name.loc
                        }
                        table.insert(telescope_data, parsed_data)
                    end
                    return telescope_data
                end
            },
            method_picker_config = {
                picker_opts = themes.get_dropdown({
                    layout_config = {
                        height = 15,
                        width = 180
                    }
                }),
                title = "Available Methods",
                ts_data_creator = function (data)
                    local telescope_data = {}
                    for _, method in ipairs(data) do
                        local parsed_data = {
                            name = method.access.name .. " " .. method.name.name .. method.params.name .. ": " .. method.type.name,
                            loc = method.name.loc
                        }
                        table.insert(telescope_data, parsed_data)
                    end
                    return telescope_data
                end
            },
            field_picker_config = {
                picker_opts = themes.get_cursor(),
                title = "Available Fields",
                ts_data_creator = function (data)
                    local telescope_data = {}
                    for _, field in ipairs(data) do
                        local parsed_data = {
                            name = field.access.name .. " " .. field.name.name .. ": " .. field.type.name,
                            loc = field.name.loc
                        }
                        table.insert(telescope_data, parsed_data)
                    end
                    return telescope_data
                end
            }
        }
    },
    query = {
        java = {
            class = [[
                (
                    class_declaration
                        name: (identifier) @name (#offset! @name)
                )
            ]],
            methods = [[
                (
                    method_declaration
                        (modifiers) @access
                        type: [
                            (void_type)
                            (type_identifier)
                            (boolean_type)
                            (generic_type)
                            (integral_type)
                            (floating_point_type)
                        ] @type
                        name: (identifier) @name (#offset! @name)
                        parameters: (formal_parameters) @params
                )
            ]],
            fields = [[
                (
                    field_declaration
                        (modifiers) @access
                        type: [
                            (type_identifier)
                            (generic_type)
                            (boolean_type)
                            (integral_type)
                            (floating_point_type)
                        ] @type
                        declarator: (
                                        variable_declarator
                                            name: (identifier) @name (#offset! @name)
                                    ) 
                )
            ]]
        }
    }
}

return {opts = opts}
