local merged_config = {}

local modules = {
    "conf.launch",
    "conf.keymap",
    "conf.appearance"
    -- 这里可以继续添加其它 conf 下的模块
}

local function merge_table(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
end

for _, modname in ipairs(modules) do
    local ok, mod = pcall(require, modname)
    if ok and type(mod) == "table" and type(mod.setup) == "function" then
        local conf = mod.setup()
        if type(conf) == "table" then
            merge_table(merged_config, conf)
        end
    end
end

return merged_config
