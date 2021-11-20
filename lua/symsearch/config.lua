local opts = {
    qprops = {
        java = {"class", "fields", "methods"}
    },
    symbols = {
        protected = "🔐",
        private = "🔒",
        public = "🔓"
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
