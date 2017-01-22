
local function format_data(array, width)
    local left_and_top_spacing = 0
    local right_bottom_spacing = 0
    
    local quotient = width // #array
    local remainder = width % #array
    left_and_top_spacing = math.ceil(remainder / 2 - 0.5)
    right_bottom_spacing = remainder - left_and_top_spacing
    local result = {}
    for row = 1, width, 1
    do
        local row_data = {}
        if (row <= left_and_top_spacing) or (row > width - right_bottom_spacing) then
            for col = 1, width, 1
            do
                table.insert(row_data, 0)
            end
        else
            for col = 1, width, 1
            do
                if (col <= left_and_top_spacing) or (col > width - right_bottom_spacing) then
                    table.insert(row_data, 0)
                else
                    table.insert(row_data, array[(row - left_and_top_spacing - 1) // quotient + 1][(col - left_and_top_spacing - 1) // quotient + 1])
                end
            end
            
        end
        table.insert(result, row_data)
    end
    return result
    
end


local function header(array)
    local file_size = 62 + ((#array + 31) // 32) * 4 * #array
    local result = "BM" .. string.pack("i4i2i2i4", file_size, 0, 0, 54 + 8)
    return result
end

local function dib(array)
    local data_size = ((#array + 31) // 32) * 4 * #array
    local result = string.pack("i4i4i4i2i2i4i4i4i4i4i4", 40, #array, #array, 1, 1, 0, data_size, 0, 0, 2, 0)
    return result
end

local function color_map()
    return "\xff\xff\xff\xff\x00\x00\x00\x00"
end

local function data(array)
    local result = ""
    for col = #array, 1, -1
    do
        local row_data = ""
        local index = 0
        local current_data = 0
        for row = 1, #array, 1
        do
            if array[row][col] > 0 then
                current_data = current_data | 1 << (31 - index)
            end
            index = index + 1

            if index == 32 then
                row_data = row_data .. string.pack(">I4", current_data)
                current_data = 0
                index = 0
            end
        
        end
        if index > 0 then
            row_data = row_data .. string.pack(">I4", current_data)
        end
        
        result = result .. row_data
    end
    return result
end

local function bmp(array, width)
    if not width then 
        width = #array * 10 
    end
    array = format_data(array, width)
    return header(array) .. dib(array) .. color_map() .. data(array)
end

return bmp
