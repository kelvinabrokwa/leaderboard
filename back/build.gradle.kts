import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.2.6.RELEASE"
	id("io.spring.dependency-management") version "1.0.9.RELEASE"
	//id("com.google.cloud.tools.appengine-appyaml") version "2.2.0"
	kotlin("jvm") version "1.3.71"
	kotlin("plugin.spring") version "1.3.71"
}

group = "biz.kelvin"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_11

repositories {
	jcenter()
	mavenCentral()
}

dependencies {
	implementation("com.google.cloud", "google-cloud-secretmanager", "1.0.1")
	implementation("com.google.cloud.tools", "appengine-gradle-plugin", "2.2.0")
	implementation("com.fasterxml.jackson.core", "jackson-core", "2.10.3")
	implementation("com.fasterxml.jackson.core", "jackson-annotations", "2.10.3")
	implementation("com.fasterxml.jackson.core", "jackson-databind", "2.10.3")
	implementation("org.jetbrains.kotlin", "kotlin-reflect")
	implementation("org.jetbrains.kotlin", "kotlin-stdlib-jdk8")
	implementation("org.jetbrains.exposed", "exposed-core", "0.23.1")
	implementation("org.jetbrains.exposed", "exposed-dao", "0.23.1")
	implementation("org.jetbrains.exposed", "exposed-jdbc", "0.23.1")
	implementation("org.postgresql", "postgresql", "42.2.12")
	implementation("org.springframework.boot", "spring-boot-starter")
	implementation("org.springframework.boot", "spring-boot-starter-web")

	testImplementation("org.springframework.boot", "spring-boot-starter-test") {
		exclude(group = "org.junit.vintage", module = "junit-vintage-engine")
	}
}

//apply(plugin = "com.google.cloud.tools.appengine-appyaml")

tasks.withType<Test> {
	useJUnitPlatform()
}

tasks.withType<KotlinCompile> {
	kotlinOptions {
		freeCompilerArgs = listOf("-Xjsr305=strict")
		jvmTarget = "1.8"
	}
}
