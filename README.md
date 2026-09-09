# ROS2 Intermediate/Advanced Practice Exercises

A set of self-contained ROS2 exercises targeting an intermediate/advanced level. None of them require real hardware — everything runs with timers, simulated data, and (where useful) artificial jitter/latency.

## Structure

Each exercise has its own file with: objective, full problem statement, technical requirements, expected observations (so you can self-check your solution), and an optional extension to go further.

| # | File | Topic |
|---|------|-------|
| 1 | [`01_callback_groups.md`](01_callback_groups.md) | Callback groups (`MutuallyExclusive` / `Reentrant`) + `MultiThreadedExecutor` |
| 2 | [`02_lifecycle_node.md`](02_lifecycle_node.md) | `rclcpp_lifecycle` node with full state machine |
| 3 | [`03_composable_nodes.md`](03_composable_nodes.md) | Composable nodes / intra-process vs inter-process comms |
| 4 | [`04_custom_interfaces.md`](04_custom_interfaces.md) | Custom `.msg` / `.srv` / `.action` interfaces |
| 5 | [`05_message_filters_sync.md`](05_message_filters_sync.md) | Multi-topic synchronization with `message_filters` |
| 6 | [`06_qos_experiments.md`](06_qos_experiments.md) | QoS compatibility experiments |

## Suggested order

`1 → 6 → 4 → 5 → 2 → 3` (roughly from most self-contained to most "systems-level"), but feel free to jump around based on what interests you most.

## Prerequisites

- ROS2 installed (Humble, Iron, or Jazzy — examples assume a recent distro).
- A working `colcon` workspace (`~/ros2_ws/src` or similar).
- Basic familiarity with `ament_cmake` package layout (`package.xml`, `CMakeLists.txt`).
- C++17 or later (needed for `std::optional`, `std::variant`, structured bindings, etc., in case you combine these with the C++ concurrency exercises).

## General workflow

For each exercise:

1. Create a new package inside your workspace:
   ```bash
   cd ~/ros2_ws/src
   ros2 pkg create <package_name> --build-type ament_cmake --dependencies rclcpp
   ```
2. Implement the node(s) as described in the corresponding exercise file.
3. Build:
   ```bash
   cd ~/ros2_ws
   colcon build --packages-select <package_name>
   source install/setup.bash
   ```
4. Run and verify against the "Expected observations" section of that exercise.

## Notes

- Exercises are independent from each other — you don't need to complete them in order, except where explicitly noted (e.g. Exercise 4 introduces interfaces that could be reused, but it's not mandatory).
- Where a comparison is requested (e.g. latency intra-process vs inter-process, or QoS behavior), try to actually measure and log real numbers rather than just observing qualitatively — it makes the exercise much more valuable.
