// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    // Define versions directly accessible within this block
    val kotlinVersion = "1.9.23" // Ensure this is a string
    val agpVersion = "8.2.2"     // Ensure this is a string
    val googleServicesPluginVersion = "4.4.2" // Ensure this is a string

    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:$agpVersion")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
        classpath("com.google.gms:google-services:$googleServicesPluginVersion")
        
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Your custom build directory settings
val newBuildDir: org.gradle.api.file.Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}