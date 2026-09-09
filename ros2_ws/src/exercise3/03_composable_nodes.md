# Exercise 3 — Composable Nodes

## Objective

Compare **inter-process** communication (separate nodes, going through DDS) against **intra-process** communication (multiple nodes loaded as components in the same process).

## Problem statement

1. Implement two simple nodes as **components** (`rclcpp_components`):
   - `TalkerComponent`: publishes a message (`std_msgs::msg::Header`, or a custom message with a timestamp) at a high rate (e.g. 1000 Hz, or whatever is reasonable).
   - `ListenerComponent`: subscribes and, in the callback, computes latency = `this->now() - msg->stamp`, logging it (or accumulating statistics: mean, max).

2. Register them as plugins with `rclcpp_components_register_node` in `CMakeLists.txt`.

3. **Case A — separate processes:** launch each component in its own process, either with `ros2 run rclcpp_components component_container` + `ros2 component load` into two different containers, or with standalone executables wrapping each component.

4. **Case B — same process (intra-process):** launch a single `component_container` (or better, `component_container_mt` for multithreading) and load both components into it. Enable intra-process comms:
   ```cpp
   rclcpp::NodeOptions().use_intra_process_comms(true)
   ```

5. Compare the mean/max latency measured at the listener between Case A and Case B.

## Technical requirements

- Use `ros2 component load /ComponentManager <package> <plugin>`, or — more convenient and reproducible — a launch file with `ComposableNodeContainer` + `ComposableNode`.
- To measure fairly, avoid noise from `sleep` calls: use high-frequency timers and small message sizes so the difference reflects transmission, not processing time.
- Store the statistics (min/max/mean latency) in an array and dump them every N messages.

## Expected observations

- Intra-process latency should be substantially lower (microseconds, since a pointer/`shared_ptr` is passed instead of being serialized over DDS) compared to inter-process (tens/hundreds of microseconds or more, depending on the RMW in use).
- If you use large messages (e.g. multi-MB float arrays), the difference should be even more pronounced.

## Optional extension

- Repeat the comparison varying message size (small vs large) and plot latency vs size for both cases.
- Try different RMW implementations (`rmw_fastrtps_cpp` vs `rmw_cyclonedds_cpp`, if installed) and compare.
