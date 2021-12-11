local g = vim.g
local cmd = vim.cmd
local fn = vim.fn
local colors = vim.g.mywords_colors or {'#8ccbea', '#a4e57e', '#ffdb72', '#ff7272', '#ffb3ff', '#9999ff'}

local word_group_mapping = {}
local group_color_mapping = {}
local avail_colors = colors

-- clear highlight group to clear highlight of the word
local function unhighlight_group(group)
    cmd(string.format('highlight clear %s', group))
    for k, v in pairs(word_group_mapping) do
        if v == group then
            word_group_mapping[k] = nil
        end
    end

    local color = group_color_mapping[group]
    group_color_mapping[group] = nil
    table.insert(avail_colors, 1, color)
end

local function find_avail_color()
    if #avail_colors ~= 0 then
        return avail_colors[1]
    else
        for k, v in pairs(word_group_mapping) do
            if word_group_mapping[k] ~= nil then
                unhighlight_group(v)
                return avail_colors[1]
            end
        end
    end
end

-- toggle the highlight status of the given word
local function highlight_word(word)
    local hl_group = 'mywords_'..word

    if word_group_mapping[word] ~= nil then
        unhighlight_group(hl_group)
    else
        local color = find_avail_color()
        if color ~=nil then
            -- ctermbg=Blue 
            cmd(string.format('highlight %s guibg=%s', hl_group, color))
            local id = fn.matchadd(hl_group, string.format([[\<%s\>]], word), 11)

            word_group_mapping[word] = hl_group
            group_color_mapping[hl_group] = color
            for i, c in pairs(avail_colors) do
                if c == color then 
                    table.remove(avail_colors, i)
                end
            end
        end
    end
end

-- unhighlight all words
local function uhl_all()
    for k, v in pairs(word_group_mapping) do
        unhighlight_group(v)
    end
end

-- toggle the highlight of current word
local function hl_toggle()
    local word = fn.expand('<cword>')
    highlight_word(word)
end

-- helper to create key mapping
local function key_mapping_helper(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then
        options = vim.tbl_extend("force", options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end


key_mapping_helper("n", "<leader>m", ":lua require'mywords'.hl_toggle()<CR>", { silent = true })
key_mapping_helper("n", "<leader>c", ":lua require'mywords'.uhl_all()<CR>",   { silent = true })


return {
  hl_toggle = hl_toggle,
  uhl_all = uhl_all 
}
