project(creality-cloud-plugin NONE)

cmake_minimum_required(VERSION 2.8.12)

set(INSTALL_PATH "lib/cura/plugins/CrealityCloudIntegration"
    CACHE PATH
    "The path to install the cloud plugin to. Should ideally be relative to CMAKE_INSTALL_PREFIX"
    )

install(DIRECTORY ./ DESTINATION INSTALL_PATH
        PATTERN ".github" EXCLUDE
        )