# Exercise 6 — QoS: Compatibility and Incompatibility

## Objective

Understand how QoS policies affect (or break) communication between a publisher and a subscriber, and learn to read the diagnostics ROS2 gives when there's an incompatibility.

## Problem statement

### Part A — Reliability

1. Create a publisher with `RELIABLE` QoS and a subscriber with `RELIABLE` QoS: they should communicate normally.
2. Switch the publisher to `BEST_EFFORT` while keeping the subscriber on `RELIABLE`. Per the DDS spec, this is **incompatible** (a "reliable" subscriber cannot connect to a "best effort" publisher). Verify:
   - That the subscriber receives no messages.
   - The *warning* emitted by `rclcpp` (or use `ros2 topic info /topic --verbose` to see the effective QoS and spot the incompatibility).
3. Try the reverse combination (publisher `RELIABLE`, subscriber `BEST_EFFORT`): this one is actually valid — why? (hint: the subscriber is asking for "at most this", not "at least this").

### Part B — Durability

4. Create a publisher with `TRANSIENT_LOCAL` (keeps the last message for new subscribers) and publish a single message. Then start a subscriber **afterwards** with `TRANSIENT_LOCAL`: it should receive that last message even though it connected late ("late-joiner").
5. Repeat the same experiment with a `VOLATILE` subscriber (the default): it should receive nothing if it connects after the publication.
6. Try publisher `VOLATILE` + subscriber `TRANSIENT_LOCAL`: again, an incompatible combination — document the observed behavior/message.

### Part C — Diagnostics

7. Use `ros2 topic info /topic --verbose` and `ros2 doctor` (or `ros2 wtf`) to inspect the QoS each endpoint is actually using and detect incompatibilities without looking at the code.
8. Add a QoS event callback on the publisher or subscriber (`rclcpp::QoSEventHandler`, `incompatible_qos` event) to programmatically capture when an incompatibility occurs, instead of relying only on logs.

## Technical requirements

- Define QoS with `rclcpp::QoS(...)`, chaining `.reliability(...)`, `.durability(...)`, `.keep_last(N)`, etc.
- Use the same simple message type (`std_msgs::msg::String`, for example) throughout, to keep the focus on the effect of QoS alone.

## Summary table (fill in yourself as the outcome of this exercise)

| Publisher | Subscriber | Compatible? | Why? |
|---|---|---|---|
| RELIABLE | RELIABLE | | |
| BEST_EFFORT | RELIABLE | | |
| RELIABLE | BEST_EFFORT | | |
| BEST_EFFORT | BEST_EFFORT | | |
| TRANSIENT_LOCAL | TRANSIENT_LOCAL | | |
| VOLATILE | TRANSIENT_LOCAL | | |
| TRANSIENT_LOCAL | VOLATILE | | |

## Optional extension

- Repeat the `BEST_EFFORT` experiment with simulated packet loss (you can use `tc`/`netem` on Linux to inject network loss if publisher/subscriber are in separate processes) and observe how `RELIABLE` retries while `BEST_EFFORT` simply drops messages.
