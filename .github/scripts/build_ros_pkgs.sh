#!/usr/bin/env bash
#
# ci_build.sh — CI script that builds every ROS2 package in the workspace
# individually and fails (non-zero exit code) if any package fails to build.
#
# Usage:
#   ./ci_build.sh [workspace_dir]
#
# Env vars:
#   ROS_DISTRO_SETUP   Path to the ROS2 underlay setup.bash (default: /opt/ros/$ROS_DISTRO/setup.bash)
#   COLCON_BUILD_ARGS  Extra args appended to every `colcon build` call (optional)
#
set -uo pipefail
# NOTE: we intentionally do NOT use `set -e` globally, because we want to
# keep building every package even after one fails, and only decide the
# final exit code at the end. Each risky command is checked explicitly.

WS_DIR="${1:-$(pwd)}"
LOG_DIR="${WS_DIR}/ci_build_logs"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo -e "[ci_build] $*"; }
err()  { echo -e "[ci_build][ERROR] $*" >&2; }

# ---------------------------------------------------------------------------
# 1. Basic sanity checks
# ---------------------------------------------------------------------------
if [[ ! -d "${WS_DIR}" ]]; then
    err "Workspace directory '${WS_DIR}' does not exist."
    exit 1
fi

if ! command -v colcon >/dev/null 2>&1; then
    err "'colcon' is not installed or not in PATH."
    exit 1
fi

cd "${WS_DIR}" || exit 1

if [[ ! -d "src" ]]; then
    err "No 'src' directory found in '${WS_DIR}'. Is this a colcon workspace?"
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Source the ROS2 underlay (and overlay install/setup.bash if it exists
#    from a previous run, so dependent packages can find each other)
# ---------------------------------------------------------------------------
ROS_SETUP="${ROS_DISTRO_SETUP:-/opt/ros/${ROS_DISTRO:-humble}/setup.bash}"

if [[ -f "${ROS_SETUP}" ]]; then
    log "Sourcing ROS2 underlay: ${ROS_SETUP}"
    # ROS2's setup.bash references variables (e.g. AMENT_TRACE_SETUP_FILES)
    # without initializing them first, which is incompatible with `set -u`.
    # Temporarily disable nounset while sourcing it.
    set +u
    # shellcheck disable=SC1090
    source "${ROS_SETUP}"
    set -u
else
    err "Could not find ROS2 setup file at '${ROS_SETUP}'."
    err "Set ROS_DISTRO or ROS_DISTRO_SETUP to point to the correct setup.bash."
    exit 1
fi

if [[ -f "install/setup.bash" ]]; then
    log "Sourcing existing overlay: install/setup.bash"
    set +u
    # shellcheck disable=SC1090
    source "install/setup.bash"
    set -u
fi

# ---------------------------------------------------------------------------
# 3. Discover all packages in the workspace
# ---------------------------------------------------------------------------
log "Discovering packages under '${WS_DIR}/src' ..."

mapfile -t PACKAGES < <(colcon list --base-paths src --names-only 2>/dev/null | sort)

if [[ "${#PACKAGES[@]}" -eq 0 ]]; then
    err "No packages found under 'src'. Nothing to build."
    exit 1
fi

log "Found ${#PACKAGES[@]} package(s):"
printf '  - %s\n' "${PACKAGES[@]}"

# ---------------------------------------------------------------------------
# 4. Build each package individually so one failure doesn't hide the rest
# ---------------------------------------------------------------------------
mkdir -p "${LOG_DIR}"

FAILED_PACKAGES=()
BUILT_PACKAGES=()

for pkg in "${PACKAGES[@]}"; do
    log "----------------------------------------------------------------"
    log "Building package: ${pkg}"
    log "----------------------------------------------------------------"

    log_file="${LOG_DIR}/${pkg}.log"

    # shellcheck disable=SC2086
    if colcon build \
            --packages-select "${pkg}" \
            --event-handlers console_direct+ \
            ${COLCON_BUILD_ARGS:-} \
            > "${log_file}" 2>&1; then
        log "OK   -> ${pkg}"
        BUILT_PACKAGES+=("${pkg}")
    else
        err "FAIL -> ${pkg} (see ${log_file})"
        FAILED_PACKAGES+=("${pkg}")
        # Print the tail of the failing log immediately for fast CI feedback
        echo "----- last 40 lines of ${log_file} -----"
        tail -n 40 "${log_file}"
        echo "-----------------------------------------"
    fi
done

# ---------------------------------------------------------------------------
# 5. Summary
# ---------------------------------------------------------------------------
log "================================================================"
log "Build summary"
log "================================================================"
log "Total packages : ${#PACKAGES[@]}"
log "Succeeded      : ${#BUILT_PACKAGES[@]}"
log "Failed         : ${#FAILED_PACKAGES[@]}"

if [[ "${#FAILED_PACKAGES[@]}" -gt 0 ]]; then
    err "The following package(s) failed to build:"
    printf '  - %s\n' "${FAILED_PACKAGES[@]}"
    exit 1
fi

log "All packages built successfully."
exit 0
