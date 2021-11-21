# WARNING

This is just my first `neovim plugin`, trying to build quick symbol searcher with `neovim-treesitter` and 
`telescope`. If you experience any issues, you are free to add/enhance by improving it or raise an issue
for me to look into it.

# symsearch.nvim

## What is symsearch?

`symsearch.nvim` is a customizable symbol searcher. Symsearch is built on `neovim-treesitter`
and `telescope` for fuzzy finding the symbols. The three symbol groups which symsearch finds and
categorises them are `class`, `fields` and `methods`. This is my first `neovim plugin` build to bring 
quick symbol finder they one we have in ides like `Eclipse`. The default configuration is for `java`
as that is the primary language I use from dev work, but it can be extended by configuring more into it.

https://user-images.githubusercontent.com/17352263/142762037-96a58591-36aa-420f-ab56-e216e4b40c63.mp4

## Symsearch Table of contents

- [Problem](#problem)
- [Installation](#installation)
- [Usage](#usage)
- [Default Configuration](#default-configuration)
- [Customization](#customization)


## Problem
The main problem which we are trying to solve here is quick symbol search when working in a project,
for quick navigation. We already have this feature exposed via `lsp` and `telescope` via `lsp_document_symbols`
builtin picker, but I have tried to build this plugin to get a hands on learning without using any `lsp`.

## Installation
### Requires Neovim version 0.5.0+, neovim-treesitter and telescope
Simply install via your favourite plugin manager

```lua
use {
    "rishabh3/symsearch.nvim",
    requires = {"nvim-telescope/telescope.nvim", "nvim-treesitter/nvim-treesitter"},
    config = function()
        require "symsearch".setup()
    end
}
```
One can pass an updated configuration to `setup` function which would merge the default configuration
and the new passed configuration. Check the [Default Configuration](#default-configuration) section for 
more details on the default configuration.

## Usage
This section will talk about usage methods and keymaps one can set to search the symbols present in
the buffer. The commands will work only if the configuration has been added for the filetype, else 
it will error out.

The following are the different commands exposed by the plugin:
- **SymClassSearch**: This command opens a telescope picker to search for classes present in the buffer. On selecting any entry would jump to the line containing the name of the class.
- **SymFieldSearch**: This command opens a telescope picker to search for fields present in the buffer. On selecting any entry would jump to line of the field declaration.
- **SymMethodSearch**: This command opens a telescope picker to search for methods present in the buffer. On selecting any entry would jump to line of the method declaration.
- **ReloadSymbols**: This command will reload the symbols, in case of buffer modification (addition of new class, field or method) one can reload the symbols and cache them. If you donot reload the symbols then same symbol set will be shown.

```lua
    lua require("symsearch").show_symbols("class") -- Show class symbols found in the buffer
    lua require("symsearch").show_symbols("methods") -- Show method symbols found in the buffer
    lua require("symsearch").show_symbols("fields") -- Show fields symbols found in the buffer
    lua require("symsearch").reload_symbols() -- Reload symbols for the buffer (in case of buffer change)
```


The plugin also registers an `Autocommand group` as described below
```viml
augroup SymSearch
    autocmd BufLeave * lua require("symsearch").cleanup()
augroup end
```
This autogroup invokes the `cleanup` function exposed by the `symsearch` module on BufLeave event (whenever one switches buffer, well this is necessary to not show symbols of previous buffer in the new buffer)

## Default Configuration
This section will talk about the default configuration available and how one can extend it by overriding this configuration and passing it 
in the `setup` function mentioned in the [Installation](#installation) section.

```lua
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
                    for _, class in pairs(data) do
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
                    for _, method in pairs(data) do
                        local temp_name = "🔎 "
                        if method.access ~= nil then
                            temp_name = temp_name .. method.access.name .. " "
                        end
                        local parsed_data = {
                            name = temp_name .. method.name.name .. method.params.name .. ": " .. method.type.name,
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
                    for _, field in pairs(data) do
                        local temp_name = "🔎 "
                        if field.access ~= nil then
                            temp_name = temp_name .. field.access.name .. " "
                        end
                        local parsed_data = {
                            name = temp_name .. field.name.name .. ": " .. field.type.name,
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
                [
                    (
                        class_declaration
                            name: (identifier) @name (#offset! @name)
                    )
                    (
                        interface_declaration 
                            name: (identifier) @name (#offset! @name)
                    )

                ]
            ]],
            methods = [[
                (
                    method_declaration
                        (modifiers)* @access
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
                        (modifiers)* @access
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
```

The above configuration exposes the following properties one can customise:
- **qprops**: This configuration property basically means query properties, which stores mappings for the supported groups as we talked in the previous section (class, fields, methods). Consider the default configuration as an example, the above config basically means that for java filetype all the three groups symbols can be searched if one has open a java file in the buffer. Some languages do not have classes or concept of classes, in such cases one can skip mentionining the `class` in the qprops table.
- **symbols**: This configuration property basically maintains a mapping of substituting the text captured from the `treesitter node` to some other text or symbols for better display. As we can see here `java` has `public`, `private` and `protected` access levels which I have mapped to these symbols which would be displayed in the pickers. 
- **picker_config**: This configuration property is the most important property as it can help one to configure and customise the telescope picker that would appear to view and navigate to these symbols in the buffer. Consider the same example mentioned above, this particular property has the following sub-properties using which one can control the behaviour, look and feel of the picker. This also contains filetype config for the key, to enable customisation on each filetype. Each filetype property contains different picker configuration based on the supported group, for example `java` supports all three groups (class, fields, methods) hence we can configure picker for all of them. The following are sub-properties of the group pickers.
    - **picker_opts**: One can pass telescope specific configuration/options for the picker we are going to create for the symbol search.
    - **title**: Title of the picker
    - **ts_data_creator**: This must contain a function which would return an array of data that would be passed to the telescope picker. One can customise the name of the option one would see in the picker and second being the location of the symbol in the buffer.
- **query**: This property maintains a mapping of filetype and their treesitter query to capture different bits of information like name, type, params, access etc. One can configure different query for different language in their configuration and pass to the setup function, once the query support and other configurations as mentioned are passed, symsearch would be able to collect the different available symbols and list them via the picker for quicker navigation.

### Details
This sub section lays down the details of how `symsearch` collects the data and importance of each configuraiton. Once the user has configured the different `query` associated for specific language, the `symsearch` parses the query and run it on the buffer and captures different nodes as defined in the query. In the query `@<name>` defines a capture which would capture a node from the buffer matching the specification. Lets consider the methods query and different captures associated with it.
```scratch
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
```
As we can see here we have defined 4 captures in this query which are `@access`, `@type`, `@name`, `@params`.
`@access` capture, captures the access modifier node associated with method declaration
`@type` capture, captures the return type node of the method.
`@name` capture, captures the name node of the method
`@params` capture, captures the params node of the method.

`symsearch` processes each captures and collect them in a table with value containing two properties `name`, `loc`. The `loc` property will be populated with the location of the node (line, col), if the capture in the query has been declared with `#offset!` directive. So from a single method definition we will get 4 pieces of information that is `@access`, `@type`, `@name` and `@params`. Now in the picker configuration mentioned above, when we parse this data prepared by `symsearch` to pass it to telescope we can utilise all the data mentioned in the above 4 captures and that is the reason there is a correlation in the *ts_data_creator* function and the data prepared post parsing the treesitter nodes.
We can create a name which would be displayed in the picker using the data available to us.
```lua
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
```

As mentioned we have 4 captures `access`, `name`, `params` and `type` and as we can see we utilise the data available to us in the `ts_data_creator` function to create new name using it. Also note that `loc` property is filled using the location captured from `name` capture. If one configures the location to be captured by a different capture like `access` one needs to change the loc property in this function to use `method.access.loc` instead of `method.name.loc`. The `loc` property is used for navigation or jumping to the symbol in the buffer.


## Customization
This section covers some details about customization. One can easily customize this plugin by passing their own queries, customizing the picker configuration and configuring it for their required languages they primarily work on. In my case it is `java` hence i have added a default configuration for `java` but one can enhance it by adding configuration for `python`, `lua` and many more. Another suggestion would be to use `TSPlayground` to come up with various queries which one can configure here as that would give you the control on the different symbols you can collect and show in the picker.

## Contributing

All contributions are welcome! Just open a pull request.
