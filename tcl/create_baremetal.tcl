# создаем workspace
setws baremetal

# создаем platform
platform create -name baremetal_platform -hw zcu102_example.xsa
platform active baremetal_platform
domain create -name "standalone_domain" -os standalone -proc psu_cortexa53_0
platform generate

# создаем example app
app create -name example_app -template {Empty Application(C)} -platform baremetal_platform -domain standalone_domain -sysproj example_app_system
file copy src_baremetal/baremetal_example.c baremetal/example_app/src
app config -name example_app -add libraries m
app build -name example_app