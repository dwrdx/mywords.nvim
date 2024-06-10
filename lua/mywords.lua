local g = vim.g
local cmd = vim.cmd
local fn = vim.fn
local colors = vim.g.mywords_colors or {'#8ccbea', '#a4e57e', '#ffdb72', '#ff7272', '#ffb3ff', '#9999ff'}

local group_word_color_mapping = {}
local group_fifo = {}
local avail_colors = colors

local bit = require('bit')

-- convert regex expression to a valid highlight group name suffix
local function regex_to_varname(regex)
    -- Clean the string by keeping only alphanumeric characters and underscores
    local clean = regex:gsub("[^%w_]", "")
  
    -- Calculate a hash value for the original regular expression
    local hash = 0
    for i = 1, #regex do
        local c = string.byte(regex, i)
        hash = bit.bxor(bit.lshift(hash, 5), hash) + c
        hash = bit.band(hash, 0x7FFFFFFF)  -- prvent negative value
    end
  
    -- If the cleaned string starts with a digit, prepend 'var' to make it a valid identifier
    if clean:match("^%d") then
        clean = "var" .. clean
    end
  
    -- Append the hash value as a suffix to ensure uniqueness
    local varname = clean .. "_" .. tostring(hash)

    return varname
end

-- clear highlight group to clear highlight of the word
local function unhighlight_group(group)
    -- unhighlight
    cmd(string.format('highlight clear %s', group))

    local color = group_word_color_mapping[group][2]

    -- inser avail_colors
    table.insert(avail_colors, color)
    -- clear group record
    group_word_color_mapping[group] = nil
    -- remove group fifo
    for k, v in pairs(group_fifo) do
        if v == group then
            table.remove(group_fifo, k)
        end
    end
end

local function find_avail_color()
    if #avail_colors ~= 0 then
        return avail_colors[1]
    else
        local hl_group = group_fifo[1]
        unhighlight_group(hl_group)
        return avail_colors[1]
    end
end

local function debug_helper_print_table(t)
    for i=1, #t do
        print(i)
        print(t[i])
    end
end

-- toggle the highlight status of the given word
local function highlight_word(word)
    local hl_group = 'mywords_'..regex_to_varname(word)

    if group_word_color_mapping[hl_group] ~= nil then
        unhighlight_group(hl_group)
    else
        local color = find_avail_color()
        if color ~=nil then
            -- ctermbg=Blue 
            cmd(string.format('highlight %s guibg=%s guifg=Black', hl_group, color))

            local win_totalnum = fn.winnr('$')

            for i=1, win_totalnum do
                local win_id = fn.win_getid(i)
                local id = fn.matchadd(hl_group, string.format([[\<%s\>]], word), 11, -1, { window=win_id})
            end

            group_word_color_mapping[hl_group] = {word, color}
            table.insert(group_fifo, hl_group)

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
    for k, v in pairs(group_word_color_mapping) do
        local hl_group = k
        unhighlight_group(hl_group)
    end
end

-- toggle the highlight of current word
local function hl_toggle()
    local word = fn.expand('<cword>')
    highlight_word(word)
end

-- toggle the haghlight of given regex expression
local function hl_toggle_regex()
    local user_input = vim.fn.input("Input Regex: ")
    highlight_word(user_input)
end

return {
  hl_toggle = hl_toggle,
  hl_toggle_regex = hl_toggle_regex,
  uhl_all = uhl_all 
}
