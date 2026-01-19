cmake_minimum_required(VERSION 3.16)

project(CDDatabaseOndrisekQML VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Sql QuickControls2 Core LinguistTools)

qt_standard_project_setup(REQUIRES 6.8)

qt_standard_project_setup(I18N_TRANSLATED_LANGUAGES cs en)
qt_add_translations(appCDDatabaseOndrisekQML
    TS_FILES
        translations/app_cs.ts
        translations/app_en.ts
    RESOURCE_PREFIX "/i18n"
)

qt_add_executable(appCDDatabaseOndrisekQML
    main.cpp
    database.cpp
    database.h
    enums.cpp
    enums.h
    imagefile.cpp
    imagefile.h
    languagemanager.cpp
    languagemanager.h
    thememanager.cpp
    thememanager.h
)

set(QML_FILES
    QML/Main.qml
    QML/AppMenuBar.qml
    QML/AddAlbumForm.qml
    QML/AlbumDetail.qml
    QML/GenreSelectInput.qml
    QML/ImageSelectInput.qml
    QML/Modal.qml
    QML/SearchPanel.qml
    QML/ValidationTextField.qml
    QML/AlbumList.qml
    QML/DestructiveButton.qml
    QML/EditAlbumForm.qml
)

qt_add_qml_module(appCDDatabaseOndrisekQML
    URI CDDatabaseOndrisekQML
    VERSION 1.0
    QML_FILES ${QML_FILES}
)

set_target_properties(appCDDatabaseOndrisekQML PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appCDDatabaseOndrisekQML
    PRIVATE
        Qt6::Quick
        Qt6::Sql
        Qt6::QuickControls2
        Qt6::Core
)

include(GNUInstallDirs)

install(TARGETS appCDDatabaseOndrisekQML
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
