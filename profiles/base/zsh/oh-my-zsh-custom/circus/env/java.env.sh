# ==============================================================================
# Java Configuration
#
# Environment variables for Java development.
# ==============================================================================

# --- JAVA_HOME Auto-Detection -------------------------------------------------

# Auto-detect JAVA_HOME using macOS java_home utility
# This finds the default JDK installed on the system
if [[ -x /usr/libexec/java_home ]] && /usr/libexec/java_home &>/dev/null; then
    export JAVA_HOME=$(/usr/libexec/java_home)
fi

# To use a specific Java version:
# export JAVA_HOME=$(/usr/libexec/java_home -v 17)
# export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# --- Maven Configuration ------------------------------------------------------

# Maven memory settings
export MAVEN_OPTS="-Xmx2048m -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# Maven home (if installed manually)
# export M2_HOME=/opt/homebrew/opt/maven/libexec

# --- Gradle Configuration -----------------------------------------------------

# Gradle memory and performance settings
export GRADLE_OPTS="-Xmx2048m -Dorg.gradle.daemon=true -Dorg.gradle.parallel=true"

# Gradle home directory
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"

# --- JVM Options for Tools ----------------------------------------------------

# Default JVM options for Java tools
export JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"

# --- SDKMAN Configuration -----------------------------------------------------

# SDKMAN directory (Java version manager)
export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

# Initialize SDKMAN if installed
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
