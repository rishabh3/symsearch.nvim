local opts = {
    qprops = {
        java = {"class", "fields", "methods"}
    },
    query = {
        java = {
            class = [[
                (
                    class_declaration
                        name: (identifier) @className (#offset! @className)
                )
            ]],
        }
    }
}

return {opts = opts}
