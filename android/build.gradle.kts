buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Project Android Gradle Plugin (your version may differ)
        classpath("com.android.tools.build:gradle:8.2.1")

        // Add Google services classpath so the plugin is available
        classpath("com.google.gms:google-services:4.3.15")
    }
}

// Keep your existing top-level configuration (repositories, build dir override, etc.)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// optional: keep your custom build dir logic below
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
   project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
