rule("linkrule")
on_config(function(target)
    target:add("shflags", "/DELAYLOAD:bedrock_runtime.dll")
end)
before_link(function(target)
    import("lib.detect.find_file")
    os.mkdir("$(builddir)/.prelink/lib")

    local data = assert(find_file("bedrock_runtime_data", {"$(env PATH)"}), "Cannot find bedrock_runtime_data")
    local link = assert(find_file("prelink.exe", {"$(env PATH)"}), "Cannot find prelink.exe")

    import("core.project.config")

    os.execv(link,
        table.join({vformat("%s-%s-%s", config.get("target_type") or "server", config.get("plat"), config.get("arch")),
                    vformat("$(builddir)/.prelink"), data}, target:objectfiles()))
    target:add("linkdirs", "$(builddir)/.prelink/lib")
    target:add("shflags", "bedrock_runtime_api.lib", {
        force = true
    })
end)
after_link(function(target)
    os.rm("$(builddir)/.prelink/lib/*.lib")
end)
rule_end()
