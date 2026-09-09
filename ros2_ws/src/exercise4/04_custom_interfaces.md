# Exercise 4 — Custom Interfaces: msg + srv + action

## Objective

Design a complete interface, end to end, for a realistic robotics action, including feedback and cancellation.

## Problem statement

Create a package `custom_interfaces` (`ament_cmake`, no C++ code besides the interfaces) containing:

**1. A message `ObjectPose.msg`:**
```
string object_id
geometry_msgs/Pose pose
float32 confidence
```

**2. A service `GetClosestObject.srv`:**
```
# Request
geometry_msgs/Point reference_point
---
# Response
bool found
ObjectPose closest_object
float32 distance
```

**3. An action `PickObject.action`:**
```
# Goal
string object_id
geometry_msgs/Pose target_pose
---
# Result
bool success
string message
float32 total_time_elapsed
---
# Feedback
string current_phase   # e.g. "approaching", "grasping", "lifting"
float32 progress_percent
```

Then, in a **second package** (`custom_interfaces_demo`, `ament_cmake` with C++):

- Implement an **action server** for `PickObject` that:
  - Receives the goal and accepts/rejects it based on some simple condition (e.g. reject if `object_id` is empty).
  - Simulates the "picking" process in phases (`approaching` → `grasping` → `lifting` → `done`), publishing feedback roughly every 300ms with `progress_percent` increasing.
  - Supports **cancellation**: if the client cancels mid-process, it must stop cleanly and return `success = false`.
  - On success, returns the result with the total elapsed time.

- Implement an **action client** that:
  - Sends a goal.
  - Prints the received feedback.
  - Cancels the goal if `progress_percent > 50` in one test case (to force the cancellation path), and lets it complete in another.

## Technical requirements

- Remember to declare the dependency between packages correctly (`rosidl_default_generators`, `rosidl_default_runtime` in the interfaces package; a normal dependency in the package that consumes them).
- Use `rclcpp_action::create_server` / `create_client` with the three typical callbacks: `handle_goal`, `handle_cancel`, `handle_accepted`.
- The goal's *execute* logic must run on a separate thread (standard `rclcpp_action` pattern) so it doesn't block the executor.

## Expected observations

- `ros2 interface show custom_interfaces/action/PickObject` should correctly display your definition.
- `ros2 action send_goal /pick_object custom_interfaces/action/PickObject "{object_id: 'cube_1', ...}" --feedback` should show you feedback in real time.
- On cancellation (`Ctrl+C` on the client, or `ros2 action cancel`), the server should react and not leave the goal hanging.
