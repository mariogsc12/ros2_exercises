# Exercise 2 — Lifecycle Node

## Objective

Model a managed node lifecycle (`rclcpp_lifecycle::LifecycleNode`) by simulating opening/closing a virtual "sensor".

## Problem statement

Create a node `sensor_lifecycle_node` that inherits from `rclcpp_lifecycle::LifecycleNode` and implements the following transition callbacks:

| Transition | What it should do |
|---|---|
| `on_configure` | "Open" the simulated sensor (e.g. initialize a struct, allocate a buffer, log "sensor configured"). Create (but do not activate yet) a `LifecyclePublisher`. |
| `on_activate` | Activate the publisher (`publisher_->on_activate()`), start a timer that publishes simulated data (e.g. random numbers or a counter) every 500ms. |
| `on_deactivate` | Stop the timer, deactivate the publisher (`publisher_->on_deactivate()`) — the node stays "alive" but stops publishing. |
| `on_cleanup` | Release resources (destroy the simulated buffer/struct, reset pointers). |
| `on_shutdown` | Log shutdown and release any remaining resources, callable from any state. |
| `on_error` | Log the failure and either return `TRANSITION_CALLBACK_FAILURE` or attempt recovery, your choice. |

Every callback must return the appropriate `CallbackReturn` (`SUCCESS`/`FAILURE`/`ERROR`) and clearly log which transition it's handling.

## Technical requirements

- Follow the standard `rclcpp_lifecycle` pattern (the `lifecycle_talker` example from `ros2/demos` is a good reference — don't copy it verbatim, though).
- The "simulated sensor" can be as simple as a class with `open()`, `close()`, and `read()` returning a pseudo-random value.
- Drive the transitions manually from the command line:
  ```bash
  ros2 lifecycle set /sensor_lifecycle_node configure
  ros2 lifecycle set /sensor_lifecycle_node activate
  ros2 lifecycle set /sensor_lifecycle_node deactivate
  ros2 lifecycle set /sensor_lifecycle_node cleanup
  ros2 lifecycle set /sensor_lifecycle_node shutdown
  ```
- Check the current state at any time with `ros2 lifecycle get /sensor_lifecycle_node`.

## Expected observations

- The topic only receives data between `activate` and `deactivate`.
- Attempting invalid transitions (e.g. `activate` without having done `configure`) should fail in a controlled way (the framework already prevents this, but check the resulting error message).
- `ros2 topic echo` should only show publications while the node is in the `active` state.

## Optional extension

- Add a second lifecycle node acting as a "manager" that listens to the first node's state changes (`~/transition_event`) and reacts (e.g. logs "sensor became active").
- Simulate a failure in `on_configure` (return `FAILURE` the first time, `SUCCESS` the second) and observe how the node stays in `unconfigured` instead of moving to `inactive`.
