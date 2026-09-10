allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Force a minimum compileSdk on plugin subprojects that pin an older SDK
// (e.g. geocoding_android → android-33), which blocks the app build.
// Uses reflection so it works across AGP DSL changes (new `compileSdk`
// property vs. legacy `compileSdkVersion(int)` method). Guards on
// state.executed because evaluationDependsOn(":app") above can evaluate
// some subprojects before this block registers its callback.
subprojects {
    val applyMinSdk = fun(proj: org.gradle.api.Project) {
        val android = proj.extensions.findByName("android") ?: return
        val minSdk = 36
        val methods = android.javaClass.methods
        val getNew = methods.firstOrNull { it.name == "getCompileSdk" && it.parameterCount == 0 }
        val setNew = methods.firstOrNull {
            it.name == "setCompileSdk" && it.parameterCount == 1 && it.parameterTypes[0] == Integer::class.java
        }
        if (getNew != null && setNew != null) {
            val current = (getNew.invoke(android) as? Int) ?: 0
            if (current < minSdk) setNew.invoke(android, minSdk)
        } else {
            methods.firstOrNull {
                it.name == "compileSdkVersion" && it.parameterCount == 1 && it.parameterTypes[0] == Integer.TYPE
            }?.invoke(android, minSdk)
        }
    }
    if (state.executed) {
        applyMinSdk(project)
    } else {
        afterEvaluate { applyMinSdk(project) }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
